'use strict';

const http = require('http');

function _mountRoute(route, backend) {
  let hitCount = 0;
  return (url, req, res) => {
    if ('/cache-test/' + route !== url) {
      return;
    }

    console.log(`hit ${backend.name}: ${++hitCount}`);

    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    backend(req, res, backend.name);
  };
}

function _makeRoutes(routeConf) {
  return Object.keys(routeConf).map(mountURL => {
    return _mountRoute(mountURL, routeConf[mountURL]);
  });
}

// backend def

const smallMassShortBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'small_mass_short'
    })
  );
  res.end(JSON.stringify({ from: name }));
};

const mockBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'small_mass_short'
    })
  );
  res.end(JSON.stringify({ from: name }));
};

const bigFewLongBackend = (req, res, name) => {
  res.setHeader(
    'X-YQJ-CACHE', // trigger Openresty auto-cache
    JSON.stringify({
      type: 'big_few_long'
    })
  );
  res.end(JSON.stringify({ from: name, chunk: Buffer.alloc(10e2).toString() }));
};

const noCacheBackend = (req, res, name) => {
  // no cache
  res.end(JSON.stringify({ from: name }));
};

// run

const routes = _makeRoutes({ bigFewLongBackend, smallMassShortBackend, mockBackend, noCacheBackend });

http
  .createServer((req, res) => {
    routes.forEach(route => {
      route(req.url, req, res);
    });
  })
  .listen(7778);

//
