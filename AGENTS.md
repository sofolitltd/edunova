# AGENTS.md – OpenCode instructions

## Quick start

```bash
# Run app
flutter run

# Run tests
flutter test

# Run single test
flutter test test/widget_test.dart

# Lint & analyze
flutter analyze
flutter lint

# Regenerate localization files (after editing .arb)
flutter gen-l10n
```

## Project structure

Three-repo architecture: Flutter app, Go backend server, Next.js admin dashboard.

```
Flutter:  /Users/reyad/Documents/Programming/Flutter/edunova
Go:       /Users/reyad/Documents/Programming/Go/edunova-server
Next.js:  /Users/reyad/Documents/Programming/NextJs/edunova-admin
```

## Key conventions

- **State management:** Riverpod (`StateNotifierProvider`)
- **Routing:** GoRouter (no named routes, paths only)
- **Localization:** `context.l10n.keyName` or `AppLocalizations.of(context).keyName`
- **Fonts:** Google Fonts –  Google Sans (BN) – auto-switches via `AppTextStyles`
- **Design tokens:** `AppColors`, `AppSpacing`, `AppTextStyles` – all in `lib/shared/constants/`
- **Theme:** `themeProvider` (StateNotifierProvider<ThemeNotifier, ThemeMode>) in `lib/app/theme_provider.dart`
- **Custom widgets:** Use `AppButton`, `AppTextField`, `AppScaffold`, `AppAppBar` from `lib/shared/widgets/`

## Gotchas

- **Auth:** Login and register use real API calls to Go server.
- **Backend:** Go server lives in a separate repo at `/Users/reyad/Documents/Programming/Go/edunova-server`.
- **Localization must be regenerated** after editing `.arb` files (`flutter gen-l10n`).
- **Linter:** Uses `flutter_lints` – run `flutter analyze` before committing.
- **Test coverage:** Only one widget test exists; add more as features are built.
- **Theme:** Light and dark themes supported. Toggle via theme button (top-left on login, top-right trailing on register).
- **Database:** Neon PostgreSQL connection string in old docs is **not** used by this Flutter app.

## Backend (separate repo)

- **Location:** `/Users/reyad/Documents/Programming/Go/edunova-server`
- **Run:** `cd /Users/reyad/Documents/Programming/Go/edunova-server && go run .`
- **Build:** `go build -o edunova-server .`
- **Database:** Neon PostgreSQL, auto-migration on startup
- **Env:** `.env` file with `DATABASE_URL`, `PORT`, `JWT_SECRET`, `FCM_SERVER_KEY`

### Admin Roles

- `master_admin` — full access: manage admins, courses, exams, enrollments, hierarchy, question bank, profile
- `admin` — manage courses, exams, enrollments, hierarchy, question bank, profile (cannot manage other admins)
- `teacher` — manage courses, exams, hierarchy, question bank (restricted)

### Default Admins

- Master admin: `asifreyad1@gmail.com` / `12345678`

### Database Tables (24 total)

**Auth/Users:** `users` (11 ALTER columns for parent/academic fields), `otps`, `admin_users`
**Courses:** `courses` (13 ALTER columns including curriculum, features, gradient)
**Exams:** `exams`, `exam_questions`, `exam_results`
**Enrollments:** `enrollments`
**Question Bank:** `classes`, `subjects`, `books`, `chapters`, `topics`, `questions`, `question_imports`
**Finance:** `expenses`, `payments` (method, receipt, status, verified)
**Batches:** `batches`
**Attendance:** `attendance` (student_id, date, status, marked_by)
**Holidays:** `holidays` (date, reason)
**Device Tokens:** `device_tokens` (user_id, token, platform)
**Doubts:** `doubts` (student question, resolution, status, FCM notification)
**Calendar:** `calendar_events` (exam/holiday/class_test, auto-created, color)
**Lessons:** `lessons` (daily lesson feed for parents)
**Articles:** `articles` (parenting hub: tips, wellness, videos)

### API Endpoints

**Auth:** POST `/api/register`, `/api/login`, `/api/send-otp`, `/api/verify-otp`, `/api/resend-otp`
**User:** GET `/api/user`, PUT `/api/user/profile`, PUT `/api/change-password`, GET `/api/user/enrollments`, GET `/api/user/dashboard`
**Public:** GET `/api/courses`, `/api/courses/:id`, `/api/exams/:id/questions`, POST `/api/enrollments`

