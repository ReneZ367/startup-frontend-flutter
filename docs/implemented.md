# Implementation summary

Audit of `lib/` and related files. Last updated after health check, delete account, settings links, and package imports.

## Layout

```
lib/
├── main.dart
├── app.dart
├── constants.dart
├── config/
│   ├── env.dart
│   ├── navigation/
│   │   └── app_navigation_config.dart
│   └── router/
│       └── app_router.dart
├── core/
│   ├── auth/
│   │   ├── auth_api.dart
│   │   ├── auth_service.dart
│   │   └── screens/
│   │       └── login_screen.dart
│   └── network/
│       ├── api.dart
│       ├── api_client.dart
│       └── health.dart
├── components/
│   └── navigation/
│       └── app_shell.dart
├── theme/
│   ├── app_theme.dart
│   ├── app_theme_extension.dart
│   └── theme_extensions.dart
└── features/
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

**Auth:** Login/logout, token in secure storage, auth state (`isLoggedIn`), startup validation via `auth/check`, router redirect by auth, 401/419 → logout. Token generation counter so a stale 401 does not clear a newly stored token.

**Networking:** Shared Dio client, base URL and `Accept: application/json`, interceptors (Bearer token, 401 handling), thin helpers `apiGet` / `apiPost` / etc.
**Health check:** `core/network/health.dart` exposes `checkBackendUp()` which calls the backend `/up` route (same host/scheme as API base URL); returns `true`/`false`, no auth; call from anywhere (e.g. splash, settings, test screen).

Details: [docs/core/auth.md](core/auth.md), [docs/core/networking.md](core/networking.md).

---

## Entry & app

| File        | Role                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `main.dart` | Async entry; `authService.init()`, `onUnauthorized = () => authService.logout()`, then `runApp(FountaApp)`.                                |
| `app.dart`  | `FountaApp`: `MaterialApp.router` with "Founta App", `theme: AppTheme.light`, `darkTheme: AppTheme.dark`, router from `createAppRouter()`. |

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

| File                                           | Role                                                                                                                              |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `config/router/app_router.dart`                | go_router; `refreshListenable: authService.isLoggedIn`, redirect by auth; routes: `/login`, shell with `/`, `/settings`, `/test`. |
| `config/navigation/app_navigation_config.dart` | `AppRoutes`, `AppNavigationType`, `NavItem`; `navItems` for shell (Home, Test, Settings; Login via redirect).                     |
| `components/navigation/app_shell.dart`         | Shell: drawer or bottom nav from config; drawer header uses `context.appTheme?.drawerHeader`.                                     |

---

## Features

| Feature  | Screen / API                                     | Status                                                                                                                                                  |
| -------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Home     | `features/home/screens/home_screen.dart`         | Uses `context.appSpacing`, `context.appTheme`, title + welcome card.                                                                                    |
| Settings | `features/settings/screens/settings_screen.dart` | Themed title + subtitle; **Logout**; **Delete account** (confirmation, then delete API + logout); **Privacy policy** and **Impressum** open in browser. |
|          | `features/settings/api/delete_account_api.dart`  | `apiDelete('user')` for account deletion.                                                                                                               |
| Testing  | `features/testing/screens/test_screen.dart`      | Backend status bar (green up / red down), polled every 3s; Fetch data + user card.                                                                      |
|          | `features/testing/api/test_api.dart`             | Test API (e.g. user/me).                                                                                                                                |

---

## Tests

| File                    | Role                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `test/widget_test.dart` | Smoke test: pumps `FountaApp`, expects "Home" once. No counter; matches current app. |

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
- **Smoke test** – Verifies app and shell load; no dead counter test.
- **Docs** – This file reflects current layout and theme.

**Suggested next (when needed)**

- **Env config** – Done. `lib/config/env.dart` provides `Env.apiBaseUrl` and `Env.webAppUrl` from `--dart-define`; `Constants` uses them for API, health, and web links. Add more keys in env.dart if needed.
- **Route registration** – If many features, register routes from a list or config so adding a feature = one entry.
- **Feature tests** – Add navigation or screen-level tests when flows become critical.
- **CI** – Run `flutter analyze` and `flutter test` on push/PR once the repo is shared.

---

## Summary

- **Done:** App entry, Material 3 + ThemeExtension theme, context theme helpers, **package imports** (`package:founta_app/...`) across lib; go_router + shell, config-driven nav (Home, Test, Settings); **core auth** (login/logout, token, auth/check, redirect, token generation); **shared networking** (Dio, api helpers, interceptors); **health check** (`health.dart`, `checkBackendUp()` for `/up`); Home, **Settings** (logout, delete account, Privacy policy & Impressum links), **Testing** (backend status bar + fetch data); **url_launcher** for external links; passing smoke test.
- **Not yet:** Deeper tests, CI.
