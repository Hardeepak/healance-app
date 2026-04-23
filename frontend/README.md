# 🚀 Héalance - Team Dashboard & Action Plan

Welcome to the central hub! Below is the current status of our hackathon project. Find your role, see what is done, check what you need to do next, and look at the "Where to work" paths so you know exactly which files to edit.

---

## 🛠️ How to Access & Run the Project

**🚨 CRITICAL: The `.env` Vault**
We have hidden our Firebase and Gemini API keys for security. If you try to run the app without the `.env` file, **it will crash.**
1. Ask the Integrator (Role 4) to DM you the `.env` file text.
2. Create a file named exactly `.env` inside the `frontend/` folder (next to `pubspec.yaml`).
3. Paste the keys inside and save. **Do not commit this file!**

**To run the frontend app:**
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📋 Role Assignments & Checklists

### 🎨 Role 1: Frontend Developer (UI/UX)
**📍 Where to work:** `frontend/lib/screens/`

- [x] Build the Flutter app foundation & navigation structure.
- [x] Create `login_screen.dart` with anonymous avatar selection.
- [x] Build `feed_screen.dart` UI (trending algorithm, post cards).
- [x] Build `map_screen.dart` UI to display resource nodes.
- [x] Connect the "Create Post" button to the live Firebase database.
- [ ] **PENDING:** Build the Chat UI in `tools_screen.dart` (Add chat bubbles and a text input box for the AI Sidekick).
- [ ] **PENDING:** Swap the fake safety logic in `feed_screen.dart` with the real `HelanceAIService.isPostSafe()` function.

### ⚙️ Role 2: Backend / Node.js Developer
**📍 Where to work:** `backend/src/`

- [x] Initialize the `backend` folder structure.
- [x] Set up the base Node.js / TypeScript environment (`src/index.ts`).
- [ ] **PENDING:** Write the actual backend server logic for our custom Genkit flow (if applicable).
- [ ] **PENDING:** Ensure the backend server runs without crashing so the frontend can communicate with it.

### 🧠 Role 3: AI Engineer (Prompt Designer)
**📍 Where to work:** `frontend/lib/services/ai_service.dart`

- [x] Generate Google Gemini API keys.
- [x] Receive the `ai_service.dart` bridge file to work in.
- [ ] **PENDING:** Define the safety logic parameters in the `isPostSafe` function so it accurately flags self-harm language.
- [ ] **PENDING:** Write the exact instructions for the Gemini Chatbot in the `getChatbotResponse` function (define its personality, tone, and medical boundaries).

### 🌉 Role 4: Integrator / Project Manager (YOU)
**📍 Where to work:** Project-wide (`GitHub`, `Firebase`, `Integrations`)

- [x] Set up GitHub Monorepo and version control rules.
- [x] Handle the API Key security crisis and establish the `.env` vault.
- [x] Set up Firebase Firestore and seed the live map database.
- [x] Write the Flutter bridge connecting the Map UI to the database (Read).
- [x] Write the Flutter bridge connecting the Feed UI to the database (Write).
- [x] Install the Gemini SDK and build the `ai_service.dart` foundation.
- [ ] **PENDING:** Connect Role 1's Chat UI to Role 3's AI logic.
- [ ] **PENDING:** Final QA test of the entire app flow.
- [ ] **PENDING:** Plan, script, and record the 3-minute pitch demo.