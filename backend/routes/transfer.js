import express from "express";
import axios from "axios";
import dotenv from "dotenv";
const router = express.Router();

dotenv.config();

// RETRIEVE ITEM ACCOUNT LIST
router.post("/get-item-account-info", async (req, res) => {
    const { access_token } =
      req.body;
    if (!access_token) {
      return res.statusCode(400).json({ error: "Invalid request payload" });
    } else {
      try {
        const response = await axios.post(
          "https://sandbox.plaid.com/accounts/get",
          {
            client_id: process.env.PLAID_CLIENT_ID || client_id,
            secret: process.env.PLAID_SECRET || secret,
            access_token: access_token,
          }
        );
        res.status(response.status).json(response.data);
      } catch (error) {
        console.error("Error contacting plaid API:", error.message);
        res.status(error.response ? error.response.status : 500).json({
          error: error.message,
          ...(error.response ? error.response.data : {}),
        });
      }
    }
  });
  
  
  // AUTHORIZE A TRANSFER
  router.post("/authorize", async (req, res) => {
    const { access_token, account_id, type, network, ach_class, amount, user } =
      req.body;
    if (!access_token || !account_id) {
      return res.statusCode(400).json({ error: "Invalid request payload" });
    } else {
      try {
        const response = await axios.post(
          "https://sandbox.plaid.com/transfer/authorization/create",
          {
            client_id: process.env.PLAID_CLIENT_ID || client_id,
            secret: process.env.PLAID_SECRET || secret,
            access_token: access_token,
            account_id: account_id,
            type: type,
            network: network,
            ach_class: ach_class,
            amount: amount,
            user: user,
          }
        );
        res.status(response.status).json(response.data);
      } catch (error) {
        console.error("Error contacting plaid API:", error.message);
        res.status(error.response ? error.response.status : 500).json({
          error: error.message,
          ...(error.response ? error.response.data : {}),
        });
      }
    }
  });
  

  // INITIATE A TRANSFER
  router.post("/initiate", async (req, res) => {
    const {
      access_token,
      account_id,
      type,
      network,
      ach_class,
      amount,
      user,
      description,
      origination_account_id,
      custom_tag,
      iso_currency_code,
      metadata,
      authorization_id,
    } = req.body;
    if (!access_token || !account_id) {
      return res.statusCode(400).json({ error: "Invalid request payload" });
    } else {
      try {
        const response = await axios.post(
          "https://sandbox.plaid.com/transfer/create",
          {
            client_id: process.env.PLAID_CLIENT_ID || client_id,
            secret: process.env.PLAID_SECRET || secret,
            access_token: access_token,
            account_id: account_id,
            type: type,
            network: network,
            ach_class: ach_class,
            amount: amount,
            iso_currency_code: iso_currency_code,
            description: description,
            user: user,
            // custom_tag: custom_tag,
            metadata: metadata,
            origination_account_id: origination_account_id,
            authorization_id: authorization_id
          }
        );
        res.status(response.status).json(response.data);
      } catch (error) {
        console.error("Error contacting plaid API:", error.message);
        res.status(error.response ? error.response.status : 500).json({
          error: error.message,
          ...(error.response ? error.response.data : {}),
        });
      }
    }
  });

  module.exports = router;