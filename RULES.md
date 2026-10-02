# Code Generation Rules

These rules apply to every code change Claude (or any agent) makes in this repo. They exist to keep output at the size and shape a senior developer would actually ship — not to add process for its own sake. **These are referenced from CLAUDE.md and must be followed automatically, without being re-stated by the user.**

## 1. Minimum viable diff
- Write only the code the task requires. No speculative options, config flags, or abstractions for use cases that don't exist yet.
- Prefer extending/editing an existing file over creating a new one, unless the new concern genuinely belongs in its own file (new screen, new service, new widget reused in 2+ places).
- If a change can be 10 lines, don't let it become 100. Three similar lines of code beat a premature abstraction.

## 2. File size & structure
- Target: no single Dart file should casually grow past ~250–300 lines. Treat that as a signal to stop and split, not a hard ceiling to game by shrinking whitespace.
- A single file doing one job (one screen, one service, one widget) is fine even if long; a file doing five unrelated jobs is not — split by responsibility, not by line count.
- When a screen's `build()` method accumulates multiple distinct sections (header, list, form, card), extract each section into its own widget under `widgets/` for that feature (see existing `lib/features/*/widgets/` pattern, e.g. `home_suggested_batches_card.dart`) instead of nesting it all inline. Do this as you write the screen, not only after it's already bloated.
- Don't create a new folder/module/barrel file for a single class.

## 3. Widget reusability
- Before writing a new widget, check `lib/shared/widgets/` and the current feature's `widgets/` folder for something that already does the job — extend it with a parameter rather than duplicating it.
- Any UI fragment used in 2+ places (cards, list tiles, badges, empty states, loading/error states) must become a shared widget, not copy-pasted.
- Prefer `const` constructors wherever the widget tree allows it — it's both a reusability and a performance signal.
- Extract a widget when it has its own clear responsibility or local state, even if currently used once, when that keeps `build()` readable — but don't over-fragment trivial one-line widgets.

## 4. No unused scaffolding
- Don't generate empty `models/`, `providers/`, or `widgets/` folders "for later."
- Don't add TODOs, placeholder methods, or commented-out alternate implementations.
- Don't add error handling, try/catch, null checks, or fallback branches for states that cannot occur given the surrounding code — only guard real boundaries (user input, API responses, platform calls).

## 5. Flutter performance
- Use `const` constructors for every widget that can be const — this is the single highest-leverage, lowest-cost perf habit and should be automatic, not an afterthought.
- Scope `ConsumerWidget`/`Consumer`/`ref.watch` as narrowly as possible around the subtree that actually needs to rebuild; don't wrap an entire screen in a watch when only one child needs the value.
- Never put heavy work (parsing, filtering, sorting large lists, date formatting in a loop) inside `build()` — compute it in the notifier/service layer or memoize it.
- Use `ListView.builder`/`GridView.builder` (not `ListView(children: [...])`) for any list that can grow, and supply `itemExtent`/`cacheExtent` where the item size is fixed and known.
- Avoid unnecessary `setState` calls that rebuild more of the tree than needed — prefer scoping state to the smallest widget via Riverpod providers.
- Don't wrap widgets in extra `Container`/`Padding`/`SizedBox` layers that don't change layout — each avoidable layer is an avoidable rebuild cost.

## 6. Use modern Dart syntax — dot shorthands
- This project targets the latest Flutter/Dart SDK, which supports **dot shorthand syntax** (static-member/enum access inferred from context type, e.g. `Brightness.dark` written as `.dark` when the expected type is already known — in a parameter, assignment, switch case, or return position).
- Use dot shorthands in all new code wherever the context type makes the enum/static member unambiguous (e.g. `theme: .dark`, `mainAxisAlignment: .center`, `return .success(data)`), instead of writing the full type name out.
- When editing an existing file for any other reason, opportunistically convert nearby enum/static-member references in the lines you're already touching to dot shorthand — but don't go out and rewrite untouched parts of the file just for this. The migration should happen gradually, file by file, as files are naturally edited, not as a dedicated sweep.
- Don't use dot shorthand where it would hurt readability (e.g. the target type isn't clear from surrounding context) — correctness and clarity win over terseness.

## 7. Keep dependencies current
- When adding a new package to `pubspec.yaml`, check its latest stable version on pub.dev (via `WebFetch`/`WebSearch` or `flutter pub outdated`) instead of guessing or using a remembered version — pub.dev versions move fast and a stale guess can pull in a yanked or long-superseded release.
- Don't downgrade or pin an existing dependency without being asked.
- If a task surfaces an outdated package that's blocking something, flag it to the user rather than silently upgrading unrelated dependencies.

## 8. Follow existing patterns, don't invent new ones
- Match the state management, routing, API, and widget patterns already documented in `CLAUDE.md` (Riverpod `StateNotifierProvider`, GoRouter in `routes.dart`, `ApiClient` wrapper, `AppButton`/`AppTextField`/etc., `AppColors`/`AppSpacing`/`AppTextStyles`).
- If an existing helper, widget, or service already does what's needed, use it — don't rewrite a parallel version.

## 9. Comments
- Default to no comments. Code should read clearly from naming and structure.
- Only comment a genuinely non-obvious WHY (a workaround, a hidden constraint, a subtle invariant) — never a WHAT, and never a reference to "the current task" or a specific fix/issue.

## 10. Stop at the task boundary
- Don't refactor, rename, or "clean up" surrounding code that wasn't part of the request.
- Don't fix unrelated lints/bugs in the same diff unless asked — mention them instead.
- A bug fix doesn't need an accompanying refactor. A new screen doesn't need a new design-system component unless one doesn't already exist.

## 11. Before finishing
- Re-read the diff and ask: would a senior reviewer call any part of this unnecessary, oversized, or out of scope? If yes, cut it.
- Check file sizes of anything touched/created — split if a file has drifted past the ~250–300 line guideline from section 2.
- Run `flutter analyze` on touched files before considering the change done.
