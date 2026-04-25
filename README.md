# 🚀 Héalance - Anonymous AI-Powered Mental Health for Students

Héalance is a next-generation mental health platform designed specifically for university students. It bridges the gap between isolation and professional help by providing an anonymous, AI-protected community where students can connect without the fear of exposure.

---

## 🛑 The Problem Statement
University students are facing a **silent crisis**. Burnout, academic pressure, and loneliness are at an all-time high, yet many students avoid seeking help due to:
1.  **Stigma:** Fear of being judged by peers or faculty.
2.  **Exposure:** Concerns about privacy on social media.
3.  **Isolation:** Not knowing where to start or who to talk to.
4.  **Resource Deserts:** Difficulty finding local, accessible mental health support.

## ✅ Our Solution
Héalance provides a **Safe Haven** through three core pillars:
*   **Anonymity First:** Users are identified only by randomly generated Dicebear avatars and anonymous handles.
*   **AI Protection:** Every post is screened by our **Gemini-powered Safety Interceptor** before it ever reaches the community.
*   **Intelligent Companion:** Our AI Sidekick, **Helance**, provides 24/7 empathetic support and "remembers" user struggles to offer personalized guidance.

---

## ✨ Key Features in Detail

### 1. The Protected Community Feed
*   **Anonymous Posting:** Share struggles about burnout or anxiety without revealing identity.
*   **AI Auto-Categorization:** Our AI automatically tags posts (e.g., #AcademicBurnout, #Loneliness) based on contextual understanding.
*   **AI Verified Badge:** A golden trust indicator showing that a post has been cleared by our safety moderator.
*   **Resilience Points:** A supportive upvote system where students "uplift" each other's stories.

### 2. The AI Safety Interceptor
*   **Real-Time Screening:** Implemented using **Gemini 2.5 Flash Lite**. It detects high-risk language (self-harm, crisis) with high precision.
*   **Crisis Redirection:** If a post is flagged, the user is immediately diverted to a compassionate "Intercept UI" with one-tap access to 24/7 crisis hotlines.

### 3. Helance: The AI Sidekick
*   **Empathetic Persona:** A warm, university-focused companion that maintains strict medical boundaries.
*   **Emotional Memory:** Helance "remembers" and analyzes your last 3 community posts to understand your journey over time and provide deeper, non-generic support.
*   **Contextual Chat:** Full conversation history support for natural, flowing dialogue.

### 4. Wellbeing Dashboard & Resource Map
*   **Mental Battery:** Visual tracking of energy levels based on self-reported data.
*   **Sleep Pattern Alerts:** Anonymous tracking of late-night app activity to highlight potential sleep issues.
*   **Local Resource Nodes:** A map identifying "Stable Zones" (counseling centers) and "Resource Deserts" (areas lacking support).

---

## 🛠️ The Full Tech Stack
*   **Frontend:** Flutter Web (Dart) – Material 3 Design & Responsive Layouts.
*   **Backend:** Node.js, Express – RESTful API for community data.
*   **Database:** Firebase Firestore – Real-time data synchronization.
*   **AI Engine:** Google Gemini (2.5 Flash Lite) via `google_generative_ai`.
*   **Security:** `flutter_dotenv` for secret management and strict `.gitignore` protocols.
*   **Avatars:** Dicebear API integration for anonymous identity generation.

---

## 📋 Role Assignments & Detailed Checklist

### 🎨 Role 1: Frontend Developer (UI/UX)
**📍 Focus:** Interactive components and user experience.
- [x] **Foundation:** Build the Flutter navigation (BottomNavBar: Feed, Map, Tools).
- [x] **Onboarding:** Create the Login Screen with anonymous avatar selection logic.
- [x] **Community:** Build the `RichPostCard` UI with "Resilience Point" interactions.
- [x] **Feed Logic:** Implement category filtering and the "Trending Today" sidebar.
- [x] **Chat UI:** Design message bubbles (User vs. Helance) and auto-scroll behavior.
- [x] **Moderation UI:** Build the **Safety Intercept Modal** and crisis resource buttons.
- [x] **Dashboard:** Implement the "Mental Battery" and "Wellbeing Roadmap" visuals.

### ⚙️ Role 2: Backend Developer
**📍 Focus:** Server reliability and data integrity.
- [x] **Architecture:** Initialize Node.js Express server and Firestore SDK.
- [x] **Post API:** Implement `GET /api/posts` and `POST /api/posts` endpoints.
- [x] **Resilience Logic:** Build the Firebase `increment` function for post upvotes.
- [x] **Data Hardening:** Add validation to prevent empty or malformed posts from reaching the cloud.
- [x] **Sorting:** Ensure the API returns posts by `timestamp` to keep the feed fresh.

### 🧠 Role 3: AI Engineer (Prompt Designer)
**📍 Focus:** Intelligence, safety, and persona.
- [x] **SDK Integration:** Connect `google_generative_ai` and secure API keys in the `.env` vault.
- [x] **Safety Interceptor:** Engineer the high-precision "YES/NO" safety classification prompt.
- [x] **Auto-Classifier:** Build the JSON-based categorization engine for the Feed.
- [x] **Persona Design:** Define "Helance" as a warm, supportive student sidekick.
- [x] **Memory Bridge:** Implement the **Emotional Memory** logic to share user history with the AI.
- [x] **Robustness:** Added "Fail-Open" logic and compassionate fallback messages for API timeouts.

### 🌉 Role 4: Integrator / Project Manager
**📍 Focus:** End-to-end flow and project delivery.
- [x] **Security:** Establish the `.env` vault and coordinate secret management.
- [x] **Database:** Seed Firestore with initial map markers and sample posts for the demo.
- [x] **Bridges:** Connect the Frontend UI text controllers to the Backend API and AI Service.
- [x] **State Management:** Implement the global `UserActivityTracker` to sync data across screens.
- [x] **Documentation:** Finalize `README.md` and `GEMINI.md` for the pitch.
- [ ] **Pitch Prep:** Record the "Golden Path" demo video (Login -> Post -> Trigger Safety -> Chat).

---

## 🚀 Getting Started

1.  **Clone the Repo:** `git clone https://github.com/Hardeepak/healance-app.git`
2.  **Setup Secrets:** Create `frontend/.env` and add:
    *   `GEMINI_API_KEY=your_key`
    *   `FIREBASE_API_KEY=your_key`
    *   `FIREBASE_APP_ID=your_id`
3.  **Run Backend:** `cd backend && npm start`
4.  **Run Frontend:** `cd frontend && flutter run -d chrome`
