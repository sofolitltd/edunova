# EduNova — Product Requirements Document

**Status:** Draft for review
**Scope:** `edunova` (Flutter app), `edunova-server` (Go backend), `edunova-admin` (Next.js admin)

---

## 1. Product Vision & Target User

EduNova is the app for an offline coaching center. The near-term goal is **not** a general edtech marketplace — it's a companion app for guardians whose children attend our physical batches, with online course delivery deferred to a later phase.

**Primary user: the guardian.** Most parents in our context are not tech-savvy. Every guardian-facing screen must be simple, guided, and low-choice — large touch targets, one clear action per screen, minimal simultaneous decisions.

**Secondary user: the student**, using the same account, for practice content (vocabulary, sentence-making, flashcards, learning games). This surface can and should feel more Gen-Z: playful, gamified, visually energetic — a deliberate tonal split from the guardian-facing dashboard, not an inconsistency.

**Core value proposition:** organized, always-visible **student progress** — results, percentage, trend, and areas needing improvement — so a guardian can see how their child is doing without asking the coaching center.

### Explicit non-goals (settled decisions — do not re-open without a new discussion)

1. **No separate guardian account/role.** One account per student (mobile number + password), operated by whichever family member uses the app. No guardian login, no multi-child account linking, no guardian/student role split. If a family has two children in our coaching, they get two separate accounts today.
2. **No Google/Gmail login.** Mobile number + password is the only supported auth method going forward. The existing Google auth path is to be removed, not just deprioritized.

---

## 2. Personas

| Persona | Who | What they need from the app |
|---|---|---|
| **Guardian** (primary) | Parent of an enrolled student, often first- or second-generation smartphone user | At-a-glance: is my child doing well? What's the schedule? Any notices? One or two taps to any answer. |
| **Student** (secondary, same login) | Class 3–8 student enrolled in an offline batch | Notes for their subjects, and short, game-like practice sessions (vocabulary, sentences, flashcards) scaled to their class. |
| **Coaching admin/teacher** (Next.js) | Staff running batches, marking attendance, entering results | Needs to get offline exam scores and attendance into the system with minimal friction — that data is what powers the guardian's progress view. |

---

## 3. Current-State Audit

Findings below come from a full read of the three codebases (not just file listings), with citations so each claim is independently checkable.

### 3.1 Auth & Onboarding

- **Registration** (`lib/features/auth/screens/register_screen.dart:26-50`, Go `RegisterRequest` in `models/models.go:36-40`) collects only **full name, mobile, password** — no class, no confirm-password field anywhere (client or server).
- **OTP verification exists but is disabled.** `auth_provider.dart:100-104` has `// TODO: Restore AuthFlow.registerOtp when OTP is re-enabled in backend`; Go's `handlers/auth.go:47-56` has the OTP step commented out and auto-verifies new users (`auth.go:58-63`).
- **Google/Gmail login is fully live**, not dead code: `POST /api/auth/google` → `GoogleAuth` (`handlers/auth.go:332-460`) verifies a Google ID token against `https://oauth2.googleapis.com/tokeninfo`, then collects a mobile number and creates/links a user, writing `google_id`/`email` DB columns not present on the `User` struct. Flutter has a `loginWithToken()` stub in `auth_provider.dart:238-266` with **zero callers** — no UI button exists for it today, but the backend path is live and reachable.
- **Login** (`login_screen.dart:59-72`) is already mobile + password — matches the target. A passwordless OTP-login path also exists (`handlers/auth.go:462-560`, `POST /api/otp-login`).
- **Profile-setup** (`profile_setup_screen.dart:22-37`, shown when `!user.isProfileComplete`) only collects **gender, religion, class (3–8), shift, school**. It does **not** collect family info or address at onboarding — those fields exist on the backend `User` model already (`father_name/mobile`, `mother_name/mobile`, `notification_mobile`, `address` — `models/models.go:7-26`) but only surface later, in a separate "Edit Profile → Family" tab (`edit_profile_screen.dart:391-463`), not in the guided first-run flow.

### 3.2 Home Page, Results & Progress

