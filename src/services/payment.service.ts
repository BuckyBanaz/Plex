import axios from 'axios';
import fs from "fs";
import path from "path";
import paypal from "@paypal/checkout-server-sdk";

const config = JSON.parse(fs.readFileSync(path.join(__dirname, "../config/config.json"), "utf-8"));

// PayPal environment setup
const environment =
  config.PAYPAL_MODE === "live"
    ? new paypal.core.LiveEnvironment(config.PAYPAL_CLIENT_ID, config.PAYPAL_CLIENT_SECRET)
    : new paypal.core.SandboxEnvironment(config.PAYPAL_CLIENT_ID, config.PAYPAL_CLIENT_SECRET);

const client = new paypal.core.PayPalHttpClient(environment);

// Create PayPal order
export async function createPaymentIntent(amount: number, currency: string = "USD") {
  const request = new paypal.orders.OrdersCreateRequest();
//   console.log("request =========> ", request)
  request.prefer("return=representation");
  request.requestBody({
    intent: "CAPTURE",
    purchase_units: [
      {
        amount: {
          currency_code: currency, // use passed currency
          value: amount.toFixed(2),
        },
      },
    ],
        application_context: {
      brand_name: "PLEX APP",          
      landing_page: "NO_PREFERENCE",
      user_action: "PAY_NOW",
      return_url: config.RETURN_URL,              // Redirect after success
      cancel_url: config.CANCEL_URL,              // Redirect if user cancels
    },
  });

  const order = await client.execute(request);
  return order.result; 
}

export const capturePayment = async (orderId: string) => {
  const auth = Buffer.from(`${config.PAYPAL_CLIENT_ID}:${config.PAYPAL_CLIENT_SECRET}`).toString('base64');

  const response = await axios.post(
    `https://api-m.sandbox.paypal.com/v2/checkout/orders/${orderId}/capture`,
    {},
    {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`,
      },
    }
  );

  return response.data;
};
