# 📅 Habit Tracker App (Flutter)

A lightweight, offline-first habit tracking application built with Flutter to help users build consistency and monitor daily routines using persistent local storage and reactive state management.

---

## 🚀 Features

- ✅ Create and manage daily or recurring habits  
- 🔁 Recurring schedule support (daily / selected days)  
- 📆 Track habit completion by date  
- 💾 Fully offline with local data persistence  
- ⚡ Fast and responsive UI using Provider state management

---

## 🧠 Design Goals

This project was built to practice and demonstrate:

- Offline-first mobile app design  
- Local database modeling for recurring data  
- Reactive UI updates with minimal rebuilds  
- Clean separation of UI, state, and persistence layers  

The app does **not** depend on any backend and works entirely offline.

---

## 🏗️ Architecture Overview

The app follows a simple layered architecture:

UI Widgets  
↓  
Provider (State Management)  
↓  
Local Storage Service (Hive / SQLite)

### UI Layer
- Stateless and Stateful widgets
- List and calendar-based views for habits and progress

### State Layer (Provider)
- Centralized habit state
- Handles add, update, and completion actions
- Notifies UI efficiently using scoped listeners

### Data Layer
- Structured local models for habits and completion logs
- Persistent storage using Hive or SQLite (based on implementation)

---

## 🗂️ Data Modeling

### Habit Model
- id  
- title  
- schedule (daily or selected weekdays)  
- createdAt  

### Completion Model
- habitId  
- date  
- completed (boolean)  

This separation allows:
- Historical tracking  
- Flexible recurring schedules  

---

## ⚙️ Tech Stack

- Flutter  
- Dart  
- Provider (state management)  
- Hive / SQLite (local persistence)

---

## 🧪 What I Learned

- Designing offline-first mobile workflows  
- Structuring local relational-style data models  
- Preventing unnecessary widget rebuilds using Provider  
- Building responsive layouts without backend dependencies

---

## 📌 Future Improvements

- Habit analytics and visual charts  
- Optional cloud sync across devices  
- Local notifications and reminders  
- Modular feature separation

---

## ▶️ Getting Started

1. Clone the repository  
   git clone <repo-url>

2. Install dependencies  
   flutter pub get

3. Run the app  
   flutter run

---

## 📄 License

This project is intended for educational and portfolio purposes.
