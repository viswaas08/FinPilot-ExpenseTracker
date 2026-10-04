# 💎 FinPilot 2.0 — Personal Finance Operating System

[![Kotlin](https://img.shields.io/badge/Kotlin-2.1.0-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Compose Multiplatform](https://img.shields.io/badge/Compose%20Multiplatform-1.7.1-4285F4?style=for-the-badge&logo=jetpackcompose&logoColor=white)](https://www.jetbrains.com/compose-multiplatform/)
[![SQLDelight](https://img.shields.io/badge/SQLDelight-2.0.2-10B981?style=for-the-badge)](https://cashapp.github.io/sqldelight/)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-AI%20Intelligence-8E75C2?style=for-the-badge&logo=googlegemini&logoColor=white)](https://ai.google.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

> **FinPilot 2.0** is an enterprise-grade Personal Finance and Expense Operating System designed for **Android and Web**, powered by **Kotlin Multiplatform (KMP) + Compose Multiplatform**. It features offline-first SQLDelight persistence, real-time bidirectional Firestore synchronization, multi-account asset & liability tracking, Google Gemini financial intelligence, and on-demand Google Sheets integration.

---

## 🌐 System Architecture & Core Modules

```text
FinPilot
│
├── androidApp       # Native Android Application & Launcher Activity
├── webApp           # Compose Multiplatform Web (Canvas / Wasm) Runner
├── shared-ui        # Unified Compose UI screens, responsive layout & components
├── domain           # Enterprise Domain Entities, Repository Contracts & Use Cases
├── data             # Offline SQLDelight primary store & Remote Firestore bridge
├── sync             # Offline Mutation Queue, Conflict Resolver (LWW) & Sync Engine
├── auth             # Firebase Auth, Google Sign-In, Session & Biometric Security
├── ai               # Gemini AI Intelligence Engine (Secure server-side proxy)
├── sheets           # Google Sheets OAuth 2.0 & Structured Spreadsheet Export
├── notifications    # Budget thresholds, 24h subscription reminders & alerts
├── core             # Decimal-Safe Money, Currencies, Liquid Glass Theme & Logging
└── backend          # Secure Node.js / Cloud Functions Server Gateway
```

---

## 🌟 Key Features

1. **Offline-First Architecture**:
   - Primary data layer runs on local SQLDelight SQLite boxes.
   - Fully operational without network: browse accounts, log transactions, review budgets, and examine analytics completely offline.
   - Pending changes queue automatically syncs upon reconnection with exponential backoff.

2. **Real-Time Android ↔ Web Synchronization**:
   - Seamless data sync between Android and Web instances via Firestore event listeners.
   - State indicator shows live status: `✓ Synced`, `↻ Syncing...`, `○ Offline`, `⚠ Sync failed`.

3. **Multi-Account & Credit Card Management**:
   - Supports `BANK`, `CASH_WALLET`, `CREDIT_CARD`, `SAVINGS`, `INVESTMENT`, and `FIXED_DEPOSIT`.
   - First-class credit card tracker displaying limit, current balance, available credit, and real-time utilization % (e.g. `27.4%`).
   - Transfer transactions adjust account balances without altering total net worth (`Assets - Liabilities`).

4. **Natural Language Transaction Entry**:
   - Type naturally (e.g. `"Spent ₹240 on lunch"` or `"Received ₹50000 salary"`).
   - AI interprets amount, type, category, and description, requiring user confirmation before saving.

5. **Gemini AI Financial Intelligence**:
   - Deterministic Financial Health Score (0–100) combining savings rate, debt-to-income, and runway.
   - Cash-flow forecasting for 7, 30, and 90 days.
   - Conversational finance assistant grounded in your actual records.
   - **Zero Client Key Exposure**: All Gemini calls run through the secure backend gateway.

6. **Google Sheets Voluntary Integration**:
   - Connect your personal Google account via OAuth 2.0.
   - Generates a structured `FinPilot Finance 2026` workbook with 8 dedicated tabs:
     `Dashboard`, `Transactions`, `Income`, `Expenses`, `Accounts`, `Budgets`, `Goals`, `Subscriptions`.
   - On-demand "Sync Now" export with selective category/date-range filtering.

7. **Decimal-Safe Financial Engine**:
   - Zero floating-point rounding errors using integer minor units (`paise` / `cents`).
   - Default base currency: **Indian Rupee (₹ INR)** with support for 13+ world currencies.

---

## 🚀 Quick Start Guide

### Prerequisites
- **JDK**: Version 17 or higher (`java -version`)
- **Android SDK**: API 35 (for Android target)
- **Node.js**: `v20.x` or higher (for backend gateway)

### 1. Configure Secrets
```bash
cp .env.example .env
# Edit .env with your Gemini API Key & Google OAuth credentials
```

### 2. Launch Backend Gateway
```bash
cd backend
npm install
npm run dev
```

### 3. Build & Run Application

#### Web Target (Compose Multiplatform)
```bash
./FinPilot/gradlew :webApp:jsBrowserDevelopmentRun
```
Access at `http://localhost:8080`.

#### Android Target
```bash
./FinPilot/gradlew :androidApp:assembleDebug
# Install to device / emulator:
./FinPilot/gradlew :androidApp:installDebug
```

---

## 🔒 Security & Privacy Posture
- Strict Firestore rules guarantee **100% user data isolation**: `request.auth.uid == userId`.
- All AI queries pass through privacy sanitization to strip account numbers and credentials.
- Local biometric authentication protects access via fingerprint, Face ID, or system PIN.

---

## 📄 Documentation Sitemap
- [`ARCHITECTURE.md`](file:///e:/2026/Flutter%20App-Expense%20Tracker/ARCHITECTURE.md) — Architectural patterns, clean MVVM/MVI, and flow diagrams.
- [`DATABASE.md`](file:///e:/2026/Flutter%20App-Expense%20Tracker/DATABASE.md) — SQLDelight & Firestore schemas and query patterns.
- [`SYNC.md`](file:///e:/2026/Flutter%20App-Expense%20Tracker/SYNC.md) — Offline queue, LWW conflict resolution, and retry backoff.
- [`SECURITY.md`](file:///e:/2026/Flutter%20App-Expense%20Tracker/SECURITY.md) — Security guardrails, secret protection, and Firestore rules.
- [`DEPLOYMENT.md`](file:///e:/2026/Flutter%20App-Expense%20Tracker/DEPLOYMENT.md) — Firebase Hosting, Android Release builds, and CI/CD pipelines.
