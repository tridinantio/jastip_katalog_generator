# Flutter Engineering Playbook

Use this reference when the task needs detailed Flutter engineering judgment: architecture design, feature implementation, refactoring, code review, performance work, test strategy, dependency decisions, or platform integration.

## Source-Informed Principles

Current Flutter documentation emphasizes separation of concerns, typically split into UI and data layers. It recommends Views and ViewModels in the UI layer, Repositories and Services in the data layer, and an optional domain/use-case layer when logic is complex, duplicated, or combines multiple repositories.

The Flutter architecture recommendations strongly favor data/UI separation, repository pattern, ViewModel/View separation, dependency injection, unidirectional data flow, immutable models, and separate testing of architectural components. They treat `ChangeNotifier`/`Listenable` as a conditional state update mechanism rather than a universal answer, and recommend `go_router` for most Flutter applications.

Effective Dart's tone matters: consistency, brevity, readable APIs, meaningful naming, `dart format`, lints, and judgment over mechanical rule-following.

Performance guidance starts with avoiding common pitfalls: expensive work in `build`, oversized build methods, unnecessary high-level `setState`, missing `const`, non-lazy lists/grids, expensive opacity/clipping/saveLayer usage, intrinsic layout costs, and missed frame budgets.

Flutter testing guidance separates unit, widget, and integration tests. Most codebases should have many unit/widget tests and enough integration tests for important flows. Plugin calls should usually be wrapped behind app-owned APIs so unit/widget tests do not depend on native host code.

Flutter platform guidance supports official mobile, desktop, and web targets, and uses plugins, platform channels, Pigeon, FFI, and platform-specific embedding when Dart-only code is not enough. Release guidance includes platform deployment, flavors, code obfuscation, symbol handling, app size, and continuous delivery.

Feature-first clean architecture is useful when package-level boundaries improve modularity: multiple apps, reusable features, larger teams, monorepos, AI-assisted development, independently shippable features, or repeated cross-feature transformations.

## Analysis Workflow

Start by identifying:

- The product flow and user-visible behavior.
- The current architecture, state management, routing, dependency injection, code generation, lints, and test style.
- Existing feature boundaries and naming conventions.
- Which layer owns the change: presentation, view model/state, domain/use-case, repository, service, platform adapter, configuration, or tests.
- The narrowest implementation that solves the request without degrading maintainability.

For legacy code, avoid rewriting architecture first. Improve the touched path by introducing small boundaries, tests, and adapters that can coexist with current patterns.

For every feature that is more than a local UI adjustment, establish an implementation contract:

- Inputs and preconditions, including authorization and connectivity assumptions.
- Source of truth and cache/freshness expectations.
- State transitions for initial load, refresh, submit, success, empty, error, offline, and disposal when each applies.
- Side-effect owner for navigation, analytics, persistence, platform calls, and user feedback.
- Invariants that must remain true under retries, duplicate taps, stale responses, and app lifecycle interruption.
- The narrowest tests that prove the contract.

This contract is a reasoning aid, not necessarily a document the user needs to see.

## Architecture Decision Guide

Choose simple MVVM-style layering when the app is single-purpose or feature count is modest:

```text
lib/
  ui/
    core/
    <feature>/
      <feature>_screen.dart
      <feature>_view_model.dart
  data/
    repositories/
    services/
    models/
```

Add domain/use-cases when:

- A ViewModel is merging multiple repositories.
- Business logic is duplicated across ViewModels.
- A rule needs independent tests and a stable API.
- The logic should remain unchanged if UI or data source changes.

For stricter clean architecture, use:

```text
feature/
  domain/
    entities/
    repositories/
    use_cases/
  data/
    models/
    data_sources/
    repositories/
  presentation/
    pages/
    widgets/
    state/
```

For monorepos or reusable features, prefer package-level boundaries:

```text
apps/
features/
  auth/
    auth_domain/
    auth_data/
    auth_presentation/
shared/
```

Keep dependency direction explicit:

- Presentation reads domain state/contracts and emits user intents.
- Domain owns business rules and repository interfaces.
- Data implements repository interfaces and maps DTOs to domain models.
- Services/data sources own HTTP, database, cache, plugin, and platform details.
- Apps compose dependencies, routes, themes, localization, and environment configuration.

## SOLID in Flutter Terms

