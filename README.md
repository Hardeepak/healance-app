# 🚀 Héalance - Anonymous AI-Powered Mental Health for Students

Héalance is a next-generation mental health platform designed specifically for university students. It bridges the gap between isolation and professional help by providing an anonymous, AI-protected community where students can connect, vent, and find resources without the fear of exposure or stigma.

---

## 🛑 The Problem Statement
University students are facing a **silent crisis**. Burnout, academic pressure, and loneliness are at an all-time high, yet many students avoid seeking help due to:
1.  **Stigma:** Fear of being judged by peers or faculty.
2.  **Exposure:** Concerns about privacy on standard social media platforms.
3.  **Isolation:** Not knowing where to start or how to navigate their mental health journey.
4.  **Resource Deserts:** Difficulty identifying where physical and digital support is actually available.

## ✅ Our Solution
Héalance provides a **Safe Haven** through three core pillars:
*   **Anonymity First:** Users are identified only by randomly generated Dicebear avatars and anonymous handles, ensuring zero peer-exposure.
*   **AI Protection:** Every community post is screened by our **Gemini-powered Safety Interceptor** in real-time before it is published.
*   **Deep Empathy AI:** Our AI Sidekick, **Héalance**, provides 24/7 personalized support by "remembering" user struggles to offer patterns and insights over generic advice.

---

## ✨ Key Features in Detail

### 1. The AI-Protected Community Feed
*   **Anonymous Posting:** Share struggles about burnout, relationships, or anxiety securely.
*   **AI Auto-Categorization:** Our Gemini engine automatically tags posts (e.g., #AcademicBurnout, #Loneliness) based on contextual analysis.
*   **AI Verified Badge:** A golden trust indicator showing that a post has been cleared by our safety interceptor.
*   **Resilience Points:** A supportive engagement system where students "uplift" each other’s posts.
*   **Nested Anonymous Comments:** Engage in deep, private conversations within the safety of the community.

### 2. The AI Safety Interceptor
*   **Real-Time Crisis Detection:** Powered by **Gemini 2.5 Flash Lite**. It detects high-risk language (self-harm, clinical crisis) with high precision.
*   **Crisis Redirection:** If a post is flagged as unsafe, the user is immediately diverted to a compassionate "Intercept UI" with one-tap access to 24/7 crisis hotlines like the Befrienders.

### 3. Héalance Sidekick: Emotional Memory
*   **Contextual Intelligence:** Unlike standard chatbots, the Héalance Sidekick "remembers" and analyzes the user's last 3 community posts.
*   **Pattern Recognition:** It identifies recurring themes (e.g., "I see you've been posting late at night about future doubts") to provide deeper, more personalized empathy.
*   **Safe Boundaries:** The AI is strictly tuned to provide support while maintaining a clear medical disclaimer (not a doctor).

### 4. Interactive Resource Map
*   **Resilience Nodes:** Visualizes "Stable Zones" (counseling centers) and "Resource Deserts" (areas lacking support) across Malaysia.
*   **Live Data Sync:** Markers update in real-time from our Firebase database.
*   **Interactive Insights:** AI-generated summaries of regional mental health trends (e.g., burnout spikes in university districts).

---

## 🛠️ The Full Tech Stack
*   **Frontend:** Flutter Web (Dart) – Material 3 Design with rich, responsive layouts.
*   **Backend:** Node.js, Express – Scalable RESTful API for community interactions.
*   **Database:** Firebase Firestore – Real-time NoSQL data synchronization.
*   **Authentication:** Firebase Auth – Secure, anonymous sign-in flow.
*   **AI Engine:** Google Gemini (2.5 Flash Lite) via `google_generative_ai`.
*   **Mapping:** `flutter_map` with OpenStreetMap (CartoDB Dark tiles).
*   **Identity:** Dicebear API integration for procedural avatar generation.

---

## 📋 Role Assignments & Final Checklist

### 🎨 Role 1: Frontend Developer (UI/UX)
**📍 Focus:** Component architecture and visual storytelling.
- [x] **Foundation:** Build the Flutter navigation and layout structure.
- [x] **Auth UI:** Create the Login/Signup screen with live avatar selection.
- [x] **Feed UI:** Implement `RichPostCard` with Resilience Point logic and Sharing.
- [x] **Interaction:** Build the nested comment system and the Safety Intercept Modal.
- [x] **Dashboard:** Develop the "Wellbeing Roadmap" with interactive goal-tracking.

### ⚙️ Role 2: Backend Developer
**📍 Focus:** Server logic and cloud data management.
- [x] **API Core:** Initialize Node.js Express server and Firestore SDK.
- [x] **EndPoints:** Implement `GET/POST /api/posts` and comment routing.
- [x] **Security:** Add backend validation to ensure data integrity.
- [x] **Sync:** Match frontend field names (`resiliencePoints`, `authorEmail`) with backend logic.

### 🧠 Role 3: AI Engineer (Prompt Designer)
**📍 Focus:** Safety logic, persona, and memory engineering.
- [x] **Safety Engine:** Design the high-precision "YES/NO" interceptor prompt.
- [x] **Classifier:** Build the context-aware auto-tagging system for posts.
- [x] **Emotional Memory:** Implement the `UserActivityTracker` bridge for AI context.
- [x] **Persona:** Hardcode the "Héalance" identity and medical boundaries.

### 🌉 Role 4: Integrator / Project Manager
**📍 Focus:** End-to-end stability and delivery.
- [x] **Deployment:** Manage the GitHub monorepo and versioning.
- [x] **Security:** Established the `.env` vault for API keys.
- [x] **Database Seed:** Populated the initial resource nodes for the Malaysia map.
- [x] **Stability:** Fixed the `const FirebaseOptions` runtime error and UI overflows.

---

## 🚀 Getting Started

1.  **Clone the Repo:** `git clone https://github.com/Hardeepak/healance-app.git`
2.  **Setup Secrets:** Create `frontend/.env` and add:
    *   `GEMINI_API_KEY=your_key`
    *   `FIREBASE_API_KEY=your_key`
    *   `FIREBASE_APP_ID=your_id`
3.  **Run Backend:** `cd backend && npm install && npm start`
4.  **Run Frontend:** `cd frontend && flutter pub get && flutter run -d chrome`
