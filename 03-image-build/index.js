const express = require('express')
const app = express()
const port = 3000
const process = require('node:process')

app.get('/', (_, res) => {
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
