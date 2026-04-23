# 🚀 Héalance - Team Dashboard & Action Plan

Welcome to the central hub! Below is the current status of our hackathon project. Find your role, see what is done, check what you need to do next, and look at the "Where to work" paths so you know exactly which files to edit.

---

## 🛠️ How to Access & Run the Project

**🚨 CRITICAL: The `.env` Vault**
We have hidden our Firebase and Gemini API keys for security. If you try to run the app without the `.env` file, **it will crash.**
1. Create a file named exactly `.env` inside the `frontend/` folder (next to `pubspec.yaml`).
2. Paste the required keys (`GEMINI_API_KEY`, `FIREBASE_API_KEY`, `FIREBASE_APP_ID`) inside and save.
3. **DO NOT COMMIT THIS FILE!** It is already in `.gitignore`.

**To run the frontend app:**
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

**Project Context:** See `GEMINI.md` in the root for a detailed architecture breakdown and development guidelines.

---

## 📋 Role Assignments & Checklists

### 🎨 Role 1: Frontend Developer (UI/UX)
**📍 Where to work:** `frontend/lib/screens/`

- [x] Build the Flutter app foundation & navigation structure.
- [x] Create `login_screen.dart` with anonymous avatar selection.
- [x] Build `feed_screen.dart` UI (trending algorithm, post cards).
- [x] Build `map_screen.dart` UI to display resource nodes.
- [x] Connect the "Create Post" button to the live Firebase database.
- [ ] **PENDING:** Build the Chat UI in `tools_screen.dart` (Implement chat bubbles and a text input box).
- [ ] **PENDING:** Integrate AI: Connect the Chat UI to `HelanceAIService.getChatbotResponse()`.
- [ ] **PENDING:** Integrate AI: Swap the fake safety logic in `feed_screen.dart` with the real `HelanceAIService.isPostSafe()` function.

### ⚙️ Role 2: Backend / Node.js Developer
**📍 Where to work:** `backend/`

- [x] Initialize the `backend` folder structure.
- [x] Set up the base Node.js environment (`index.js`).
- [x] Connect to Firebase Firestore and implement resilience points (upvotes).
- [ ] **PENDING:** Implement request validation for new posts (ensure non-empty title/body).
- [ ] **PENDING:** Ensure the backend server runs stably for the live demo.

### 🧠 Role 3: AI Engineer (Prompt Designer)
**📍 Status: ✅ COMPLETE & VERIFIED**

- [x] **Gemini Integration:** Connected the `google_generative_ai` SDK using `gemini-2.5-flash-lite`.
- [x] **Safety Interceptor:** Implemented a high-precision `isPostSafe` function with robust crisis detection.
- [x] **AI Sidekick Persona:** Defined "Helance," a warm, supportive student companion with strict medical boundaries.
- [x] **Context Memory:** Updated the chatbot to support conversation history for continuous context.
- [x] **Live Testing:** Verified all AI logic with a real API key in a production-like environment.

### 🌉 Role 4: Integrator / Project Manager (YOU)
**📍 Where to work:** Project-wide (`GitHub`, `Firebase`, `Integrations`)

- [x] Set up GitHub Monorepo and version control rules.
- [x] Handle the API Key security crisis and establish the `.env` vault.
- [x] Set up Firebase Firestore and seed the live map database.
- [x] Write the Flutter bridge connecting the Map UI to the database (Read).
- [x] Write the Flutter bridge connecting the Feed UI to the database (Write).
- [ ] **PENDING:** Coordinate the final integration between Role 1's UI and Role 3's AI logic.
- [ ] **PENDING:** Final QA test of the entire app flow.
- [ ] **PENDING:** Plan, script, and record the 3-minute pitch demo.