- Single Responsibility: split huge widgets, god ViewModels, mixed repository/service classes, and DTO/domain hybrids.
- Open/Closed: prefer composing strategies, mappers, validators, adapters, and use-cases over repeatedly editing central conditional blocks.
- Liskov Substitution: repository interfaces must have behavior that fakes, remote implementations, local implementations, and cached implementations can all honor.
- Interface Segregation: expose narrow contracts per feature/use case; avoid dumping every backend operation into one app-wide service.
- Dependency Inversion: depend on abstractions for repositories, clients, storage, analytics, auth, clock, UUID, connectivity, and platform plugins when tests or variants need control.

## State Management Judgment

Preserve the existing choice first. If choosing:

- Local `StatefulWidget` state: ephemeral UI state such as selected tab, controller lifecycle, animation, focus, and temporary form editing.
- `ValueNotifier`/`ChangeNotifier`: simple mutable state with small dependency needs.
- Provider: lightweight dependency injection and simple `ChangeNotifier` wiring.
- Riverpod: testable dependency graphs, async state, override-friendly providers, modular state, and compile/lint support when using generator/lints.
- Bloc/Cubit: explicit event/state flows, replayable business behavior, larger teams, and highly testable feature states.

Keep state immutable at the UI boundary where possible. Avoid having widgets mutate model objects directly.

## UI and UX Implementation

- Prefer small named widgets with `const` constructors over private helper methods when the UI is reusable or rebuild scope matters.
- Keep `build` methods free of network calls, disk reads, expensive parsing, sorting of large collections, and command side effects.
- Use `ListView.builder`, `GridView.builder`, slivers, pagination, caching, and image constraints for large collections.
- Make empty, loading, error, offline, permission denied, and retry states first-class UI.
- Avoid storing derived UI state when it can be computed cheaply and safely from source state.
- Check `context.mounted` after `await` before navigation, dialogs, snackbars, or context reads in widgets.
- Keep forms resilient: input formatters, validation timing, disabled submit while in-flight, duplicate-submit protection, focus/error handling, and server-side error mapping.
- Use app theming and design tokens already present; do not hardcode colors/styles unless the local codebase does.

## Data, API, and Offline Concerns

- Separate DTO/API models from domain models in large or volatile APIs.
- Parse at the edge. Validate nullability and enum fallbacks defensively.
- Centralize HTTP concerns such as auth headers, refresh tokens, retry policy, timeout, logging, error mapping, and cancellation when the stack supports it.
- Keep repositories responsible for cache, refresh, polling, merging local/remote sources, and domain-friendly errors.
- Prefer streams for continuously changing data and futures for one-shot operations.
- Make offline behavior explicit when relevant: stale data display, optimistic updates, conflict resolution, queued writes, and sync status.

For concurrent requests, choose a deliberate policy: latest-result-wins for search/filtering, serialize non-idempotent mutations, or deduplicate identical work. Associate results with request parameters or a request token when an older completion could overwrite newer state.

For paginated collections, keep page/cursor, terminal state, in-flight state, deduplication, refresh semantics, and error recovery together in the repository or state owner. Do not let a scroll callback become the hidden source of truth.

## Platform and Build Integration

- Wrap plugins and native channels behind app-owned interfaces before using them in core logic.
- Prefer Pigeon for structured, type-safe platform channel contracts when custom native APIs grow beyond a couple of simple method calls.
- For reusable native functionality, consider a package or federated plugin rather than embedding all platform code inside one app.
- Keep Android/iOS build changes minimal and documented in code or comments only when future maintainers need context.
- When touching permissions, background execution, notifications, deep links, app links, flavors, signing, or platform channels, verify both Dart and native configuration.
- Respect target platform differences for navigation, typography, haptics, safe areas, permissions, back handling, and web/desktop constraints.

## Security, Privacy, and Release Readiness

- Do not store secrets in the app binary, assets, git history, or generated configuration. Obfuscation is not encryption and does not protect secrets.
- Keep API keys, environment values, and flavor-specific configuration controlled through the repo's existing secure mechanism.
- Preserve crash symbol files and obfuscation maps when release builds use `--obfuscate` and `--split-debug-info`.
- Treat auth, payments, PII, location, notifications, media permissions, background services, and analytics as privacy-sensitive surfaces.
- Check release-mode behavior for tree shaking, minification, permissions, network security config, deep links, app links, and platform-specific entitlements.
- For CI/CD, prefer repeatable commands: dependency fetch, generated code, format, analyze, test, build, artifact signing, symbol upload, and store/deployment steps.
- Keep observability useful: structured logs where appropriate, crash/error reporting boundaries, user/session breadcrumbs without leaking sensitive data, and domain-specific error categories.