- **No aggregate progress system exists anywhere** — Flutter, Go, or the Next.js admin. Confirmed via repo-wide search for result/progress/performance/improvement/analytics across all three codebases.
- The closest analog is **`student_transitions`** (`handlers/transitions.go`): a student self-reports a GPA + subject list + notes for a class-to-class promotion, and the backend buckets it into canned Bangla feedback tiers (`high_performer` / `good` / `needs_improvement` / `struggling`, `transitions.go:41-115`). This is manually entered, once-a-year, and has **no admin authoring UI** in Next.js — `src/app/admin/transitions/page.tsx` is read-only, `transitionApi` (`src/lib/api.ts:1242-1245`) only exposes `getTransitions`.
- **`exam_results`** (Go) stores raw score per exam (`ExamResult`, `models/admin.go:141-150`) with no computed percentage, no subject breakdown, no trend over time.
- **The Next.js admin has no way to enter per-student offline exam scores at all.** `src/app/admin/exams/page.tsx` only builds MCQ live-quiz exams (question + 4 options + correct answer, "Go Live" toggle) — there's no score-entry form for offline, paper-based exams, which is how most coaching-center testing actually works.
- `profile_tab.dart:136-141`'s stat cards (`'89%' avgScore`, `'48' examsTaken`, `'12' courses`) are **hardcoded mock values**, not computed from any real API call.
- **Home tab today** (`home_tab.dart`) has: greeting header, search bar, a 4-item quick-access row (Live Exams / Notes / Daily Learning / Transition), then three separate horizontally-scrolling course carousels (free / offline / online), a "see all courses" banner, and a Parenting Hub banner. **No routine/schedule, no notifications preview, no results/progress section, no notes preview** are integrated into this screen — the pieces the new home page needs either live in other tabs or don't exist.

### 3.3 Offline Batches, Routine & Attendance

- **`Batch`** (Go `models/admin.go:494-504`, Next.js `Batch` type `src/lib/api.ts:373-383`) has only: course link, name, a **free-text `schedule` string**, max students, status. No structured days/times/subjects/rooms — an admin literally types "Mon-Wed-Fri 8:00 AM" into one field.
- **Batches and attendance are entirely admin-only.** Every batch/attendance route is under the Go `admin`/`secured` group (`routes/routes.go:98, 152-165`) — there is no student-facing endpoint for either. A student can't even see their own batch's schedule indirectly: `GetUserEnrollments` (`auth.go:239-271`) joins the `batches` table but the query doesn't select the `schedule` column at all.
- The one guardian-facing touchpoint tied to attendance is a **push notification on "present" status only** (`sendAttendanceNotification`, `handlers/attendance.go:256-329`) — absences don't notify. The code that tries to route the notification to a "parent's own account" via `father_mobile`/`mother_mobile` has a real bug: it scans a single `id` column into a `[]int` slice destination (`attendance.go:280`), which will error and fall through — so that lookup never actually works today.

### 3.4 Interactive Practice (Vocabulary / Flashcards / Sentence-Making / Games)

- **`daily_content`** (Go `models/admin.go:536-547`, Flutter `lib/features/daily_content/`) is the only practice-adjacent feature that exists, and it is **passive reading content**, not interactive practice: a title/body/optional-answer shown in a bottom sheet. Content types are `vocabulary | math | science | news`.
- `class_level` on `daily_content` is a **tag for filtering**, not a difficulty tier — there's no difficulty concept independent of class, and no progression within a class. Flutter's `daily_content_service.dart` doesn't even pass a class filter to the API today — filtering happens entirely server-side based on the logged-in user's `student_class`.
- The "streak" (🔥 counter, `UserGetDailyStreak`, `handlers/daily_content.go:270-304`) is actually a **lifetime distinct-content-viewed counter**, not a real consecutive-day streak — there's no streak-break logic.
- **Zero flashcards, zero sentence-construction exercises, zero game mechanics (points, levels, badges) exist anywhere** in Flutter or Go — confirmed by repo-wide grep for "flashcard," "sentence," "game." This entire product pillar is greenfield.

### 3.5 Notes (subject-wise)

