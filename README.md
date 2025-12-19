# Smart Site Task Manager

A comprehensive task management application that automatically classifies and prioritizes tasks using intelligent content analysis. Built with a Node.js backend and a polished Flutter mobile interface.

## 1. Project Overview
This project solves the problem of manual task organization by using a "Smart Classification" engine. When a user creates a task (e.g., "Urgent meeting about budget"), the system automatically:
* [cite_start]**Detects Category:** Assigns categories like 'Finance' or 'Scheduling' based on keywords [cite: 70-76].
* [cite_start]**Assigns Priority:** Flags tasks as 'High' priority if urgent words are detected [cite: 79-81].
* [cite_start]**Suggests Actions:** Provides actionable steps relevant to the task type [cite: 88-93].

[cite_start]The goal was to build a production-ready "Hybrid" application demonstrating clean architecture, real-time database persistence, and a responsive mobile UI [cite: 30-35].

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
   