**Admin (require admin JWT):**
- Dashboard: GET `/api/admin/dashboard`
- Profile: GET/PUT `/api/admin/profile`, PUT `/api/admin/change-password`
- Users: GET/PUT/DELETE `/api/admin/users`
- Courses: GET/POST/PUT/DELETE `/api/admin/courses`
- Exams: GET/POST/PUT/DELETE `/api/admin/exams`, GET/POST/DELETE `/api/admin/exams/:id/questions`
- Enrollments: GET/PUT/DELETE `/api/admin/enrollments`

**Admin Management (master_admin only):**
- Admins: GET/POST `/api/admin/admins`, PUT `/api/admin/admins/:id/role`, DELETE `/api/admin/admins/:id`, PUT `/api/admin/admins/:id/reset-password`

**Finance:**
- Dashboard: GET `/api/admin/finance/stats`
- Expenses: GET/POST `/api/admin/expenses`, PUT/DELETE `/api/admin/expenses/:id`

**Batches:**
- Hierarchy: GET/POST/PUT/DELETE `/api/admin/batches`, GET `/api/admin/batches/stats`

**Attendance & Holidays:**
- Students: GET `/api/admin/students`
- Attendance: POST `/api/admin/attendance` (bulk mark), GET `/api/admin/attendance?date=YYYY-MM-DD`
- Report: GET `/api/admin/attendance/report?date=YYYY-MM-DD`
- Holidays: GET/POST `/api/admin/holidays`, DELETE `/api/admin/holidays/:id`

**Device Token (FCM):**
- Register: POST `/api/device-token` (user auth required)

**Notifications:**
- FCM push via Legacy HTTP API (free), triggered on attendance mark (parent notified if student present)
- Config: `FCM_SERVER_KEY` env var

**Doubt Resolution Tracker:**
- Student: POST `/api/doubts` (submit), GET `/api/doubts` (my doubts)
- Admin: GET/PUT `/api/admin/doubts`, PUT `/admin/doubts/:id/resolve`, PUT `/admin/doubts/:id/close`, GET `/admin/doubts/stats`

**Smart Calendar:**
- Admin: GET/POST/PUT/DELETE `/api/admin/calendar`
- User: GET `/api/calendar/upcoming`

**Lessons:**
- Admin: GET/POST/PUT/DELETE `/api/admin/lessons`, GET `/admin/lessons/today`
- User: GET `/api/lessons/today`

**Payments:**
- Admin: GET/POST `/api/admin/payments`, PUT `/admin/payments/:id/verify`, PUT `/admin/payments/:id/reject`, DELETE `/admin/payments/:id`

**Parenting Hub:**
- Admin: GET/POST/PUT/DELETE `/api/admin/articles`, PUT `/admin/articles/:id/toggle`
- User: GET `/api/articles`

**Question Bank (NEW):**
- Hierarchy: GET/POST/PUT/DELETE for `/api/admin/classes`, `/subjects`, `/books`, `/chapters`, `/topics`
- Bulk Hierarchy: POST `/api/admin/hierarchy/bulk` (multipart CSV file upload)
- Questions: GET/POST/PUT/DELETE `/api/admin/questions`, PUT `/questions/:id/status`
- Bulk: POST `/api/admin/questions/bulk` (multipart file upload)
- Stats: GET `/api/admin/questions/stats`
- Duplicate check: POST `/api/admin/questions/check-duplicate`
- Import history: GET `/api/admin/imports`

## Question Bank System

### Hierarchy: Class → Subject → Book → Chapter → Topic

Each level is a separate table with `id`, `name`, `name_bn`, `order_index`.
Demo data seeded: 2 classes (Class 10, Class 8), 3 subjects, 3 books, 5 chapters, 9 topics.

### Question Model

`questions` table fields:
- `class_id`, `subject_id`, `book_id`, `chapter_id`, `topic_id` (all nullable FK)
- `question_type`: mcq, short_answer, very_short_answer, fill_blank, true_false, matching, descriptive, creative, problem_solving
- `question_text`, `options` (JSONB for MCQ), `answer`, `explanation`
- `marks`, `difficulty` (easy/medium/hard), `tags` (text array), `source`, `source_page`, `language` (bn/en)
- `status`: draft → published → archived
- `created_by`, `reviewed_by` (admin_users FK)
- `version`, `usage_count`, `last_used_at`
- 14 indexes for query performance

### Bulk CSV Import

