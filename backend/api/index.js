const { Client } = require('pg');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

// Embedded database schema SQL for self-contained execution inside AWS Lambda
const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS daily_costs (
    id SERIAL PRIMARY KEY,
    usage_date DATE NOT NULL,
    service VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    usage_type VARCHAR(255) NOT NULL,
    unblended_cost NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    amortized_cost NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    currency VARCHAR(10) NOT NULL DEFAULT 'USD',
    tags JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_costs_unique 
ON daily_costs (usage_date, service, region, usage_type);

CREATE INDEX IF NOT EXISTS idx_daily_costs_date ON daily_costs (usage_date);
CREATE INDEX IF NOT EXISTS idx_daily_costs_service ON daily_costs (service);
CREATE INDEX IF NOT EXISTS idx_daily_costs_tags ON daily_costs USING gin (tags);

CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    resource_id VARCHAR(255) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    service VARCHAR(100) NOT NULL,
    current_config JSONB,
    recommended_config JSONB,
    estimated_savings NUMERIC(12, 4) NOT NULL DEFAULT 0.0000,
    rule_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_recommendations_resource ON recommendations (resource_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_status ON recommendations (status);
CREATE INDEX IF NOT EXISTS idx_recommendations_savings ON recommendations (estimated_savings DESC);

CREATE TABLE IF NOT EXISTS anomalies (
    id SERIAL PRIMARY KEY,
    detection_date DATE NOT NULL,
    service VARCHAR(100) NOT NULL,
    expected_cost NUMERIC(12, 4) NOT NULL,
    actual_cost NUMERIC(12, 4) NOT NULL,
    deviation_percentage NUMERIC(6, 2) NOT NULL,
    anomaly_score NUMERIC(5, 2),
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_anomalies_date ON anomalies (detection_date);
CREATE INDEX IF NOT EXISTS idx_anomalies_status ON anomalies (status);
`;

// Helper to retrieve the database master user password from Secrets Manager
async function getDbPassword() {
  const secretArn = process.env.DB_SECRET;
  if (!secretArn) {
    throw new Error('DB_SECRET environment variable is missing');
  }

  const client = new SecretsManagerClient({ region: process.env.AWS_REGION || 'us-east-1' });
  const response = await client.send(new GetSecretValueCommand({ SecretId: secretArn }));
  
  if (response.SecretString) {
    const secrets = JSON.parse(response.SecretString);
    return secrets.password;
  }
  throw new Error('Database password secret is empty');
}

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const path = event.path || (event.requestContext && event.requestContext.path) || '';
  
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'OPTIONS,GET,POST,PUT,DELETE'
  };

  // Check if this is the database migration route
  if (path.endsWith('/migrate')) {
    let client;
    try {
      console.log('Retrieving database credentials...');
      const password = await getDbPassword();

      console.log('Connecting to PostgreSQL database...');
      client = new Client({
        host: process.env.DB_HOST,
        port: parseInt(process.env.DB_PORT || '5432'),
        database: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: password,
        ssl: { rejectUnauthorized: false } // Required for AWS RDS secure connection inside VPC
      });

      await client.connect();
      console.log('Connected successfully. Executing migration schema...');

      await client.query(SCHEMA_SQL);
      console.log('Database migration completed successfully.');

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          status: 'success',
          message: 'Database schema applied successfully',
          tables: ['daily_costs', 'recommendations', 'anomalies'],
          timestamp: new Date().toISOString()
        })
      };
    } catch (error) {
      console.error('Migration failed:', error);
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          status: 'error',
          message: 'Database migration failed',
          error: error.message,
          timestamp: new Date().toISOString()
        })
      };
    } finally {
      if (client) {
        await client.end();
      }
    }
  }

  // Default placeholder response
  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({
      message: 'AWS Cost Optimizer API placeholder',
      status: 'ok',
      timestamp: new Date().toISOString()
    })
  };
};
