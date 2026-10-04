# 🚀 FinPilot 2.0 — Build & Deployment Guide

## 1. Prerequisites
- **Java Development Kit**: JDK 17+
- **Android SDK**: Build Tools 35.0.0
- **Node.js**: `v20.x` or higher
- **Firebase CLI**: `npm install -g firebase-tools`

---

## 2. Web Deployment (Firebase Hosting)

### Step 1: Build Compose Multiplatform Web Bundle
```bash
./FinPilot/gradlew :webApp:jsBrowserProductionWebpack
```
Output directory: `FinPilot/webApp/build/dist/js/productionExecutable`

### Step 2: Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```
Live URLs:
- Primary: `https://expense-tracker-f9567.web.app`
- Secondary: `https://expense-tracker-f9567.firebaseapp.com`

---

## 3. Android Distribution (APK & AAB)

### Build Release APK
```bash
./FinPilot/gradlew :androidApp:assembleRelease
```
Artifact location: `FinPilot/androidApp/build/outputs/apk/release/androidApp-release.apk`

### Build Google Play App Bundle (AAB)
```bash
./FinPilot/gradlew :androidApp:bundleRelease
```
Artifact location: `FinPilot/androidApp/build/outputs/bundle/release/androidApp-release.aab`

---

## 4. Backend Gateway Deployment

### Deploy to Firebase Cloud Functions / Cloud Run
```bash
cd backend
npm install
npm run build
firebase deploy --only functions
```

Alternatively, run with Docker:
```bash
docker build -t finpilot-backend:2.0 ./backend
docker run -p 5000:5000 --env-file .env finpilot-backend:2.0
```

---

## 5. Automated CI/CD (GitHub Actions)
The repository includes automated CI/CD pipeline triggers in `.github/workflows/ci.yml`:
- Validates code compilation on every pull request and push to `main`.
- Runs multiplatform test suites.
- Builds production web bundles and Android APKs.
