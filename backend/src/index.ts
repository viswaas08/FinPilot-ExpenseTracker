import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { categorizeTransaction, generateFinancialAdvice } from './aiService';
import { getAuthorizationUrl, exchangeCodeForTokens, createFinPilotSpreadsheet } from './sheetsService';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'FinPilot 2.0 Backend', timestamp: Date.now() });
});

// AI Endpoints (Gemini API protected on server side)
app.post('/api/ai/categorize', async (req, res) => {
  try {
    const { description, amount } = req.body;
    const result = await categorizeTransaction(description, amount || 0);
    res.json(result);
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Categorization failed' });
  }
});

app.post('/api/ai/chat', async (req, res) => {
  try {
    const { question, context } = req.body;
    const reply = await generateFinancialAdvice(question, context || '');
    res.json({ reply });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'AI assistant request failed' });
  }
});

// Google Sheets Endpoints
app.get('/api/sheets/auth-url', (req, res) => {
  try {
    const url = getAuthorizationUrl();
    res.json({ url });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/sheets/callback', async (req, res) => {
  try {
    const { code } = req.body;
    const tokens = await exchangeCodeForTokens(code);
    res.json({ tokens });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/sheets/create', async (req, res) => {
  try {
    const { accessToken, refreshToken } = req.body;
    const spreadsheet = await createFinPilotSpreadsheet(accessToken, refreshToken);
    res.json(spreadsheet);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`FinPilot 2.0 secure backend running on port ${port}`);
});
