# RaceDay API Endpoint Plan

## Legend
- **Public**: No authentication required
- **Any User**: Any authenticated user (Participant, Organiser, or Admin)
- **Participant**: Participant only
- **Organiser**: Organiser only
- **Admin**: Admin only

---

## 1. Authentication Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | /api/auth/register | Register a new user account. Users can sign up as Participant or Organiser. | Public | `{ "email": "user@example.com", "password": "SecurePass123!", "fullName": "John Doe", "role": "Participant" }` | **201 Created** - User created<br>**400 Bad Request** - Invalid data<br>**409 Conflict** - Email already exists |
| POST | /api/auth/login | Authenticate user and return JWT token. | Public | `{ "email": "user@example.com", "password": "SecurePass123!" }` | **200 OK** - Returns token and user info<br>**401 Unauthorized** - Invalid credentials |
| POST | /api/auth/logout | Logout current user. | Any User | None | **200 OK** - Logged out successfully |

---

## 2. Event Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/events | Get all events with optional filters (by date, location, type). | Public | None | **200 OK** - List of events |
| GET | /api/events/{id} | Get detailed information about a specific event including categories. | Public | None | **200 OK** - Event details<br>**404 Not Found** - Event doesn't exist |
| POST | /api/events | Create a new event. Only verified organisers can create events. | Organiser | `{ "name": "Cape Town Cycle Tour", "description": "World's largest cycle race", "eventDate": "2026-03-15", "location": "Cape Town", "distance": 109, "eventType": "Cycle", "maxParticipants": 35000 }` | **201 Created** - Event created<br>**400 Bad Request** - Invalid data<br>**403 Forbidden** - Not an organiser |
| PUT | /api/events/{id} | Update an existing event. Only the organiser who created the event can update it. | Organiser | `{ "name": "Updated Event", "description": "Updated description", "eventDate": "2026-03-16", "location": "Updated location", "distance": 110, "eventType": "Cycle", "maxParticipants": 36000, "status": "Closed" }` | **200 OK** - Updated event<br>**403 Forbidden** - Not the event owner<br>**404 Not Found** - Event doesn't exist |
| DELETE | /api/events/{id} | Delete an event. Only the organiser who created the event can delete it. | Organiser | None | **204 No Content** - Deleted successfully<br>**403 Forbidden** - Not the event owner<br>**404 Not Found** - Event doesn't exist |
| POST | /api/events/{id}/banner | Upload a banner image for the event. | Organiser | Multipart form data with `file` field | **200 OK** - Image uploaded<br>**400 Bad Request** - Invalid file |

---

## 3. Category Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/events/{eventId}/categories | Get all categories for a specific event. | Public | None | **200 OK** - List of categories |
| POST | /api/events/{eventId}/categories | Add a new category to an event. | Organiser | `{ "name": "Elite", "distance": 109, "entryFee": 500, "maxParticipants": 1000 }` | **201 Created** - Category added<br>**400 Bad Request** - Invalid data<br>**403 Forbidden** - Not event owner |
| PUT | /api/categories/{id} | Update an existing category. | Organiser | `{ "name": "Updated Category", "distance": 110, "entryFee": 600, "maxParticipants": 1200 }` | **200 OK** - Updated category<br>**404 Not Found** - Category doesn't exist |
| DELETE | /api/categories/{id} | Delete a category. Cannot delete if participants are enrolled. | Organiser | None | **204 No Content** - Deleted successfully<br>**409 Conflict** - Has enrolments<br>**404 Not Found** - Category doesn't exist |

---

