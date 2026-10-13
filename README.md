# 🩺 Health Assistant (`Health_Checker`)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.141+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-3.1%20%7C%203.8%20Flash-4285F4?logo=google&logoColor=white)](https://ai.google.dev/)
[![NCBI PubMed](https://img.shields.io/badge/Biomedical%20R%26D-NCBI%20PubMed-326295)](https://pubmed.ncbi.nlm.nih.gov/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An intelligent, privacy-first AI digital health assistant combining a cross-platform **Flutter** client with a **FastAPI** Python backend. The system integrates real-time biomedical research from **NCBI PubMed** (whole papers & full study abstracts), **NLM MedlinePlus** expert guidelines, and **NCBI Bookshelf** clinical textbooks, synthesizing evidence-grounded medical triage using **Google Gemini AI**.

---

## 🌟 Key Features

- **Evidence-Grounded AI Conversational Engine:**
  - Powered by Google Gemini (`gemini-3.1-flash-lite`, `gemini-3.8-flash`).
  - Directly studies and cites peer-reviewed PubMed clinical trials, journals, PMIDs, and NIH guidelines.
  - Strictly zero canned or hardcoded responses.
- **Multi-Source Live Medical Research:**
  - **NCBI PubMed E-Utilities:** Fetches active clinical studies and complete study abstracts in real time.
  - **NLM MedlinePlus / NIH:** Live expert clinical summaries, risk factors, and health topics.
  - **NCBI Bookshelf & StatPearls:** Authoritative medical reference textbook chapters.
  - **Wikipedia Medical API:** Pathophysiological definitions and mechanisms.
- **Emergency Triage Detection:**
  - Immediate identification of critical red-flag symptoms (e.g. chest pain, stroke signs, respiratory distress) with urgent dispatch advice.
- **Adaptive Depth Modes:**
  - ⚡ **Short / Concise:** Fast, high-impact triage assessment for mobile users.
  - 📖 **Detailed Explanation:** In-depth clinical briefing covering pathophysiology, staged care protocols, and literature insights.
- **Personalized Health Tracking:**
  - User profiles (age, gender, height, weight), real-time BMI calculator, and metabolic hydration targets.
- **Cross-Platform Flutter UI:**
  - Supports Android, iOS, Web, and Desktop with responsive Material 3 design and offline-first profile caching.

---

## 🏗️ Architecture

```mermaid
graph TD
    subgraph "Flutter Client (lib/)"
        A[AuthWrapper] --> B[HomeScreen]
        B --> C[ChatScreen]
        D[UserProvider] -.State.-> C
        C -->|REST Requests| E[ApiService]
    end

    subgraph "FastAPI Backend (backend/)"
        E --> F[main.py :8001]
        F --> G[ai_service.py]
        G --> H{Emergency Signs?}
        H -->|Yes| I[Critical Emergency Alert]
        H -->|No| J[Live Multi-Source Research Engine]
        J --> K1[NCBI PubMed: Whole Papers & Full Abstracts]
        J --> K2[NLM MedlinePlus: Expert Reviews & Guidelines]
        J --> K3[NCBI Bookshelf: Clinical Textbooks]
        K1 & K2 & K3 --> L[Google Gemini 3.1 / 3.8 Flash]
        L --> M[Evidence-Grounded Conversational Response]
    end
```

---

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** (`>=3.3.0`)
- **Python** (`3.10+`)
- Optional: Free **[Google AI Studio API Key](https://aistudio.google.com/apikey)**

### 1. Unified Launch (Frontend + Backend)
Run the automated runner script:
```bash
./run.sh
# or using shorthand:
./rn.sh
```
- **Flutter Web App:** `http://localhost:8080`
- **FastAPI Backend:** `http://localhost:8001` (Docs: `http://localhost:8001/docs`)

### 2. Configure Gemini AI (Optional)
To enable live generative AI reasoning, copy `.env.example` to `.env` in `backend/`:
```bash
cp backend/.env.example backend/.env
```
Add your free API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```
*(The backend dynamically reloads environment keys without requiring a restart.)*

---

## 📁 Project Structure

```text
Health_Checker/
├── backend/
│   ├── ai_service.py       # Live PubMed research + MedlinePlus + Gemini AI synthesis
│   ├── main.py             # FastAPI REST endpoints (/chat, /profile)
│   ├── requirements.txt    # Python dependencies
│   ├── .env.example        # Environment variables template
│   └── .env                # Local secrets (git-ignored)
├── lib/
│   ├── main.dart           # App entrypoint
│   ├── app.dart            # MultiProvider & MaterialApp setup
│   ├── models/             # Data models (UserProfile)
│   ├── providers/          # State management (UserProvider)
│   ├── screens/            # UI screens (Home, Chat, Login, Onboarding)
│   └── services/           # REST client (ApiService)
├── run.sh                  # All-in-one runner script
├── brain.md                # System architectural blueprint & fast context
└── README.md
```

---

## ⚠️ Medical Disclaimer
This software is intended for educational, research, and informational triage assistance. It is not a substitute for professional medical diagnosis, advice, or treatment. Always consult a licensed healthcare professional for medical concerns.
