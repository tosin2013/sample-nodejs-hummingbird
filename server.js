'use strict';

const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

const OPERATIONS = {
  uppercase: (text) => text.toUpperCase(),
  lowercase: (text) => text.toLowerCase(),
  reverse: (text) => text.split('').reverse().join(''),
  wordcount: (text) => String(text.trim().split(/\s+/).filter(Boolean).length),
  base64encode: (text) => Buffer.from(text).toString('base64'),
  base64decode: (text) => Buffer.from(text, 'base64').toString('utf-8'),
};

app.get('/', (_req, res) => {
  res.json({
    nodeVersion: process.version,
    expressVersion: require('express/package.json').version,
    v8Version: process.versions.v8,
    platform: process.platform,
    architecture: process.arch,
  });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'healthy' });
});

app.post('/transform', (req, res) => {
  const { text, operation } = req.body || {};

  if (typeof text !== 'string') {
    return res.status(400).json({ error: 'Missing or invalid "text" field (string required)' });
  }

  if (!operation || !OPERATIONS[operation]) {
    return res.status(400).json({
      error: `Invalid or missing "operation". Supported: ${Object.keys(OPERATIONS).join(', ')}`,
    });
  }

  res.json({
    input: text,
    operation,
    result: OPERATIONS[operation](text),
  });
});

app.get('/transform/sample', (_req, res) => {
  const sampleText = 'hello world';
  const sampleOperation = 'uppercase';

  res.json({
    input: sampleText,
    operation: sampleOperation,
    result: OPERATIONS[sampleOperation](sampleText),
  });
});

const server = app.listen(PORT, () => {
  console.log(`sample-nodejs-hummingbird listening on port ${PORT}`);
});

function shutdown(signal) {
  console.log(`\nReceived ${signal}. Shutting down gracefully...`);
  server.close(() => {
    console.log('Server closed.');
    process.exit(0);
  });
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
