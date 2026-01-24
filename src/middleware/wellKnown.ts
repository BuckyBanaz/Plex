import express from 'express';
import path from 'path';

export const serveWellKnown = (app: express.Application) => {
  const wellKnownPath = path.join(__dirname, '../../.well-known'); 

  console.log("wellKnowPath ----> ", wellKnownPath);
  

  app.use(
    '/.well-known',
    express.static(wellKnownPath, {
      index: false,
      setHeaders: (res, filePath) => {
        if (filePath.endsWith('assetlinks.json')) {
          res.setHeader('Content-Type', 'application/json; charset=utf-8');
          res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
        }
      },
    })
  );
};
