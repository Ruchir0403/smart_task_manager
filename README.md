# Smart Site Task Manager

A comprehensive task management application that automatically classifies and prioritizes tasks using intelligent content analysis. Built with a Node.js backend and a polished Flutter mobile interface.

## 1. Project Overview
This project solves the problem of manual task organization by using a "Smart Classification" engine. When a user creates a task (e.g., "Urgent meeting about budget"), the system automatically:
* **Detects Category:** Assigns categories like 'Finance' or 'Scheduling' based on keywords.
* **Assigns Priority:** Flags tasks as 'High' priority if urgent words are detected.
* **Suggests Actions:** Provides actionable steps relevant to the task type.

The goal was to build a production-ready "Hybrid" application demonstrating clean architecture, real-time database persistence, and a responsive mobile UI [cite: 30-35].

## 2. Tech Stack
* **Backend:** Node.js, Express.js
* **Database:** Supabase (PostgreSQL)
* **Mobile App:** Flutter (Dart)
* **State Management:** Riverpod
* **Networking:** Dio
* **Deployment:** Render (Backend Service)

## 3. Setup Instructions

### Backend (Node.js)
1. Navigate to the backend directory:
   ```bash
   cd backend

2. Install dependencies:
   ```bash
   npm install

3. Create a .env file in the backend/ folder with your Supabase credentials:
   ```bash
   PORT=3000
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_KEY=your_supabase_service_role_key

4. Start the server locally:
   ```bash
   npm start

## Mobile App (Flutter)
1. Navigate to the app directory:
   ```bash
   cd mobile_app

2. Install dependencies:
   ```bash
   flutter pub get

3. Run the app (ensure an emulator is running or device is connected):
   ```bash
   flutter run

## API Documentation
GET /api/tasks
Retrieve all tasks with optional filters.
Query Parameters:
* **search:** Search text in title or description.
* **category:** Filter by category (e.g., 'finance', 'technical').
* **priority:** Filter by priority ('high', 'medium', 'low').

POST /api/tasks

Create a new task. The system will auto-classify it upon creation.

Request Body:

{
  "title": "Fix login bug",
  "description": "Users getting 500 error",
  "assigned_to": "Dev Team",
  "due_date": "2025-12-31T00:00:00.000Z"
}


Response:

{
  "success": true,
  "data": {
    "id": "uuid...",
    "category": "technical",
    "priority": "high",
    "suggested_actions": [
      "Diagnose issue",
      "Check resources"
   ]
  }
}

DELETE /api/tasks/:id

Permanently remove a task.

## 5. Database Schema

The project uses Supabase (PostgreSQL) with the following schema.

Table: tasks
| Column               | Type      | Description                               |
| -------------------- | --------- | ----------------------------------------- |
| `id`                 | UUID      | Primary key                               |
| `title`              | Text      | Task headline                             |
| `description`        | Text      | Detailed info                             |
| `category`           | Text      | Auto-detected (finance, scheduling, etc.) |
| `priority`           | Text      | Auto-detected (high, medium, low)         |
| `status`             | Text      | pending, in_progress, completed           |
| `assigned_to`        | Text      | Person responsible                        |
| `due_date`           | Timestamp | Deadline                                  |
| `extracted_entities` | JSONB     | Dates, names parsed from text             |
| `suggested_actions`  | JSONB     | Action items based on category            |



## 6. Screenshots

![home_screen](https://github.com/user-attachments/assets/4ced1907-94dc-4dc1-94d4-92448120262c) 

![task_entry_form](https://github.com/user-attachments/assets/0be0a452-ef7d-473a-9cb9-e82c9af05952)

![date_picker](https://github.com/user-attachments/assets/8648d18b-b298-4632-8fa2-41d7bedeb133)

![filter_one](https://github.com/user-attachments/assets/1c7feb8f-6162-4c49-ae0c-5b976305dd15)

![filter_two](https://github.com/user-attachments/assets/cc495ce3-62d5-4dea-b19a-6f888866fc5b)

![search_results](https://github.com/user-attachments/assets/ca374c32-bfb0-4dca-b6c7-658a87362df5)

## 7. Architecture Decisions
* **Monorepo Structure:** Backend and frontend are kept in a single repository for easier review and shared context.
* **Controller–Service Pattern (Backend):** Business logic (auto-classification) is separated from route handlers for modularity and testability.
* **Riverpod (Flutter):** Chosen for compile-time safety and clean async state handling without boilerplate.
* **Keyword Heuristics:** Deterministic keyword matching is used instead of an LLM to ensure speed, reliability, and zero operating cost.

## 8. What I’d Improve
Given more time, I would implement:
* **Authentication:** Secure APIs using Supabase Auth (JWT validation) so users only access their own tasks.
* **Real-time Updates:** Use Supabase subscriptions to push updates instantly to the mobile app.
* **Offline Mode:** Implement local caching (Hive or SQLite) with background sync.
* **Unit Testing:** Expand test coverage for Flutter widgets and backend integration tests.
