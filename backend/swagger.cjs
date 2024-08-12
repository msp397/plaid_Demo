// swagger.js
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Plaid API', 
      version: '1.0.0',
      description: 'An API for communicate with Plaid',
    },
  },
  apis: ['./index.js'],
};

const specs = swaggerJsdoc(options);

const swaggerDocs = {
  specs,
  ui: swaggerUi,
};

module.exports = swaggerDocs;
