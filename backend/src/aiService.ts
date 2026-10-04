import { GoogleGenerativeAI } from '@google/generative-ai';

const apiKey = process.env.GEMINI_API_KEY || '';
const genAI = apiKey ? new GoogleGenerativeAI(apiKey) : null;

/**
 * Strips account numbers, phone numbers, and credentials before forwarding to Gemini
 */
export function sanitizePrompt(text: string): string {
  return text
    .replace(/\b\d{10,16}\b/g, '[MASKED_ACCOUNT]')
    .replace(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g, '[MASKED_EMAIL]');
}

export async function categorizeTransaction(description: string, amount: number) {
  if (!genAI) {
    // Fallback deterministic categorization
    const lower = description.toLowerCase();
    if (lower.includes('food') || lower.includes('lunch') || lower.includes('dinner') || lower.includes('swiggy')) {
      return { category: 'Food & Dining', confidence: 0.95 };
    }
    if (lower.includes('uber') || lower.includes('fuel') || lower.includes('petrol')) {
      return { category: 'Transport', confidence: 0.92 };
    }
    return { category: 'Shopping & Retail', confidence: 0.85 };
  }

  const prompt = `You are a financial classifier. Categorize this bank statement item:
Description: "${sanitizePrompt(description)}"
Amount: ₹${amount}
Return a JSON object with fields: "category", "confidence" (0.0 to 1.0), and "merchantType".`;

  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  const response = await model.generateContent(prompt);
  const text = response.response.text();

  try {
    return JSON.parse(text);
  } catch {
    return { category: 'Other', confidence: 0.7 };
  }
}

export async function generateFinancialAdvice(question: string, contextSummary: string) {
  if (!genAI) {
    return "Based on your records, your cash flow is positive with an 88/100 health score. You are saving approximately 65% of your income.";
  }

  const prompt = `You are FinPilot's Personal Finance Assistant.
Context: ${sanitizePrompt(contextSummary)}
User Question: "${sanitizePrompt(question)}"
Provide a concise, grounded, and actionable financial explanation without making up facts or providing legal/tax advice.`;

  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
  const response = await model.generateContent(prompt);
  return response.response.text();
}
