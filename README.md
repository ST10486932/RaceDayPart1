# RaceDay - Event Management System

## Project Overview

RaceDay is a web-based event management platform designed specifically for the South African road running, walking, and cycling community. The system allows Event Organisers to create and manage events, while Participants can browse events, enter competitions, and track their personal performance history.

This repository contains the **planning and database design** for the RaceDay system (Part 1 of the Portfolio of Evidence).

---

## User Roles

### 1. Participant
- Register and manage personal profile
- Upload profile picture
- Browse and filter upcoming events
- View complete event information
- Enrol in events by selecting a category
- Track enrolment status (Pending/Approved/Rejected)
- View personal race history and results

### 2. Event Organiser
- Create, update, and delete events
- Upload event banner images
- Define event categories (age/distance groups)
- View all participant enrolments
- Approve or reject participant enrolments
- Capture participant finish times and positions
- Publish race results

### 3. Admin
- Log in securely (separate from registration page)
- Monitor all users, events, and enrolments
- View and manage user accounts
- Generate system reports and analytics
- Ensure platform security and efficiency

---

## Documentation

| Document | Description | Link |
|----------|-------------|------|
| **ERD Diagram** | Entity Relationship Diagram showing database structure | [View ERD](/docs/erd-diagram.png) |
| **API Endpoint Plan** | Complete RESTful API endpoint specifications | [View API Plan](/docs/api-endpoints.md) |
| **Database Script** | SQL script for creating and populating the database | [View SQL Script](/docs/database-script.sql) |

---

## CI/CD Status

![Validate Project Structure](https://github.com/ST10486932/RaceDayPart1/actions/workflows/validate.yml/badge.svg)

All validation checks passed successfully.

---

## Repository Structure
