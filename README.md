   # 📘 AI Exam Helper App

An AI-powered mobile application designed to help students **study and prepare for exams** by scanning questions from images, extracting text using OCR, and generating **step-by-step explanations** using a large language model.

> ⚠️ **Ethical Notice**: This app is intended for **learning, revision, and practice only**. It is not designed to encourage cheating during live examinations.
  
---

## 🚀 Project Overview

Students often struggle to understand exam-style questions from textbooks, notes, or past papers. This app simplifies the learning process by allowing users to:

1. Take a photo of a question
2. Extract text from the image using Vision AI (OCR)
3. Generate a clear, step-by-step explanation using AI
4. Save questions and answers for future revision

The project demonstrates **real-world AI integration**, **mobile development**, and **full-stack backend design**.

---

## ✨ Key Features

* 📸 **Image to Text (OCR)** using Google ML Kit (offline-capable)
* 🤖 **AI-powered explanations** using Gemini API
* 🔐 **Authentication** (Email/Password + Google Sign-In)
* 💾 **Cloud storage** of Q&A history with Firebase Firestore
* 📚 **History & revision mode**
* ⚡ Clean architecture with separation of concerns

---

## 🧠 Tech Stack

| Layer            | Technology                  |
| ---------------- | --------------------------- |
| Mobile Framework | Flutter                     |
| OCR              | Google ML Kit               |
| AI Model         | Gemini API                  |
| Backend          | Firebase                    |
| Authentication   | Firebase Auth + Google Auth |
| Database         | Cloud Firestore             |

All services are used within **free tiers**.

---

## 🏗️ App Architecture

The app follows a **feature-based clean architecture**:

* UI handles only presentation
* Controllers manage logic
* Services handle external APIs
* Models define data structures

This makes the app scalable, testable, and production-ready.

---

## 📂 File Structure

```
lib/
│
├── main.dart                # App entry point
├── app.dart                 # MaterialApp, theme, routes
│
├── core/                    # App-wide utilities
│   ├── constants/           # App & API constants
│   ├── theme/               # Global theme
│   └── utils/               # Helpers (logger, validators)
│
├── services/                # External services layer
│   ├── auth/                # Firebase authentication logic
│   ├── ocr/                 # ML Kit OCR service
│   ├── ai/                  # Gemini API service
│   ├── firestore/           # Firestore database logic
│   └── storage/             # Image storage (optional)
│
├── features/                # Feature-based modules
│   ├── auth/                # Login / Register / Google Auth
│   ├── scan/                # Camera + OCR flow
│   ├── result/              # AI answer display
│   ├── history/             # Saved Q&A list
│   └── profile/             # User profile & logout
│
├── models/                  # Data models
│   ├── question_model.dart
│   └── user_model.dart
│
└── routes/                  # App navigation routes
    └── app_routes.dart
```

---

## 🔁 Data Flow

```
User takes photo
   ↓
ML Kit OCR extracts text
   ↓
Gemini API generates explanation
   ↓
Result shown to user
   ↓
(Optional) Saved to Firestore
```

Each step is isolated and handled by a dedicated service.

---

## 🔐 Firebase Security

Firestore rules ensure that users can **only access their own data**:

```
users/{uid}/history/{docId}
```

This is enforced using Firebase Authentication.

---

## 🧪 Error Handling & UX

* OCR failure handling
* Empty or unclear image detection
* AI API error fallback
* Loading indicators for all async actions
* Friendly error messages

These decisions reflect **production-level thinking**.

---

## 📈 Future Enhancements

* Subject auto-detection (Math, Physics, Chemistry)
* Difficulty modes (Beginner / Exam / Revision)
* Offline OCR caching
* AI usage limits & premium plans
* Teacher / tutor mode

---

## 🎯 Why This Project Matters

This app demonstrates:

* Vision AI integration
* LLM usage with prompt engineering
* Full-stack mobile development
* Ethical AI considerations
* Scalable architecture

It is designed as a **portfolio-grade project**, not just a demo.

---

## 👤 Author

Built by a developer passionate about **AI, mobile apps, and education technology**.

--- 

⭐ If you find this project useful or inspiring, feel free to star the repository!
      