# 🛡 FinPilot 2.0 — Security & Privacy Architecture

## 1. Zero-Exposure Secret Policy
FinPilot 2.0 enforces a strict security guardrail: **No administrative secrets, API keys, or OAuth credentials exist within client binaries or repositories.**

### Client vs Server Responsibilities:
- **Client (Android / Web)**:
  - Contains **only public configuration** (Firebase Project ID, Public Client ID).
  - Interacts exclusively with authenticated Firebase endpoints and the FinPilot backend gateway.
  - Never references `GEMINI_API_KEY`, `GOOGLE_CLIENT_SECRET`, or Firebase Admin keys.
- **Backend Gateway**:
  - Securely parses environment variables (`.env`).
  - Validates caller authentication tokens before fulfilling requests.
  - Proxies Gemini AI requests and Google Sheets OAuth token exchanges.

---

## 2. Cloud Firestore Security Rules
All cloud documents enforce strict ownership validation:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

- Users can **never** query or modify another user's financial accounts, transactions, or budgets.
- Unauthenticated requests are rejected at the Firestore edge.

---

## 3. AI Privacy Sanitization
Before dispatching financial records or query contexts to Google Gemini:
1. **Account Number Masking**: Matches regex `\b\d{10,16}\b` and substitutes `[MASKED_ACCOUNT]`.
2. **Email & Phone Scrubbing**: PII is stripped automatically.
3. **No Credential Ingestion**: Passwords, bank tokens, and secret PINs are explicitly excluded from AI prompts.

---

## 4. Local Biometric & PIN Protection
- Supported via `androidx.biometric.BiometricPrompt` on Android and WebAuthn on Web.
- When enabled in **Settings**, cold launch and app resume trigger immediate screen locking until biometric verification succeeds.

---

## 5. Data Ownership & Portability
In compliance with global data privacy principles (GDPR / CCPA):
- **Export On Demand**: Users can generate comprehensive exports of their financial data in CSV, JSON, or Google Sheets formats.
- **Permanent Account Deletion**: Invoking "Delete Account & Cloud Data" purges the user's Firestore records and local SQLDelight boxes irreversibly.
