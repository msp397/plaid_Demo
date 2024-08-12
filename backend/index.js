const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const port = 3000;
app.use(bodyParser.json());

app.post('api/create-link-token', async (req, res) => {
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

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
