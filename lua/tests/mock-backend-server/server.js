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

// const smallFewShortBackend = (req, res, name) => {
//   res.setHeader('X-YQJ-CACHE', 'small_few_short'); // trigger Openresty auto-cache
//   res.end(JSON.stringify({ from: name }));
// };

// const bigMassLongBackend = (req, res, name) => {
//   res.setHeader('X-YQJ-CACHE', 'big_mass_long'); // trigger Openresty auto-cache
//   res.end(JSON.stringify({ from: name }));
// };

const smallChunkDataBackend = (req, res, name) => {
  res.setHeader('X-YQJ-CACHE', true); // trigger Openresty auto-cache
  res.end(JSON.stringify({ from: name }));
};

const bigChunkDataBackend = (req, res, name) => {
  res.setHeader('X-YQJ-CACHE', true); // trigger Openresty auto-cache
  res.end(JSON.stringify({ from: name, chunk: Buffer.alloc(10e3).toString() }));
};

const noCacheBackend = (req, res, name) => {
  // no cache
  res.end(JSON.stringify({ from: name }));
};

// run

const routes = _makeRoutes({ bigChunkDataBackend, smallChunkDataBackend, noCacheBackend });

http
  .createServer((req, res) => {
    routes.forEach(route => {
      route(req.url, req, res);
    });
  })
  .listen(7778);

//
