const express = require('express')
const app = express()
const port = 3000
const process = require('node:process')

const client = require('prom-client');
const collectDefaultMetrics = client.collectDefaultMetrics;
const Registry = client.Registry;
const register = new Registry();
collectDefaultMetrics({ register });


// Endpoint to expose the metrics
app.get('/metrics', async (req, res) => {
  console.log('GET /metrics')
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/', (_, res) => {
  console.log('GET /')
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

process.on('SIGINT', () => {
  console.log('Received SIGINT.')
  process.exit(0)
})

process.on('SIGTERM', () => {
  console.log('Received SIGTERM.')
  process.exit(0)
})