- `lib/features/notes/` + `handlers/notes.go` already implement subject-wise notes filtered by class (3–8, auto-selected from the student's profile) and subject. This is functionally close to what's needed — the earlier bug-fix session in this same app already resolved a data-loss bug (seed data wiping admin-created notes on every server restart) and a missing-auth-token bug (note detail screen). Two known follow-ups from that session, still open:
  - Some existing user accounts have malformed `student_class` values (`"one"`, `"Class 4"`, `""`) instead of `"3"`–`"8"`, which silently hides all class-filtered notes/content from those specific accounts.
  - The admin note-creation form's subject list is in Bengali (`গণিত`, `বিজ্ঞান`, ...) while the Flutter app's subject filter chips are in English (`Math`, `Science`, ...) — an exact-string mismatch that hides admin-created notes whenever a guardian/student taps a subject filter.

### 3.6 Guardian as an Actor

- **Zero guardian role/table/session exists anywhere** — no `role` column on `users` at all, confirmed by repo-wide grep for "guardian." Given the settled decision (§1), this is not a gap; it's documented here so it's understood as intentional, not an oversight.
- Guardian data (father/mother name+mobile) already exists on the `User` model and even on the Next.js `User` API type (`src/lib/api.ts:390-400`) — but the admin Users list UI doesn't display any of it (`src/app/admin/users/page.tsx:121-226` only shows name/mobile/status/joined date). It does get captured during batch enrollment (`src/app/admin/batches/page.tsx:35, 267-296`), just not surfaced centrally.

### 3.7 Class-Level Data Model (cross-cutting risk)

Two inconsistent schemes coexist for "what class is this content for":

- **Free-text string, unvalidated**: `users.student_class`, `courses.class_level`, `exams.class_level`, `daily_content.class_level`, `notes.class_level` — no shared canonical list, no FK.
- **Structured hierarchy with real FKs**: only the question-bank subsystem (`classes` → `subjects` → `books` → `chapters` → `topics`, `models/admin.go:227-304`) enforces class as a normalized entity.

This isn't theoretical — a direct query of the live database during an earlier debugging session in this app found real user rows with `student_class = "one"`, `student_class = "Class 4"`, and `student_class = ""`. Any new class-scoped feature (progress dashboard, difficulty-tiered practice) that reads `student_class` inherits this risk unless it's cleaned up first.

### 3.8 Overall UI/UX Complexity

The current Flutter UI (home tab, course browsing) is visually polished — gradients, animations, dark mode, bilingual EN/BN — but dense: the home tab alone has a search bar, a 4-item icon row, three separate horizontal carousels, and two large banners; the courses screen layers free-text search with two dropdown filters over cards carrying 5+ data points each. There's no onboarding tutorial and no progressive disclosure. This reads as built for a comfortable, tech-savvy app user — it will need real simplification (fewer simultaneous choices, bigger touch targets, icon+label redundancy, guided flows) to work for the non-tech-savvy guardian persona this PRD targets. The practice/games surface (§3.4, once built) is the one place density and playfulness are appropriate.

---

## 4. Gap Analysis

| Feature area | Current state | Target | Verdict |
|---|---|---|---|
| Login | Mobile+password ✅, plus a live Google OAuth path | Mobile+password only | **Remove** Google auth path |
| Registration | Name, mobile, password only | + class, + confirm-password | **Extend** |
| Profile setup | Personal (partial) + academic only | Personal, academic, family, address — one guided flow | **Extend** |
| Home dashboard | Course carousels + quick-access icons, no unified progress/routine/notes view | Guardian-first dashboard: routine, notifications, results summary, notes, offered courses | **Rebuild** |
| Results/progress | No aggregate system; raw per-exam scores only; admin has no offline-score entry | Overall result, percentage, trend, areas of improvement, guardian-visible | **Build new** (Go schema + Next.js entry UI + Flutter dashboard) |
| Batches/routine | Free-text schedule string, admin-only | Structured schedule, visible to guardian | **Extend + expose** |
| Attendance | Admin-only, buggy parent-notification path | Guardian-visible history, working notifications | **Extend + fix** |
| Notes | Subject-wise, class-filtered, functional (recently bug-fixed) | Same, plus fix subject-language mismatch and `student_class` data quality | **Fix + keep** |
| Vocabulary/flashcards/sentence/games | Passive daily-content reading list only | Interactive, class-tiered (3–8), gamified practice | **Build new** |
| Guardian account model | N/A | Single shared login (no new role) | **Non-goal — no change** |
| Class-level data integrity | Free-text, unvalidated, already has bad data in production | Canonical 3–8 enum, backfilled | **Cleanup — prerequisite** |

---

## 5. Phased Roadmap

### MVP — Offline-first, guardian progress, mobile-only auth

**Flutter**
- Registration form: add class selector + confirm-password field.
- Expand profile-setup into a guided multi-section wizard: personal → academic → family → address, reusing the `User` fields that already exist server-side.
- Remove the Google sign-in surface (there is currently no visible button, but audit for any remaining references and remove the dead `loginWithToken` stub).
- Redesign the home tab into an organized guardian-first dashboard: routine/schedule card, notifications preview, results/progress summary card, notes preview, offered courses (filtered by the student's class) — replacing the current carousel-heavy layout.
- Simplify course browsing: reduce simultaneous filters/decisions on `courses_screen.dart`.

**Go backend**
- Remove `POST /api/auth/google` and `GoogleAuth` handler.
- Add a student-facing batch/routine read endpoint (today admin-only); include `schedule` in the `GetUserEnrollments` join.
- Design and build a results/progress data model and endpoints: aggregate percentage, per-subject breakdown, trend over time, "areas of improvement" — built on top of `exam_results` plus a new offline-score-entry table (since offline exams currently have no scoring path at all).
- Add a student-facing attendance-history endpoint.
- Fix the broken parent-notification lookup in `attendance.go:280` (slice/scalar scan bug) and extend notifications to cover absences, not just "present."
- Add validation + a one-time backfill migration for `student_class` (canonical `"3"`–`"8"` only).

**Next.js admin**
- Build a per-student offline exam score entry UI (currently missing entirely) — this is the data-entry counterpart that feeds the new Flutter results dashboard.
- Structure `Batch.schedule` into real day/time fields instead of free text.
- Surface guardian fields (father/mother name + mobile) on the Users admin list.
- Build a real results/progress authoring screen, generalizing the pattern already started (but not fully built out) by the read-only `transitions` page.
- Align the notes subject taxonomy with what the Flutter app's filter chips expect (or vice versa) to fix the current mismatch.

### Phase 2 — Interactive practice, gamified, class-tiered

- New data model: flashcards/vocabulary items (word, meaning, example sentence, class) and sentence-construction exercises — admin-authored in Next.js, class-filtered 3–8, following the existing hierarchy-taxonomy pattern.
- Flutter: new practice-session UI — flashcard swipe, sentence builder, vocabulary quiz/game — with real scoring, a genuine consecutive-day streak (replacing today's fake "lifetime distinct count"), and levels.
- Go: session/attempt tracking, real streak calculation, a point/level model that feeds into the MVP-phase progress dashboard (practice performance becomes part of "overall progress," not a separate silo).

### Phase 3 — Online course delivery

- Live/recorded online class delivery, building on the `type: "online"` field that already exists on the `Course` catalog model. Out of scope for detailed design in this document — noted here only so the MVP's data model doesn't need to be reworked later to accommodate it (e.g., keep `Course.type` as the switch between offline/online/free, as it already is).

---

## 6. Open Risks & Explicit Assumptions

- **Sibling accounts**: since there's no guardian account layer, a family with two enrolled children will need two separate app logins/credentials. Acceptable for MVP per the settled decision in §1, but worth confirming this is understood as a real limitation guardians will notice.
- **`student_class` data quality is a prerequisite, not a parallel workstream.** Building the progress dashboard or difficulty-tiered practice on top of unvalidated class data will silently break for any account with a malformed value, the same way it already silently broke notes/daily-content visibility for at least 3 real accounts found in production during an earlier debugging session.
- **Offline exam scoring is entirely new** — there is no existing admin workflow to digitize paper-based exam results today. This is likely the largest single build item in the MVP, since it's the direct data source for the headline "progress" feature.
- **Notification quota**: extending attendance notifications to cover absences (not just presence) roughly doubles notification volume from that source — confirm this is desired before building.
- **Subject taxonomy consistency**: notes currently mix Bengali (admin-authored) and English (Flutter filter chips) subject names. Recommend picking one language as canonical (likely Bengali, matching the rest of the app's content) before Phase 2 introduces more class/subject-tagged content types.