## Testing Matrix

Use unit tests for:

- Mappers, validators, use-cases, repositories with fake services, services with fake clients, state classes, Notifiers, Blocs/Cubits, ViewModels, and error mapping.

Use widget tests for:

- Rendering states, user interactions, form validation, navigation triggers, localization-dependent text, semantics-relevant widgets, and provider/bloc wiring.

Use integration tests for:

- Auth, checkout/payment, onboarding, permission flows, offline/sync, deep links, push notification entry points, and performance-sensitive journeys.

Test generated and async-heavy code by behavior, not implementation shape. Prefer fake repositories/services to brittle plugin mocks; if a plugin must be mocked, use the highest-level mockable API available.

## Performance Checklist

- Remove expensive work from `build`.
- Add `const` where meaningful.
- Split rebuild-heavy widgets at state boundaries.
- Prefer builders/slivers for long scrollables.
- Avoid unnecessary opacity, clipping, shader work, and intrinsic layout.
- Cache decoded/processed data outside build.
- Profile before and after non-trivial performance work.
- Consider startup, memory, app size, energy, scrolling, animation, and network latency separately.

Use DevTools in profile mode for native Flutter performance investigation; debug-mode frame timings are not release-representative. Inspect the Flutter frames chart and frame analysis for jank, Memory snapshots/retaining paths for leaks or bloat, and Network view for request timing or duplicate traffic. Use browser DevTools for web network performance.

## Review Checklist

Look for:

- Business logic inside widgets.
- Repositories depending on other repositories without a domain/use-case reason.
- UI depending on DTOs, database rows, raw JSON, platform SDK types, or HTTP exceptions.
- Missing loading/empty/error states.
- Async methods that update UI after disposal.
- Unbounded streams/subscriptions/controllers.
- State classes with hidden mutation or equality bugs.
- Build methods causing side effects.
- Route guards with race conditions.
- Missing localization or accessibility for user-facing UI.
- Tests that only verify calls and not behavior.
- Plugin calls that break unit/widget tests.
- Generated files not updated after model/provider changes.

## Verification Commands

Prefer repo-specific commands when available. Otherwise use the strongest applicable subset:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
flutter test test/path/to/target_test.dart
flutter test integration_test
flutter build apk --debug
flutter build ios --debug --no-codesign
```

On Windows PowerShell, run commands directly and avoid Unix-only shell assumptions.

For a reusable Dart/Flutter package, also confirm its public surface and layout: keep implementation under `lib/src`, tests under `test`, integration tests under `integration_test`, and run `dart pub publish --dry-run` only when publication readiness is in scope.

## Reference Links

- Flutter app architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter architecture recommendations: https://docs.flutter.dev/app-architecture/recommendations
- Flutter architecture case study: https://docs.flutter.dev/app-architecture/case-study
- Flutter testing overview: https://docs.flutter.dev/testing/overview
- Flutter plugin testing: https://docs.flutter.dev/testing/plugins-in-tests
- Flutter performance best practices: https://docs.flutter.dev/perf/best-practices
- Flutter DevTools Performance view: https://docs.flutter.dev/tools/devtools/performance
- Flutter DevTools Memory view: https://docs.flutter.dev/tools/devtools/memory
- Flutter DevTools Network view: https://docs.flutter.dev/tools/devtools/network
- Flutter platform integration: https://docs.flutter.dev/platform-integration
- Flutter platform channels: https://docs.flutter.dev/platform-integration/platform-channels
- Flutter deployment: https://docs.flutter.dev/deployment
- Flutter code obfuscation: https://docs.flutter.dev/deployment/obfuscate
- Effective Dart: https://dart.dev/effective-dart
- Dart package layout conventions: https://dart.dev/tools/pub/package-layout
- Riverpod providers: https://docs-v2.riverpod.dev/docs/concepts/providers
- Bloc tutorials and architecture examples: https://bloclibrary.dev/tutorials/flutter-todos/
- VGV Feature-First Clean Architecture: https://engineering.verygood.ventures/architecture/ffca/overview/
