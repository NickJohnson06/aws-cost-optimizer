exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
      'Access-Control-Allow-Methods': 'OPTIONS,GET,POST,PUT,DELETE'
    },
    body: JSON.stringify({
      message: 'AWS Cost Optimizer API placeholder',
      status: 'ok',
      timestamp: new Date().toISOString()
    })
  };
};
