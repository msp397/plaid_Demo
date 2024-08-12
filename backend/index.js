// app.js
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const swaggerUi = require('swagger-ui-express');
const swaggerDocs = require('./swagger');
// const open = require('open');

const app = express();
const port = 3000;

app.use(bodyParser.json());

// Example Swagger documentation for the endpoint
/**
 * @openapi
 * /api/create-link-token:
 *   post:
 *     summary: Creates a link token with Plaid API
 *     description: Generates a link token to use with Plaid's Link SDK.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               client_id:
 *                 type: string
 *                 example: 'your-client-id'
 *               secret:
 *                 type: string
 *                 example: 'your-secret'
 *               client_name:
 *                 type: string
 *                 example: 'Your App Name'
 *               country_codes:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ['US']
 *               language:
 *                 type: string
 *                 example: 'en'
 *               user:
 *                 type: object
 *                 properties:
 *                   client_user_id:
 *                     type: string
 *                     example: 'unique-user-id'
 *               products:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ['auth', 'transactions']
 *     responses:
 *       200:
 *         description: Link token created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *       400:
 *         description: Invalid request payload
 *       500:
 *         description: Internal server error
 */
app.post('/api/create-link-token', async (req, res) => {
    const { client_id, secret, client_name, country_codes, language, user, products } = req.body;

    if (!client_id || !secret || !client_name || !country_codes || !language || !user || !products) {
        return res.status(400).json({ error: 'Invalid request payload' });
    }

    try {
        const response = await axios.post('https://sandbox.plaid.com/link/token/create', {
            client_id,
            secret,
            client_name,
            country_codes,
            language,
            user,
            products
        });

        res.status(response.status).json(response.data);
    } catch (error) {
        console.error('Error contacting Plaid API:', error.message);
        res.status(error.response ? error.response.status : 500).json({
            error: error.message,
            ...(error.response ? error.response.data : {})
        });
    }
});

app.use('/', swaggerUi.serve, swaggerUi.setup(swaggerDocs.specs));

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
    //open(`http://localhost:${port}/api-docs`);
});
