# Clinic API - Clinic Scheduling Management System

## 1. Overview
Clinic API is a specialized Backend API designed to automate doctor scheduling workflows and simplify patient appointment booking. The system is optimized for data processing and pre-configured for seamless integration with modern Frontend applications such as React, Vue, or mobile applications.

The primary objective of the project is to minimize the risk of data conflicts (double-booking) and enhance user experience through an automated email reminder system.

---

## 2. System Actors
* **Doctor:** Authorized to set up and update daily availability (Schedules) and manage the list of patients who have booked appointments.
* **Patient:** Search for doctors by specialty, find and register for open appointment slots, and track their personal appointment status.

---

## 3. Tech Stack & Architecture
* **Framework:** Ruby on Rails configured in API-only mode (`--api`) to eliminate unnecessary middleware, optimizing memory usage and request response times.
* **Database:** PostgreSQL (Production environment) and SQLite (Development environment).
* **Code Architecture:** Adheres to the Single Responsibility Principle, with a clear separation between Skinny Controllers, Service Objects, and Active Record Models.
* **Background Processing:** Integrated with Sidekiq or Active Job combined with Redis to maintain API response times under 50ms.

---

## 4. Database Schema
The system revolves around three core database tables:
1. **Users:** Handles user accounts and authorization. Contains fields: `email`, `password_digest`, `name`, and `role` (`:doctor` or `:patient`).
2. **Schedules:** Manages doctors' working hours. Contains fields: `user_id` (doctor), `date`, `start_time`, `end_time`.
3. **Appointments:** Manages clinical appointments. Associates `patient_id` and `schedule_id`, along with a status (`status`: `:pending`, `:confirmed`, `:cancelled`).

---

## 5. Core Business Logic
* **Authentication & Authorization (JWT):** The API is secured using JWT tokens attached to the HTTP Header (`Authorization: Bearer <token>`). The system implements Data Isolation (queries scoped strictly through `current_user`) to fully prevent ID tampering in URLs.
* **Anti Double-Booking:** Strictly guarded at two layers: A Unique Index on the `schedule_id` column at the Database level, and existence checks at the Active Record Model level.
* **Time Validations:** The end time must be after the start time; creating schedules or booking appointments in the past is strictly prohibited.
* **Background Jobs:** When an appointment status changes to `:confirmed`, a background worker is triggered to automatically send a reminder email to the patient exactly 24 hours before the appointment time.

---

## 6. Optimization & Error Handling
* **Anti N+1 Query Strategy:** Employs Eager Loading (using `.includes`) at the Service Object layer to batch data retrieval and minimize SQL query counts.
* **Global Rescue Network:** Unexpected runtime errors (e.g., Record Not Found) are centrally managed in `ApplicationController` using the `rescue_from` declaration.
# ClinicCare
