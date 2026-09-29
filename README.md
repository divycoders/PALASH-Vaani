# PALASH-Vaani (पलाश-वाणी)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Tablet-brightgreen)
![Hardware](https://img.shields.io/badge/RAM-%E2%89%A42GB%20Optimized-orange)
![Offline](https://img.shields.io/badge/Offline-100%25%20Local--First-blueviolet)
![Tests](https://img.shields.io/badge/Tests-70%2F70%20Passed%20(100%25)-success)
![SIH](https://img.shields.io/badge/SIH%202024-Problem%20ID%3A%2026042-critical)

**AI-Assisted Vernacular Pedagogy & Real-Time Classroom Translation Bridge for Tribal Primary Education**  
*Aligned with Jharkhand's PALASH Mother Tongue-Based Multilingual Education (MTB-MLE) & NIPUN Bharat FLN*

[Key Features](#-key-features) • [System Architecture](#-system-architecture) • [Getting Started](#-getting-started) • [SIH Compliance](#-sih-compliance-matrix) • [Test Suite](#-testing--quality-assurance)

</div>

---

## 📌 Context & Ground Reality

In over **5,000+ government primary schools** across the tribal regions of Jharkhand (Santhal Pargana, Kolhan, and Chota Nagpur), foundational learning is severely bottlenecked:
- Over **85% of early grade children** speak indigenous tribal languages (**Santhali, Ho, Mundari**) as their first language at home.
- The majority of appointed primary school teachers are trained in **Standard Hindi** and cannot read or write native tribal scripts like **Ol Chiki** or **Warang Chiti**.
- This language barrier causes severe classroom dropouts and hampers **Foundational Literacy and Numeracy (FLN)**.

**PALASH-Vaani (पलाश-वाणी)** is a local-first, low-resource pedagogical assistant designed to solve this crisis on low-cost government tablets ($\le 2$ GB RAM, Android 9+) without requiring internet or cloud connectivity.

---

## 🚀 Key Features

### 1. ⚡ Real-Time Bidirectional Classroom Voice Bridge ($\le 3.0$s Latency SLA)
* **Trilingual Input Recognition**: Accepts spoken or typed input in **Standard Hindi**, **English**, or **Hinglish** (e.g., *"open your book"*, *"kitab kholo"*, *"pani pina hai"*, *"sit down"*).
* **Instant Vernacular Synthesis**: Translates phrases in real-time into **Santhali (Ol Chiki)**, **Ho**, and **Mundari** with an offline processing latency under **50 ms** (far exceeding the SIH 3.0-second SLA).
* **Interactive Blackboard & Audio Waveforms**: Live visual audio feedback with stop/resume controls, speaker pronunciations, and persistent quick-action classroom moments.

### 2. 🔤 Dual-Script Pedagogical Mode (For Non-Native Teachers)
* Bridges the script divide for teachers who cannot read Ol Chiki:
  * **Native Script** (e.g., `ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ` / `ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ`) displayed for students.
  * **Phonetic Devanagari Pronunciation Guide** (e.g., `पुथी झिज मे` / `जोहार गिद्रा`) enabling teachers to articulate tribal words accurately with confidence.

### 3. 🧠 Dynamic Kids Quiz Engine (FLN Aligned & Infinite Fresh Questions)
* **Procedural Question Generation**: Zero repetitive questions. Generates randomized question sets on every session across:
  * **FLN Mathematics**: Concrete visual additions (`🍎🍎 + 🍎🍎🍎 = ?`), subtractions, everyday geometric shapes (Roti = Circle, Slate = Rectangle, Samosa = Triangle), and Ol Chiki numeral recognition (`᱘ = 8`).
  * **Santhali Language**: Vocabulary matching, animal and nature words, with Ol Chiki script and Roman/Devanagari phonetics.
  * **EVS & Nature**: Local biodiversity (Sal tree, Mahua, animals, river).
* **Child-Friendly Gamification**: Star accumulator (`⭐ Stars`), streak tracker (`🔥 Streak`), animated green/red option feedback, teacher voice audio prompt (`🔊`), and instant pedagogical explanations.

### 4. 📄 Client-Side Bilingual PDF Worksheet Generator
* **100% Offline Document Generation**: Dynamic PDF generator creating printable, high-resolution classroom worksheets.
* **Pedagogical Alignment**: NIPUN Bharat Grade 1–3 competencies (object counting, picture-to-word matching, handwriting drills, and bilingual evaluation rubrics).
* **Teacher Controls**: Configurable difficulty levels (L1, L2, L3), toggleable teacher answer keys, and instant print/share support via Android print spooler.

### 5. 🗂️ Interactive Multi-Deck Audio Flashcards
* Multi-category digital flashcards for classroom engagement:
  * **Numbers**: 1 to 10, 20, 50, 100 with Ol Chiki glyphs.
  * **Fauna**: Tiger, Elephant, Bird, Cow, Fish (`हाकु`, `हाथी`, etc.).
  * **Nature & Flora**: Palash flower, Sal tree, Mahua, Water, Sun (`दारे`, `बाहा`, `दाग`).
  * **Classroom Objects**: Book, Chalk, Slate, School.
  * **Colors & Shapes**: Primary colors and geometric forms with audio pronunciation buttons.

### 6. 📚 Pre-Compiled Offline SQLite Curriculum Pack
* Pre-loaded NIPUN Bharat curriculum modules running locally on SQLite (`sqflite`).
* Structured lesson plans, classroom activities, bilingual assessments, and student progress tracking for Grade 1 and 2.

### 7. 📊 Hardware Telemetry & SIH Compliance Suite
* Built-in diagnostics module allowing evaluators to verify live hardware telemetry:
  * **Live Latency Benchmarking**: Measures SQLite lookup, NLP parsing, transliteration, and TTS pipeline execution.
  * **Low-End Hardware Telemetry**: Monitors RAM usage (~68 MB active heap) and local storage footprint (~14 MB), validating operation on budget 2GB RAM devices.

---

## 🛠️ System Architecture

```
                       ┌───────────────────────────────────────────┐
                       │   Teacher / Student Speech or Text        │
                       │   (Standard Hindi, English, Hinglish)     │
                       └─────────────────────┬─────────────────────┘
                                             │
                                             ▼
                       ┌───────────────────────────────────────────┐
                       │        Input Normalizer & Parser          │
                       │    (Fuzzy Regex, Accent Stripping,        │
                       │     Number & Intent Normalization)        │
                       └─────────────────────┬─────────────────────┘
                                             │
                                             ▼
                       ┌───────────────────────────────────────────┐
                       │       Offline Tribal Lexicon Engine       │
                       │ (Rule-Based Morphosyntax & Intent Cache)  │
                       │        Santhali • Ho • Mundari            │
                       └─────────────────────┬─────────────────────┘
                                             │
                       ┌─────────────────────┴─────────────────────┐
                       ▼                                           ▼
         ┌───────────────────────────┐               ┌───────────────────────────┐
         │ Native Script Generation  │               │ Dual-Script Phonetic Guide│
         │   (Ol Chiki / Tribal)     │               │   (Devanagari Phonetics)  │
         │     e.g., ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ     │               │     e.g., पुथी झिज मे     │
         └─────────────┬─────────────┘               └─────────────┬─────────────┘
                       └─────────────────────┬─────────────────────┘
                                             │
                                             ▼
                       ┌───────────────────────────────────────────┐
                       │      Local Audio TTS / Waveform Stream    │
                       │         Sub-50ms Offline Execution        │
                       └───────────────────────────────────────────┘
```

---

## 📂 Repository Structure

```
lib/
├── app.dart                                # Core MaterialApp & Root Navigation
├── core/
│   ├── database/
│   │   └── database_helper.dart            # Local SQLite database helper
│   ├── routes/
│   │   └── app_routes.dart                 # Named app route definitions
│   ├── services/
│   │   ├── audio_tts_service.dart          # Local offline TTS & audio playback
│   │   ├── speech_recognition_service.dart # Microphone voice input bridge
│   │   ├── translation_engine.dart         # Multi-intent NLP translation pipeline
│   │   └── tribal_lexicon_data.dart        # Trilingual dictionary & intent mappings
│   └── widgets/
│       ├── natural_audio_button.dart       # High-visibility audio button with waveform
│       └── responsive_scaffold.dart        # Dual-mode phone & tablet layout shell
├── features/
│   ├── classroom/                          # Classroom moments & teacher dialogue
│   ├── diagnostics/                        # Real-time hardware telemetry & latency benchmark
│   ├── flashcards/                         # Interactive audio visual vocabulary cards
│   ├── home/                               # Hero dashboard & quick launchpad
│   ├── lessons/                            # NIPUN FLN lesson plans & SQLite browser
│   ├── quiz/                               # Dynamic FLN quiz generator & gamified UI
│   │   ├── data/quiz_question_generator.dart
│   │   ├── models/quiz_question_model.dart
│   │   └── presentation/screens/quiz_screen.dart
│   ├── translator/                         # Bidirectional trilingual translation screen
│   └── worksheets/                         # Client-side vector PDF worksheet generator
└── main.dart                               # Application entrypoint
```

---

## 🏃 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13 or higher)
* [Android SDK](https://developer.android.com/studio) (API level 28+ / Android 9 Pie or later)
* Device / Emulator with $\ge 2$ GB RAM

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/divycoders/PALASH-Vaani.git
   cd PALASH-Vaani
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run automated test suite:**
   ```bash
   flutter test
   ```

4. **Verify static analysis:**
   ```bash
   flutter analyze
   ```

5. **Launch on connected device or emulator:**
   ```bash
   flutter run
   ```

6. **Build production APK (Optimized for $\le 2$GB RAM tablets):**
   ```bash
   flutter build apk --release
   ```

---

## 🧪 Testing & Quality Assurance

PALASH-Vaani includes comprehensive automated testing across core services, translation algorithms, dynamic question generation, responsive UI layouts, and database integrations.

| Test Suite | Scope / Coverage | Result |
| :--- | :--- | :---: |
| `test/core/services/translation_engine_test.dart` | English, Hinglish, & Hindi intent parsing, number parsing, tribal mappings | **15 / 15 Passed** |
| `test/core/services/audio_tts_service_test.dart` | Audio stream state management, error handling, volume & rate configs | **6 / 6 Passed** |
| `test/features/quiz_test.dart` | Dynamic generator constraints, option uniqueness, UI star counters & feedback | **8 / 8 Passed** |
| `test/features/classroom_translator_test.dart` | Classroom dialogue flows, translator blackboard, tablet responsiveness | **9 / 9 Passed** |
| `test/features/flashcards/` | Flashcard category filtering, audio trigger, flip animations | **10 / 10 Passed** |
| `test/features/worksheets/` | Vector PDF document generation, competency metadata, answer key | **15 / 15 Passed** |
| `test/widget_test.dart` | Root offline resilience, responsive NavigationRail, end-to-end integration | **7 / 7 Passed** |
| **Total** | **All Unit, Service, Widget, and Integration Tests** | **70 / 70 Passed (100%)** |

---

## 🏆 SIH Compliance Matrix

| SIH Evaluation Parameter | SIH Requirement | PALASH-Vaani Implementation |
| :--- | :--- | :--- |
| **Language Support** | Minimum 1 tribal language (Ho, Mundari, Santhali) | **Complete support for 3 indigenous languages**: Santhali (Ol Chiki script + Devanagari phonetics), Ho, and Mundari |
| **Voice Latency SLA** | Strictly $\le 3.0$ seconds | **$\le 50$ ms average offline execution** (live benchmarking verified on Diagnostics screen) |
| **Input Flexibility** | Multimodal inputs | **Hindi, English, and Hinglish** speech recognition and text input with auto-normalization |
| **Dual-Script Pedagogy** | Usable by non-native Hindi teachers | **Native Tribal Script + Phonetic Devanagari Guide** on all screens and audio dialogues |
| **Interactive Assessment** | Student engagement tools | **Dynamic Procedural Kids Quiz** (Maths, Language, EVS) with instant gamified feedback |
| **Printable Materials** | Offline worksheet creation | **Native Client-Side Vector PDF Generator** aligned to NIPUN Bharat FLN competencies |
| **Hardware Constraints** | Low-cost Android tablets ($\le 2$ GB RAM, Android 9+) | **Ultra-lightweight footprint**: Active RAM usage ~68 MB, storage ~14 MB, zero cloud dependency |
| **Network Resilience** | Intermittent or zero connectivity | **100% Offline-First Architecture**: Functions without SIM card, cellular data, or Wi-Fi |

---

## 📜 License & Acknowledgments

* **Smart India Hackathon (SIH 2024)** — Problem Statement ID: **26042**
* **Target Beneficiary**: Department of Higher & Technical Education, Government of Jharkhand
* **Program Alignment**: PALASH Mother Tongue-Based Multilingual Education (MTB-MLE) & NIPUN Bharat Mission
* **Built by**: Team DivyCoders
