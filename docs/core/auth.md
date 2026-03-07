# Core auth

Auth lives in `lib/core/auth/`: state, login/logout, token storage, and startup validation.

---

## Overview

- **AuthService** (`auth_service.dart`) – Single source of truth for “is the user logged in?” (`ValueNotifier<bool> isLoggedIn`). Exposes `init()`, `login()`, `logout()`.
- **AuthApi** (`auth_api.dart`) – Thin API layer: `login()`, `logout()` using the shared `api.dart` helpers.
- **Login screen** (`screens/login_screen.dart`) – Calls `authService.login()`; on success navigates to home.
- **Token** – Stored in secure storage under `authTokenStorageKey` (from `api_client.dart`). Read by the Dio request interceptor; written after login; cleared on logout or 401/419.

---

## Startup and redirect

- **main.dart** – `await authService.init()` before `runApp()`. `onUnauthorized = () => authService.logout()` so 401/419 trigger logout.
- **init()** – Reads token from storage. If present, calls `GET auth/check`; only sets `isLoggedIn = true` when the backend returns `{ "valid": true }`. Clears token on 401 or invalid response so expired tokens don’t show the main app.
- **Router** – `refreshListenable: authService.isLoggedIn`, redirect: not logged in → `/login`; logged in and on `/login` → home. Protected routes require login; only paths in `_publicPaths` (e.g. login) are allowed when not logged in.

---

## Token generation (401 handling)

To avoid a **stale 401** wiping a newly stored token (e.g. user logs in again, then a late 401 from an old request clears the new token and redirects back to login), we use a **token generation counter** instead of storing the token on the request.

- **Concept** – A single integer is incremented whenever the token is **written** (login) or **cleared** (logout, init clear, or interceptor clear). Each request carries the **current** generation in `options.extra['_tokenGeneration']` (no token is stored in the request).
- **On 401/419** – The error interceptor only clears storage and calls `onUnauthorized` when the failed request’s `_tokenGeneration` **matches** the current generation. If it doesn’t match (e.g. 401 from a request that used an old token), we ignore it and just reject the error.
- **Where we bump** – `bumpTokenGeneration()` is called: after writing the token in `AuthService.login()`; after clearing in `AuthService.logout()` and in `init()` when we delete an invalid token; and in the API client error interceptor when it clears the token.
- **Security** – Only an integer is attached to requests; the token is never put in `RequestOptions`, so logging or serializing request options does not expose the token.

See also: [networking.md](networking.md) for the API client and interceptors.
