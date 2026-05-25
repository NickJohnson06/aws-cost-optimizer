# Package the API Lambda function code
data "archive_file" "api_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/api"
  output_path = "${path.module}/files/api-placeholder.zip"
}

# IAM Role for API Lambda
resource "aws_iam_role" "api_lambda" {
  name = "${var.project_name}-api-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach basic execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC access policy (required to run inside VPC subnets)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Security Group for the API Lambda
resource "aws_security_group" "api_lambda" {
  name        = "${var.project_name}-api-lambda-sg-${var.environment}"
  description = "Security group for API Lambda function"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# API Lambda Function
resource "aws_lambda_function" "api" {
  filename         = data.archive_file.api_zip.output_path
  source_code_hash = data.archive_file.api_zip.output_base64sha256
  function_name    = "${var.project_name}-api-${var.environment}"
  role             = aws_iam_role.api_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 29
  memory_size      = 256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.api_lambda.id]
  }

  environment {
    variables = {
      ENV       = var.environment
      DB_HOST   = aws_db_instance.postgres.address
      DB_PORT   = "5432"
      DB_NAME   = var.db_name
      DB_USER   = var.db_username
      DB_SECRET = aws_db_instance.postgres.master_user_secret[0].secret_arn
    }
  }

  tags = local.common_tags
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "API Gateway for AWS Cost Optimizer"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.common_tags
}

# API Gateway Proxy Resource: /{proxy+}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway Proxy Method: ANY /{proxy+}
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway Proxy Integration
resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

# API Gateway Root Method: ANY /
resource "aws_api_gateway_method" "root" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway Root Integration
resource "aws_api_gateway_integration" "root" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.proxy,
    aws_api_gateway_integration.root
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id,
      aws_api_gateway_method.root.id,
      aws_api_gateway_integration.root.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  tags = local.common_tags
}

# Permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN should be the execution ARN of the API Gateway
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
