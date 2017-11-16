'use strict';

const express = require('express');
const app = express();

// backend def

const mock2Backend = (req, res, next) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'default'
    })
  );
  res.end(JSON.stringify({ from: res.locals.name }));
};

const mockBackend = (req, res, next) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'default'
    })
  );

  const data = JSON.stringify({
    code: 200,
    data: {
      from: res.locals.name,
      time: new Date().toLocaleString(),
      encoding: '中文'
    }
  });
  res.setHeader('Content-Length', Buffer.byteLength(data, 'utf8'));
  res.end(data);
};

const bigChunkBackend = (req, res, next) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'default'
    })
  );
  res.end(JSON.stringify({ from: res.locals.name, chunk: Buffer.alloc(1e4).toString() }));
};

const noCacheBackend = (req, res, next) => {
  // no cache
  res.end(JSON.stringify({ from: res.locals.name }));
};

// run

const routes = [bigChunkBackend, mock2Backend, mockBackend, noCacheBackend];

function _makeRoute(backend) {
  let hitCount = 0;
  return (req, res, next) => {
    console.log(`hit ${backend.name}: ${++hitCount} with url:${req.originalUrl}`);
    res.locals.name = backend.name;
    backend(req, res, next);
  };
}

app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json');
  next();
});

const ROUTE_PREFIX = '/cache-test';
routes.forEach(route => {
  app.use(`${ROUTE_PREFIX}/${route.name}`, _makeRoute(route));
});

app.listen(7778, () => console.log('Started on port 7778!'));
