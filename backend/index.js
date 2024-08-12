import express from 'express';
import bodyParser from 'body-parser';
import axios from 'axios';
import swaggerUi from 'swagger-ui-express';
import swaggerDocs from './swagger.cjs'; 
import open from 'open';
import dotenv from 'dotenv';
import cors from 'cors'; 

dotenv.config();

const app = express();
const port = 3000;

// Use CORS middleware
app.use(cors()); 

app.use(bodyParser.json());

// CREATE LINK TOKEN
app.post('/api/create-link-token', async (req, res) => {
    const { client_id, secret, client_name, country_codes, language, user, products } = req.body;
    
    if (!client_name || !country_codes || !language || !user || !products) {
        return res.status(400).json({ error: 'Invalid request payload' });
    }

    try {
        const response = await axios.post('https://sandbox.plaid.com/link/token/create', {
            client_id: process.env.PLAID_CLIENT_ID || client_id,
            secret: process.env.PLAID_SECRET || secret,
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

// CREATE PUBLIC TOKEN
app.post('/api/create-public-token', async (req, res) => {
    const { client_id, secret, institution_id, initial_products } = req.body;

    if (!institution_id || !initial_products) {
        return res.status(400).json({ error: 'Invalid request payload' });
    }

    try {
        const response = await axios.post('https://sandbox.plaid.com/sandbox/public_token/create', {
            client_id: process.env.PLAID_CLIENT_ID || client_id,
            secret: process.env.PLAID_SECRET || secret,
            institution_id,
            initial_products,
            options: {
                webhook: "https://www.genericwebhookurl.com/webhook"
            }
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

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs.specs));

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
    open(`http://localhost:${port}/api-docs`);
});
