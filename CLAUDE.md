# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                        # Run app
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run a single test file
flutter analyze                    # Lint & static analysis (uses flutter_lints)
flutter gen-l10n                   # Regenerate lib/l10n/app_localizations*.dart after editing .arb files
```

There is no CI config in this repo — `flutter analyze` is the closest thing to a required gate before committing.

This directory is not a git repository (`git` commands won't work here); if the user asks you to commit, ask them how they want the repo initialized/tracked first.

## Three-repo architecture

This Flutter app is one of three repos that make up EduNova. Backend and admin dashboard live in sibling directories, not in this repo:

```
Flutter app (this repo): /Users/reyad/Documents/Programming/Flutter/edunova
Go backend:               /Users/reyad/Documents/Programming/Go/edunova-server
Next.js admin dashboard:  /Users/reyad/Documents/Programming/NextJs/edunova-admin
```

- Go server: `cd .../edunova-server && go run .` — Neon PostgreSQL, auto-migration on startup, `.env` needs `DATABASE_URL`, `PORT`, `JWT_SECRET`, `FCM_SERVER_KEY`.
- Next.js admin: `cd .../edunova-admin && npm run dev` — separate admin/user auth token storage in `src/lib/auth.ts`, API client in `src/lib/api.ts`.
- Login/register in this Flutter app hit the Go server for real — there is no mock/offline auth mode.
- When a task touches API contracts (new endpoint, changed response shape), check whether the Go server and/or Next.js admin need matching changes — they are not auto-synced.

## Architecture (this repo)

**Feature-first structure.** Each feature under `lib/features/<name>/` typically has `screens/`, `services/`, and sometimes `models/`, `providers/`. Cross-cutting code lives in `lib/shared/` (widgets, services, constants) and `lib/app/` (routing, theming).

- **State management:** Riverpod, using the legacy `StateNotifierProvider` API (`package:flutter_riverpod/legacy.dart`), not the newer Notifier/AsyncNotifier codegen style. Follow this pattern for new state — see `lib/features/auth/providers/auth_provider.dart` for the canonical example (notifier class + state model + top-level provider).
- **Routing:** GoRouter, configured entirely in `lib/app/routes.dart` as a single `routerProvider`. Routes use explicit paths (not named-route navigation in app code), and complex payloads are passed via `state.extra` rather than serialized into the URL. Auth-gating and the "profile setup incomplete" redirect are both implemented in the router's top-level `redirect` callback — check there before adding a new protected/public route to `isPublicRoute`.
- **API access:** `lib/shared/services/api_client.dart` (`ApiClient`) is a thin wrapper around `http` with `get`/`post`/`put`, JSON encode/decode, bearer-token header injection, and a shared `ApiException`. Each feature's `services/*.dart` wraps `ApiClient` for its own endpoints rather than calling it directly from UI code. `ApiClient.baseUrl` branches on platform (`10.0.2.2` for Android emulator, `localhost` otherwise) — physical devices need this changed to a LAN/deployed URL.
- **Auth/session persistence:** `lib/shared/services/secure_storage_service.dart` persists the JWT and a flattened user record via `flutter_secure_storage`; `AuthNotifier.init()` in `auth_provider.dart` rehydrates state from it on app start, before the router is built.
- **Push notifications:** `lib/shared/services/notification_service.dart` wraps Firebase Messaging + `flutter_local_notifications`, initialized post-login/on-startup-if-authenticated in `main.dart`, and registers the FCM device token with the backend via `AuthNotifier.registerDeviceToken`.
- **Design tokens:** `AppColors`, `AppSpacing`, `AppTextStyles` in `lib/shared/constants/` — use these instead of hardcoded colors/spacing/text styles. `AppTextStyles` auto-switches to a Bengali-appropriate Google Font when the active locale is Bangla.
- **Themeing:** `lib/app/theme.dart` (`AppTheme.light` / `AppTheme.dark`) + `lib/app/theme_provider.dart` (`themeProvider`, a `StateNotifierProvider<ThemeNotifier, ThemeMode>`).
- **Shared widgets:** prefer `AppButton`, `AppTextField`, `AppScaffold`, `AppAppBar` from `lib/shared/widgets/` over raw Material widgets for consistency.
- **Localization:** ARB files in `lib/l10n/` (`app_en.arb`, `app_bn.arb` conceptually — generated output is `app_localizations_en.dart` / `app_localizations_bn.dart`). Access strings via `context.l10n.keyName` or `AppLocalizations.of(context).keyName`. Must run `flutter gen-l10n` after editing `.arb` source — generated files are committed, not gitignored-and-rebuilt.

## Backend data model (for context when features touch the API)

The Go backend exposes REST endpoints under `/api` (public/user) and `/api/admin` (JWT-gated, roles: `master_admin` > `admin` > `teacher`). Key domains: auth/users, courses, exams (+ questions/results), enrollments, a 5-level question bank hierarchy (Class → Subject → Book → Chapter → Topic → Question, with CSV bulk import and two-pass duplicate detection), finance (expenses/payments), batches, attendance/holidays, FCM device tokens, doubt resolution tickets, a smart calendar, daily lessons, and a parenting-hub articles/videos feed. Full endpoint-by-endpoint reference lives in `AGENTS.md` in this repo if you need exact paths/verbs.

The Next.js admin dashboard (`edunova-admin`) has one admin page and one typed API-client object per backend domain (e.g. `financeApi`, `batchApi`, `attendanceApi` in `src/lib/api.ts`) — if you add a backend domain, the existing ones show the expected shape for both the Flutter and Next.js sides.
