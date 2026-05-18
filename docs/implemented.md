# Implementation summary

Audit of `lib/` and related files. Last updated after email verification gate, API error codes, and auth polling.

## Layout

```
lib/
├── main.dart
├── app.dart
├── constants.dart
├── enums/
│   └── api_error_code_enum.dart
├── config/
│   ├── env.dart
│   ├── navigation/
│   │   └── app_navigation_config.dart
│   └── router/
│       └── app_router.dart
├── core/
│   ├── auth/
│   │   ├── auth_api.dart
│   │   └── auth_service.dart
│   └── network/
│       ├── api.dart
│       ├── api_client.dart
│       ├── api_error.dart
│       └── health.dart
├── components/
│   └── navigation/
│       └── app_shell.dart
├── theme/
│   ├── app_theme.dart
│   ├── app_theme_extension.dart
│   └── theme_extensions.dart
└── features/
    ├── auth/
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       ├── forgot_password_screen.dart
    │       └── verify_email_screen.dart
    ├── home/
    │   └── screens/
    │       └── home_screen.dart
    ├── settings/
    │   ├── api/
    │   │   └── delete_account_api.dart
    │   └── screens/
    │       └── settings_screen.dart
    └── testing/
        ├── api/
        │   └── test_api.dart
        └── screens/
            └── test_screen.dart
```

---

## Core: auth and networking

**Auth:** Login/logout/register/forgot password; token in secure storage; **`isLoggedIn`** and **`isEmailVerified`** (`ValueNotifier`s). Startup: `auth/check` then **`GET user/account/email-verification`** to set `isEmailVerified`. Router: logged in but unverified → **`/verify-email`** only; verified → shell as usual. **403** with machine code `EMAIL_NOT_VERIFIED` → `onEmailNotVerified` in `main.dart` → `authService.notifyEmailNotVerified()` (session kept). **401/419** → logout (token generation counter still applies for stale 401). While logged in and unverified, **polling** every 3s re-fetches verification status until verified or logout.

**Auth API (high level):** `user/account/email-verification` (status), `email/verification-notification` (resend), plus existing login/register/logout/forgot-password paths. Use **paths without a leading slash** so Dio appends them to the API base URL path (e.g. `.../api/v1/`); a leading `/` on the path can make the request hit the **host root** and drop the `/api/v1/` segment.

**Networking:** Shared Dio client, base URL and `Accept: application/json`, interceptors (Bearer token, 403 email-not-verified hook, 401/419 handling), **`api_error.dart`** (`parseApiError`, **`parseKnownApiErrorCode`** for JSON `code` / `error_code` / `error`), thin helpers `apiGet` / `apiPost` / etc.

**Health check:** `core/network/health.dart` exposes `checkBackendUp()` which calls the backend `/up` route (same host/scheme as API base URL); returns `true`/`false`, no auth.

Details: [docs/core/auth.md](core/auth.md), [docs/core/networking.md](core/networking.md).

---

## Entry & app

| File        | Role                                                                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `main.dart` | `authService.init()`; `onUnauthorized = () => authService.logout()`; **`onEmailNotVerified`** → debug log + `notifyEmailNotVerified()`; `runApp(FlutterApp)`. |
| `app.dart`  | `FlutterApp`: `MaterialApp.router` with themes, `createAppRouter()`.                                                                |

---

## Config and constants

