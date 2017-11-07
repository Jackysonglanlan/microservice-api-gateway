'use strict';

const http = require('http');

const ROUTE_PREFIX = '/cache-test/';

function _mountRoute(route, backend) {
  let hitCount = 0;
  return (uri, req, res) => {
    const matchBackendOwnRule = backend.matchURI && backend.matchURI(uri);

    if (!matchBackendOwnRule) {
      // try common match rule
      if (ROUTE_PREFIX + route !== uri) {
        return;
      }
    }

    console.log(`hit ${backend.name}: ${++hitCount}`);

    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    backend(req, res, backend.name);
  };
}

function _makeRoutes(routeList) {
  return routeList.map(route => {
    return _mountRoute(route.name, route);
  });
}

// backend def

const ttl30sBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'ttl_30s'
    })
  );
  res.end(JSON.stringify({ from: name }));
};

const mockBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'ttl_30s'
    })
  );
  res.end(JSON.stringify({ from: name }));
};

const ttl5mBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'ttl_5m'
    })
  );
  res.end(JSON.stringify({ from: name, chunk: Buffer.alloc(10e2).toString() }));
};

const noCacheBackend = (req, res, name) => {
  // no cache
  res.end(JSON.stringify({ from: name }));
};

const matchRestBackend = (req, res, name) => {
  // no cache
  res.end(JSON.stringify({ from: name, 'receive-uri': req.url }));
};
matchRestBackend.matchURI = uri => {
  return !uri.startsWith(ROUTE_PREFIX);
};

// run

const routes = _makeRoutes([ttl5mBackend, ttl30sBackend, mockBackend, noCacheBackend, matchRestBackend]);

http
  .createServer((req, res) => {
    routes.forEach(route => {
      route(req.url, req, res);
    });
  })
  .listen(7778);

//