## 4. Enrolment Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/enrolments | Get current participant's enrolments with event details. | Participant | None | **200 OK** - List of enrolments |
| POST | /api/events/{eventId}/enrol | Enrol in an event by selecting a category. | Participant | `{ "categoryId": 1, "notes": "Travelling from Johannesburg" }` | **201 Created** - Enrolment created<br>**400 Bad Request** - Invalid category<br>**409 Conflict** - Already enrolled |
| PUT | /api/enrolments/{id}/status | Update enrolment status (Approve/Reject). Only the event organiser can do this. | Organiser | `{ "status": "Approved", "notes": "Medical clearance received" }` | **200 OK** - Status updated<br>**403 Forbidden** - Not event organiser<br>**404 Not Found** - Enrolment doesn't exist |
| DELETE | /api/enrolments/{id} | Cancel enrolment. Only the participant can cancel their own enrolment. | Participant | None | **204 No Content** - Cancelled successfully<br>**403 Forbidden** - Not the participant<br>**404 Not Found** - Enrolment doesn't exist |
| POST | /api/enrolments/{id}/documents | Upload supporting documents for enrolment. | Participant | Multipart form data with `file` field | **200 OK** - Document uploaded<br>**400 Bad Request** - Invalid file |

---

## 5. Result Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/events/{eventId}/results | Get published results for an event. | Public | None | **200 OK** - List of results |
| GET | /api/participants/results | Get current participant's race history. | Participant | None | **200 OK** - Personal race history |
| POST | /api/events/{eventId}/results | Add results for participants. | Organiser | `{ "enrolmentId": 1, "finishTime": "05:45:30", "finishPosition": 1 }` | **201 Created** - Result added<br>**400 Bad Request** - Invalid data<br>**409 Conflict** - Result already exists |
| PUT | /api/results/{id} | Update a result. | Organiser | `{ "finishTime": "05:50:15", "finishPosition": 3 }` | **200 OK** - Result updated<br>**404 Not Found** - Result doesn't exist |
| POST | /api/events/{eventId}/publish | Publish results for an event. Makes results publicly visible. | Organiser | None | **200 OK** - Results published<br>**400 Bad Request** - No results to publish |

---

## 6. Admin Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/admin/users | Get all users in the system with role filtering. | Admin | None | **200 OK** - List of users |
| GET | /api/admin/users/{id} | Get detailed information about a specific user. | Admin | None | **200 OK** - User details<br>**404 Not Found** - User doesn't exist |
| PUT | /api/admin/users/{id}/status | Enable or disable a user account. | Admin | `{ "isActive": false }` | **200 OK** - Status updated<br>**404 Not Found** - User doesn't exist |
| GET | /api/admin/events | Get all events in the system. | Admin | None | **200 OK** - All events |
| GET | /api/admin/enrolments | Get all enrolments in the system with filtering. | Admin | None | **200 OK** - All enrolments |
| GET | /api/admin/reports | Generate system reports and analytics. | Admin | `{ "reportType": "MonthlySummary", "startDate": "2026-01-01", "endDate": "2026-01-31" }` | **200 OK** - Report data |

---

## 7. Dashboard Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/dashboard/organiser | Get organiser dashboard with event statistics. | Organiser | None | **200 OK** - Dashboard data with events, enrolments, pending approvals |
| GET | /api/dashboard/participant | Get participant dashboard with enrolments and upcoming races. | Participant | None | **200 OK** - Dashboard data with active enrolments, pending enrolments, upcoming races |

---

## 8. Profile Endpoints

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | /api/profile | Get current user's complete profile including role-specific information. | Any User | None | **200 OK** - Profile data |
| PUT | /api/profile | Update user profile information. | Any User | `{ "fullName": "John Smith", "email": "john.smith@example.com" }` | **200 OK** - Updated profile<br>**400 Bad Request** - Invalid data<br>**409 Conflict** - Email already taken |
| POST | /api/profile/picture | Upload profile picture. | Participant | Multipart form data with `file` field | **200 OK** - Image uploaded<br>**400 Bad Request** - Invalid file |
| PUT | /api/profile/password | Change user password. | Any User | `{ "currentPassword": "OldPass123!", "newPassword": "NewPass456!" }` | **200 OK** - Password updated<br>**401 Unauthorized** - Current password incorrect |