| File              | Role                                                                                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config/env.dart` | `Env`: build-time config from `--dart-define`. `apiBaseUrl` and `webAppUrl` (defaults: ddev API and web URLs). Use for dev/staging/prod without code changes. |
| `constants.dart`  | `Constants`: app-wide values. `baseUrl` is sourced from `Env.apiBaseUrl`; other consts (e.g. `webAppUrl`, policy URLs) live here.                             |

---

## Theme

| File                             | Role                                                                                                                                                                                         |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `theme/app_theme.dart`           | Builds `ThemeData` (Material 3, `ColorScheme.fromSeed`) and registers `AppThemeExtension` in `extensions`. Single `_seedColor` for branding; swap for tenant/API later.                      |
| `theme/app_theme_extension.dart` | `AppThemeExtension`: colors (primary, error, success, warning, drawerHeader), `AppSpacing` (xxs→xxl). `.light()` / `.dark()` factories from `ColorScheme`. Implements `copyWith` and `lerp`. |
| `theme/theme_extensions.dart`    | `BuildContext` extension: `context.appTheme` (nullable), `context.appSpacing` (never null, fallback to standard). Reduces boilerplate in screens.                                            |

---

## Routing & navigation

| File                                           | Role                                                                                                                                 |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `config/router/app_router.dart`                | go_router; **`Listenable.merge([isLoggedIn, isEmailVerified])`**; redirect: not logged in → public routes/login; **logged in + unverified → `/verify-email`**; verified user on `/verify-email` → home; shell: `/`, `/settings`, `/test`. |
| `config/navigation/app_navigation_config.dart` | **`AppRoutes`** includes `verifyEmail`; `navItems` for shell (Home, Test, Settings).                                                 |
| `components/navigation/app_shell.dart`         | Shell: drawer or bottom nav from config; drawer header uses `context.appTheme?.drawerHeader`.                                     |

---

## Features

| Feature  | Screen / API                                     | Status                                                                                                                                                  |
| -------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Auth     | `features/auth/screens/login_screen.dart`        | Login form, links to Register/Forgot Password.                                                                                                          |
|          | `features/auth/screens/register_screen.dart`     | Registration form (name, email, password, confirm).                                                                                                     |
|          | `features/auth/screens/forgot_password_screen.dart` | Forgot password form (email).                                                                                                                           |
|          | `features/auth/screens/verify_email_screen.dart` | Shown when logged in and email unverified: resend (`POST email/verification-notification`), manual check, **polling** handled in `AuthService`.      |
| Home     | `features/home/screens/home_screen.dart`         | Uses `context.appSpacing`, `context.appTheme`, title + welcome card.                                                                                    |
| Settings | `features/settings/screens/settings_screen.dart` | Themed title + subtitle; **Logout**; **Delete account** (confirmation, then delete API + logout); **Privacy policy** and **Impressum** open in browser. |
|          | `features/settings/api/delete_account_api.dart`  | `apiDelete('user')` for account deletion.                                                                                                               |
| Testing  | `features/testing/screens/test_screen.dart`      | Backend status bar (green up / red down), polled every 3s; Fetch data + user card.                                                                      |
|          | `features/testing/api/test_api.dart`             | Test API call to `user`.                                                                                                                                 |

---

## Tests

| File                                | Role                                                                                                                                         |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/widget_test.dart`             | Smoke test: sets `authService` logged-in + email verified, pumps `FutterApp`, `pumpAndSettle`, expects **at least one** `"Home"` (shell duplicates label). |
| `test/core/auth/auth_service_test.dart` | Auth state lifecycle tests: init (no token / valid token / invalid token), login token storage, email-not-verified handling, logout cleanup. |
| `test/core/auth/auth_api_test.dart` | Auth API contract tests: login/register payload shape and email verification status parsing/fallback behavior.                              |
| `test/core/network/api_client_test.dart` | Interceptor tests: Bearer injection, 401 handling with token cleanup, login-path 401 exception, 403 `EMAIL_NOT_VERIFIED` callback.         |
| `test/core/network/api_test.dart`   | Thin API helper tests for `apiGet` / `apiPost` / `apiPut` / `apiPatch` / `apiDelete` return values and request forwarding.               |
| `test/core/network/health_test.dart` | Health check tests for `/up` success/failure behavior.                                                                                      |
| `test/core/network/api_error_test.dart` | Error parsing tests for `parseKnownApiErrorCode` and `parseApiError`, including Laravel-style validation/error payload edge cases.         |
| `test/support/http_stub_adapter.dart` | Shared stub HTTP adapter used by core tests to drive deterministic Dio responses without real network calls.                               |

---

## Dependencies (relevant to lib)

- **go_router** – routing and shell.
- **dio** – shared HTTP client and interceptors (replaces direct `http` usage).
- **flutter_secure_storage** – token storage.
- **url_launcher** – open Privacy policy and Impressum URLs in external browser.
- Flutter SDK, Material; **theme** is app-defined (ThemeExtension).

---

## Improvements for fast-building & scaling

**Already in place**

- **ThemeExtension + single seed** – One place for tokens; tenant/brand = different `ThemeData`/seed.
- **Context extension** – `context.appTheme` / `context.appSpacing` so screens stay short and consistent.
- **Core tests** – Auth and networking behavior covered with deterministic adapter-based tests (service state, API contracts, interceptors, health and error parsing).
- **Docs** – This file, `docs/core/auth.md`, `docs/core/networking.md`.

**Suggested next (when needed)**

- **Env config** – Done. `lib/config/env.dart` provides `Env.apiBaseUrl` and `Env.webAppUrl` from `--dart-define`; `Constants` uses them for API, health, and web links. Add more keys in env.dart if needed.
- **Route registration** – If many features, register routes from a list or config so adding a feature = one entry.
- **Verify screen** – Optional **Log out** control if product wants users to switch accounts or leave a stuck unverified session without contacting support (not required if that flow is intentionally impossible).
- **Feature/UI tests** – Add navigation or screen-level tests when flows become critical.
- **CI** – Run `flutter analyze` and `flutter test` on push/PR once the repo is shared.

---

## Summary

- **Done:** App entry, Material 3 + ThemeExtension theme, context theme helpers, **package imports** (`package:flutter_app/...`) across lib; go_router + shell, config-driven nav (Home, Test, Settings); **core auth** (login/logout/register/forgot, token, auth/check, **`isEmailVerified`**, verify gate, **403 EMAIL_NOT_VERIFIED** hook, **3s polling** while unverified, resend + manual check); **shared networking** (Dio, `api_error` + **ApiErrorCodeEnum**, interceptors); **health check**; Home, **Settings** (logout, delete account, policy links), **Testing** (backend status + fetch); **url_launcher**; passing smoke and core tests. **Auth screens:** Login, Register, Forgot Password, **Verify email**.
- **Not yet:** CI (analyze + test on push/PR), broader feature/widget tests for critical navigation and screen flows.