Template columns: `class,subject,book,chapter,topic,question_type,question,option_a,option_b,option_c,option_d,answer,explanation,marks,difficulty,tags`

Validation: required fields, hierarchy lookup (ILIKE), duplicate detection (exact + normalized text), row-level error reporting.

### Bulk CSV Import (Hierarchy)

Template columns: `class,class_bn,subject,subject_bn,book,book_bn,publisher,chapter,chapter_bn,topic,topic_bn`
One row = one full hierarchy path. Duplicates auto-skipped by name matching.

### Duplicate Detection

Two-pass approach:
1. Exact text match
2. Normalized text match (lowercase, remove punctuation, collapse whitespace)

No AI/semantic similarity — extensible for future.

## Admin Dashboard (Next.js)

- **Location:** `/Users/reyad/Documents/Programming/NextJs/edunova-admin`
- **Run:** `cd /Users/reyad/Documents/Programming/NextJs/edunova-admin && npm run dev`
- **Build:** `npm run build`

### Admin Pages (19 total)

- `/admin/dashboard` — Stats + charts
- `/admin/users` — User management
- `/admin/courses` — Course CRUD
- `/admin/batches` — Batch management per course (Morning/Evening/Weekend schedules) (NEW)
- `/admin/attendance` — Attendance management: mark daily, view report, manage holidays (NEW)
- `/admin/enrollments` — Enrollment management
- `/admin/exams` — Exam management
- `/admin/hierarchy` — Class/Subject/Book/Chapter/Topic management with drill-down UX + bulk CSV import (NEW)
- `/admin/question-bank` — Question list with search/filter/status (NEW)
- `/admin/question-bank/new` — Manual question entry form (NEW)
- `/admin/profile` — Admin profile + password change (NEW)
- `/admin/admins` — Admin management: create/edit/delete admins, role assignment (master_admin only) (NEW)
- `/admin/finance` — Financial dashboard: revenue, expenses, net profit, monthly charts (NEW)
- `/admin/expenses` — Expense management: CRUD, category filter, search (NEW)
- `/admin/doubts` — Doubt resolution tracker: student questions, resolve/close, stats (NEW)
- `/admin/calendar` — Smart calendar: monthly view, event CRUD, auto events, color legend (NEW)
- `/admin/lessons` — Lesson transparency: daily lessons, CRUD, course filter (NEW)
- `/admin/payments` — Digital fee payment: bkash/nagad/card, verify/reject, receipts (NEW)
- `/admin/articles` — Parenting hub: articles/videos, category filter, publish toggle (NEW)

### Public Pages

- `/` — Landing page
- `/courses` — Course listing
- `/courses/[id]` — Course details
- `/courses/[id]/enroll` — Enrollment checkout
- `/contact` — Contact page
- `/edu-masters` — Teacher profiles
- `/login` — User login
- `/register` — User registration
- `/verify-otp` — OTP verification
- `/forgot-password` — Password reset
- `/dashboard` — User dashboard (enrolled courses, stats) (NEW)
- `/profile` — User profile + password change (NEW)

### API Client

- `src/lib/api.ts` — `api` object (auth, users, courses, exams, enrollments, user profile/dashboard)
- `src/lib/api.ts` — `hierarchyApi` object (classes, subjects, books, chapters, topics, bulk import)
- `src/lib/api.ts` — `questionsApi` object (questions CRUD, bulk upload, stats)
- `src/lib/api.ts` — `financeApi` object (finance stats, expenses CRUD)
- `src/lib/api.ts` — `batchApi` object (batches CRUD, batch stats)
- `src/lib/api.ts` — `attendanceApi` object (students, attendance CRUD, report, holidays)
- `src/lib/api.ts` — `doubtApi` object (doubts CRUD, stats, resolve/close)
- `src/lib/api.ts` — `calendarApi` object (events CRUD, month filter)
- `src/lib/api.ts` — `lessonApi` object (lessons CRUD, today lessons)
- `src/lib/api.ts` — `paymentApi` object (payments CRUD, verify/reject)
- `src/lib/api.ts` — `articleApi` object (articles CRUD, toggle publish)
- `src/lib/auth.ts` — Admin + User token management (separate localStorage keys)

### Auth Helpers

- `src/lib/auth.ts` — Admin: `getToken`, `setToken`, `removeToken`, `isAuthenticated`
- `src/lib/auth.ts` — User: `getUserToken`, `setUserToken`, `removeUserToken`, `isUserAuthenticated`, `getStoredUser`, `setStoredUser`