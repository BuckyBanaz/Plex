import axios from 'axios';
import fs from "fs";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

export interface EstimationResult {
  distanceKm: number;
  durationText?: string;
  estimatedCostINR: number;
  estimatedCostUSD: number;
  currency: string; // default currency for PayPal
}

// Fixed conversion rate INR -> USD (adjust as needed)
const INR_TO_USD = 0.012; // 1 INR ≈ 0.012 USD (~83 INR = 1 USD)

export async function estimateFromGoogle(params: {
  originLat: number;
  originLng: number;
  destinationLat: number;
  destinationLng: number;
  weight: number;
}) : Promise<EstimationResult> {
  const { originLat, originLng, destinationLat, destinationLng, weight } = params;
  const apiKey = config.GOOGLE_MAPS_API_KEY;
  if (!apiKey) throw new Error('GOOGLE_MAPS_API_KEY not set');

  const url = `https://maps.googleapis.com/maps/api/distancematrix/json?origins=${originLat},${originLng}&destinations=${destinationLat},${destinationLng}&key=${apiKey}`;
  const resp = await axios.get(url);
  const data = resp.data;

  if (!data || !data.rows || !data.rows[0] || !data.rows[0].elements || !data.rows[0].elements[0] || data.rows[0].elements[0].status !== 'OK') {
    throw new Error('Unable to get distance from Google Maps API');
  }

  const element = data.rows[0].elements[0];
  const distanceMeters: number = element.distance.value;
  const durationText: string = element.duration?.text || '';
  const distanceKm = distanceMeters / 1000;

  // Pricing formula — tune these numbers to our business
  const baseFare = 50; // base
  const perKm = 10; // per km
  const perKg = 5; // per kg

  const estimatedCostINR = baseFare + distanceKm * perKm + weight * perKg;
  const estimatedCostUSD = Number((estimatedCostINR * INR_TO_USD).toFixed(2));

  return {
    distanceKm: Number(distanceKm.toFixed(2)),
    durationText,
    estimatedCostINR: Number(estimatedCostINR.toFixed(2)),
    estimatedCostUSD,
    currency: 'USD', // default currency for PayPal
  };
}
