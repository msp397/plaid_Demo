import express from "express";
import axios from "axios";
import dotenv from "dotenv";
const router = express.Router();

dotenv.config();

// BALANCE AUTH
router.post("/balance-auth", async (req, res) => {
  const { institution_id } = req.body;
  if (!institution_id) {
    return res.status(400).json({ error: "Invalid request payload" });
  }
  try {
    const response = await axios.post(
      "https://sandbox.plaid.com/sandbox/public_token/create",
      {
        client_id: process.env.PLAID_CLIENT_ID || client_id,
        secret: process.env.PLAID_SECRET || secret,
        institution_id: institution_id,
        initial_products: ["auth"],
        options: {
          webhook: "https://www.genericwebhookurl.com/webhook",
        },
      }
    );
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error("Error contacting Plaid API:", error.message);
    res.status(error.response ? error.response.status : 500).json({
      error: error.message,
      ...(error.response ? error.response.data : {}),
    });
  }
});

// EXCHANGE PUBLIC TOKEN
router.post("/exchange-public-token", async (req, res) => {
  const { public_token } = req.body;
  if (!public_token) {
    return res.status(400).json({ error: "Invalid request payload" });
  }
  try {
    const response = await axios.post(
      "https://sandbox.plaid.com/item/public_token/exchange",
      {
        client_id: process.env.PLAID_CLIENT_ID || client_id,
        secret: process.env.PLAID_SECRET || secret,
        public_token,
      }
    );
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error("Error contacting Plaid API:", error.message);
    res.status(error.response ? error.response.status : 500).json({
      error: error.message,
      ...(error.response ? error.response.data : {}),
    });
  }
});

// CHECK BALANCE
router.post("/check-balance", async (req, res) => {
  const { access_token, account_id } = req.body;

  if (!access_token || !account_id) {
    return res
      .status(400)
      .json({ error: "Missing access_token or account_id in request payload" });
  }

  const localAccount = accountsData.accounts.find(
    (acc) => acc.account_id === account_id
  );

  if (localAccount) {
    return res.json(localAccount.balances);
  } else {
    try {
      const response = await axios.post(
        "https://sandbox.plaid.com/accounts/balance/get",
        {
          client_id: process.env.PLAID_CLIENT_ID,
          secret: process.env.PLAID_SECRET,
          access_token,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );
      const plaidAccount = response.data.accounts.find(
        (acc) => acc.account_id === account_id
      );

      if (plaidAccount) {
        res.json(plaidAccount.balances);
      } else {
        res.status(404).json({ error: "Account not found in Plaid" });
      }
    } catch (error) {
      console.error("Error contacting Plaid API:", error.message);
      res.status(error.response ? error.response.status : 500).json({
        error: error.message,
        ...(error.response ? error.response.data : {}),
      });
    }
  }
});
