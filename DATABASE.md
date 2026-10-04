# 💾 FinPilot 2.0 — Database Architecture & Schema

## 1. Local Database (SQLDelight)

The primary offline data layer is powered by **SQLDelight 2.0.2** generating type-safe Kotlin APIs directly from standard SQL definitions.

### Table: `AccountEntity`
Stores all liquid assets, bank accounts, wallets, and credit cards.

```sql
CREATE TABLE AccountEntity (
    id TEXT PRIMARY KEY NOT NULL,
    userId TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,                         -- BANK, CASH_WALLET, CREDIT_CARD, etc.
    institutionName TEXT NOT NULL DEFAULT '',
    maskedAccountNumber TEXT NOT NULL DEFAULT '',
    currency TEXT NOT NULL DEFAULT 'INR',
    openingBalanceMinorUnits INTEGER NOT NULL DEFAULT 0,
    currentBalanceMinorUnits INTEGER NOT NULL DEFAULT 0,
    creditLimitMinorUnits INTEGER,              -- Used for CREDIT_CARD accounts
    billingDate INTEGER,
    dueDate INTEGER,
    color TEXT NOT NULL DEFAULT '#6C5CE7',
    icon TEXT NOT NULL DEFAULT 'account_balance',
    isActive INTEGER NOT NULL DEFAULT 1,
    createdAt INTEGER NOT NULL,
    updatedAt INTEGER NOT NULL,
    deletedAt INTEGER,                          -- Soft deletion timestamp
    version INTEGER NOT NULL DEFAULT 1,
    syncStatus TEXT NOT NULL DEFAULT 'SYNCED'   -- SYNCED, PENDING_INSERT, PENDING_UPDATE, PENDING_DELETE
);
```

### Table: `TransactionEntity`
Stores individual financial transactions.

```sql
CREATE TABLE TransactionEntity (
    id TEXT PRIMARY KEY NOT NULL,
    userId TEXT NOT NULL,
    accountId TEXT NOT NULL,
    destinationAccountId TEXT,                 -- Non-null for transfers
    type TEXT NOT NULL,                         -- INCOME, EXPENSE, TRANSFER, REFUND, ADJUSTMENT
    amountMinorUnits INTEGER NOT NULL,
    currency TEXT NOT NULL DEFAULT 'INR',
    baseAmountMinorUnits INTEGER NOT NULL,
    baseCurrency TEXT NOT NULL DEFAULT 'INR',
    exchangeRate REAL NOT NULL DEFAULT 1.0,
    categoryId TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL,
    notes TEXT NOT NULL DEFAULT '',
    tags TEXT NOT NULL DEFAULT '',              -- Comma-separated tags
    date INTEGER NOT NULL,                      -- Epoch ms
    isRecurring INTEGER NOT NULL DEFAULT 0,
    recurringRuleId TEXT,
    createdAt INTEGER NOT NULL,
    updatedAt INTEGER NOT NULL,
    deletedAt INTEGER,
    version INTEGER NOT NULL DEFAULT 1,
    syncStatus TEXT NOT NULL DEFAULT 'SYNCED'
);
```

### Table: `SyncQueueEntity`
Stores offline pending mutations awaiting cloud transmission.

```sql
CREATE TABLE SyncQueueEntity (
    id TEXT PRIMARY KEY NOT NULL,
    entityType TEXT NOT NULL,                   -- ACCOUNT, TRANSACTION, BUDGET, GOAL, etc.
    entityId TEXT NOT NULL,
    operation TEXT NOT NULL,                    -- INSERT, UPDATE, DELETE
    payloadJson TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    lastAttemptAt INTEGER,
    errorMessage TEXT,
    createdAt INTEGER NOT NULL
);
```

---

## 2. Cloud Database (Firebase Firestore)

Firestore serves as the cloud synchronization and backup layer. All data is partitioned under individual authenticated user documents.

### Firestore Document Structure
```text
/users/{userId}
   ├── accounts/{accountId}
   ├── transactions/{transactionId}
   ├── budgets/{budgetId}
   ├── savings_goals/{goalId}
   ├── subscriptions/{subscriptionId}
   └── categories/{categoryId}
```

### Composite Indexes (`firestore.indexes.json`)
High-performance queries are indexed to avoid downloading the entire user collection:
1. `userId` (ASC) + `date` (DESC)
2. `userId` (ASC) + `accountId` (ASC) + `date` (DESC)
3. `userId` (ASC) + `categoryId` (ASC) + `date` (DESC)
4. `userId` (ASC) + `type` (ASC) + `date` (DESC)
5. `userId` (ASC) + `updatedAt` (DESC)

---

## 3. Decimal-Safe Currency Rules
- Monetary figures are **never stored as floats or doubles**.
- All amounts are persisted as **integer minor units** (`Long`):
  - For INR / USD / EUR (scale = 2): `₹100.50` is stored as `10050`.
  - For JPY (scale = 0): `¥1000` is stored as `1000`.
- Mathematical operations are executed entirely on integer numbers, preventing IEEE 754 precision artifacts.
