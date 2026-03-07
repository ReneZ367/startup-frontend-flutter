# Implementation summary

Audit of `lib/` and related files. Last updated after core auth and shared networking.

## Layout

```
lib/
├── main.dart
├── app.dart
├── constants.dart
├── config/
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
│       └── api_client.dart
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
    └── settings/
        └── screens/
            └── settings_screen.dart
```

---

## Core: auth and networking

**Auth:** Login/logout, token in secure storage, auth state (`isLoggedIn`), startup validation via `auth/check`, router redirect by auth, 401/419 → logout. Token generation counter so a stale 401 does not clear a newly stored token.

**Networking:** Shared Dio client, base URL and `Accept: application/json`, interceptors (Bearer token, 401 handling), thin helpers `apiGet` / `apiPost` / etc.

Details: [docs/core/auth.md](core/auth.md), [docs/core/networking.md](core/networking.md).

---

## Entry & app

| File        | Role                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `main.dart` | Async entry; `authService.init()`, `onUnauthorized = () => authService.logout()`, then `runApp(FountaApp)`.                               |
| `app.dart`  | `FountaApp`: `MaterialApp.router` with "Founta App", `theme: AppTheme.light`, `darkTheme: AppTheme.dark`, router from `createAppRouter()`. |

---

## Constants

| File             | Role                                                                                                                       |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `constants.dart` | `Constants`: abstract final class with static consts (e.g. `baseUrl`). Single place for app-wide values like API base URL. |

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
| `config/router/app_router.dart`                | go_router; `refreshListenable: authService.isLoggedIn`, redirect by auth; routes: `/login`, shell with `/`, `/settings`.              |
| `config/navigation/app_navigation_config.dart` | `AppRoutes`, `AppNavigationType`, `NavItem`; `navItems` for shell (Home, Settings; Login via redirect).                               |
| `components/navigation/app_shell.dart`         | Shell: drawer or bottom nav from config; drawer header uses `context.appTheme?.drawerHeader`.                                        |

---

## Features

| Feature  | Screen                                           | Status                                                                 |
| -------- | ------------------------------------------------ | --------------------------------------------------------------------- |
| Home     | `features/home/screens/home_screen.dart`         | Uses `context.appSpacing`, `context.appTheme`, title + welcome card.  |
| Settings | `features/settings/screens/settings_screen.dart` | Themed title + subtitle; Logout button (authService.logout(), go login). |

---

## Tests

| File                    | Role                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `test/widget_test.dart` | Smoke test: pumps `FountaApp`, expects "Home" once. No counter; matches current app. |

---

## Dependencies (relevant to lib)

- **go_router** – routing and shell.
- **dio** – shared HTTP client and interceptors.
- **flutter_secure_storage** – token storage.
- Flutter SDK, Material; **theme** is app-defined (ThemeExtension).

---

## Improvements for fast-building & scaling

**Already in place**

- **ThemeExtension + single seed** – One place for tokens; tenant/brand = different `ThemeData`/seed.
- **Context extension** – `context.appTheme` / `context.appSpacing` so screens stay short and consistent.
- **Smoke test** – Verifies app and shell load; no dead counter test.
- **Docs** – This file reflects current layout and theme.

**Suggested next (when needed)**

- **Env config** – e.g. `lib/config/env.dart` or `.env` (flutter_dotenv) for API base URL / flavor (dev, staging, prod). Add when you add a backend.
- **Route registration** – If many features, register routes from a list or config so adding a feature = one entry.
- **Feature tests** – Add navigation or screen-level tests when flows become critical.
- **CI** – Run `flutter analyze` and `flutter test` on push/PR once the repo is shared.

---

## Summary

- **Done:** App entry, Material 3 + ThemeExtension theme, context theme helpers, go_router + shell, config-driven nav, **core auth** (login/logout, token, auth/check, redirect, token generation), **shared networking** (Dio, api helpers, interceptors), Home and Settings, passing smoke test.
- **Not yet:** Env/config for API flavors, extra features, deeper tests, CI.
