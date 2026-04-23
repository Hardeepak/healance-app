# 🚀 Héalance - Project Context & Guidelines

Héalance is an anonymous, AI-powered mental health platform designed for university students to navigate burnout, loneliness, and anxiety. It emphasizes connection without exposure, protected by intelligent AI intervention.

## 🏗️ Project Architecture

The project is structured as a **monorepo**:

- **`/frontend`**: Flutter Web application.
- **`/backend`**: Node.js Express server.
- **Root Files**: Project documentation and reference materials.

### 🛠️ Tech Stack
- **Frontend**: Flutter (Dart) for Web.
- **Backend**: Node.js, Express, Firebase SDK.
- **Database**: Firebase Firestore (Real-time).
- **AI**: Google Gemini (1.5 Flash & 2.0 Flash Lite) via `google_generative_ai`.
- **Integrations**: Dicebear API (Avatars), Google Maps (Resource Map).

---

## 🚀 Getting Started

### 🚨 Critical: Environment Variables
The project uses a `.env` vault for security. **Never commit the `.env` file.**
1. Create `healance-app/frontend/.env` based on the following template:
   ```env
   FIREBASE_API_KEY=your_key_here
   FIREBASE_APP_ID=your_id_here
   GEMINI_API_KEY=your_gemini_key_here
   ```

### 🏃 Running the Project

#### Frontend (Flutter Web)
```bash
cd healance-app/frontend
flutter pub get
flutter run -d chrome
```

#### Backend (Node.js)
```bash
cd healance-app/backend
npm install
npm start
```

---

## 📋 Role-Based Workflows

The project is designed for a team of four distinct roles:

### 🎨 Role 1: Frontend Developer (UI/UX)
- **Primary Location**: `frontend/lib/screens/`
- **Key Tasks**: Build the Feed, Login, Map, and Chat UI.
- **Convention**: Use Material 3 design and ensure responsiveness for web browsers.

### ⚙️ Role 2: Backend Developer
- **Primary Location**: `backend/`
- **Key Tasks**: Manage Express routes and Firebase Firestore interactions.
- **Convention**: Use ES Modules (`import/export`) as configured in `package.json`.

### 🧠 Role 3: AI Engineer
- **Primary Location**: `frontend/lib/services/ai_service.dart`
- **Key Tasks**:
    - Refine the **Safety Interceptor** prompt in `isPostSafe`.
    - Define the **AI Sidekick** persona in `getChatbotResponse`.
- **Goal**: Ensure the AI is empathetic, warm, and maintains strict medical boundaries.

### 🌉 Role 4: Integrator / Project Manager
- **Primary Location**: Project-wide
- **Key Tasks**: GitHub management, Firebase seeding, and cross-role integration.

---

## 💡 Development Conventions

1. **Anonymity First**: Users are identified by anonymous names (e.g., `brave_striver_abcd`) and Dicebear avatars.
2. **AI Safety**: Every community post must pass through `HelanceAIService.isPostSafe` before being committed to Firestore.
3. **Real-time Updates**: Prefer Firestore `StreamBuilder` for the community feed and map to avoid manual refreshes.
4. **Error Handling**: AI services should "fail open" or provide graceful fallbacks (e.g., compassionate default messages) if the API is unavailable.
5. **Medical Disclaimer**: The AI Sidekick must always state it is not a doctor and cannot provide clinical diagnoses.

---

## 🗺️ Key Files
- `healance-app/frontend/lib/main.dart`: Entry point & Firebase initialization.
- `healance-app/frontend/lib/services/ai_service.dart`: Centralized Gemini AI logic.
- `healance-app/backend/index.js`: Node.js Express server logic.
- `Healance Reference.txt`: Detailed master documentation and feature breakdown.
