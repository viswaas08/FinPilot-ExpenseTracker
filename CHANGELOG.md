# Changelog

All notable changes to the Liquid Glass Personal Finance & Expense Tracker project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0+1] - 2026-08-07

### Added
- **Core Architecture**: Modular Clean Architecture implementation using Riverpod State Management and Hive local encrypted storage.
- **Liquid Glass Design System**: Full iOS 26 Liquid Glass UI with dynamic mesh gradient background, frosted blur (`BackdropFilter`), and glowing borders.
- **Default Currency Engine**: Built-in multi-currency system defaulting to **Indian Rupee (₹ / INR)** with real-time app-wide currency switching across 20+ world currencies.
- **Gemini AI Engine**: Financial Score calculation (0–100), automated spending habit breakdown, and balance projections.
- **Smart Budget System**: Budget health score, category limit progress visualizers, and 50%/75%/90% alert triggers.
- **Smart Recurring System**: Automated income/expense schedules, subscription management, and 24h due reminders.
- **Smart Notification Hub**: Alert history categorized by Bills, Budgets, Goals, AI Insights, and System notifications.
- **Settings & Security Module**: Biometric Face ID / Fingerprint authentication toggle, one-tap encrypted local backup, and JSON export tools.
- **Motion & Interaction Framework (`LiquidMotionSystem`)**: Tactile scale compression (`LiquidPressable`), Haptic feedback engine, custom page transitions, and rotating loading orb loader.
- **Enterprise Performance Layer**: Startup optimizer (< 1.5s cold boot), image memory cache eviction, and `RepaintBoundary` rendering isolation.
- **Automated QA & Testing Suite**: Unit and widget test suite with 100% pass rate and zero static analyzer errors/warnings.
