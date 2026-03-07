# Shared API client and networking

Feature doc for the shared API layer (Dio client + interceptors + thin helpers).

---

## Context

- One **Dio** instance (`api_client.dart`) with base URL from `Constants.baseUrl`, default headers, and interceptors.
- **API helpers** (`api.dart`): `apiGet`, `apiPost`, `apiPut`, `apiDelete`, `apiPatch` – all use the shared client so feature code stays minimal.
- **Auth** and other features call these helpers (e.g. `apiPost('login', data)`); no duplicated URL or auth logic.

---

## Layout

| File | Role |
|------|------|
| `lib/core/network/api_client.dart` | Single `Dio` instance; base URL (trailing slash); headers `Content-Type` and `Accept: application/json`; timeouts; request interceptor (Bearer token from secure storage); error interceptor (401/419 + token generation check). |
| `lib/core/network/api.dart` | `apiGet`, `apiPost`, `apiPut`, `apiDelete`, `apiPatch` – path-only endpoints, return `response.data`. |

---

## Interceptors

- **Request** – Reads token from secure storage (`authTokenStorageKey`); if present, sets `Authorization: Bearer <token>` and `_tokenGeneration` (current counter) on the request. No token stored in request.
- **Error** – On 401 or 419: skip for path `login` (wrong credentials). Otherwise only clear token and call `onUnauthorized` when the request’s `_tokenGeneration` matches the current generation (avoids stale 401 wiping a new token). Then `bumpTokenGeneration()`.

---

## Token generation

Used so that a delayed 401 from an old request does not clear a newly stored token. See [auth.md](auth.md#token-generation-401-handling).

---

## Checklist (done)

| # | Step | Status |
|---|------|--------|
| 1 | Add dependencies: `dio`, `flutter_secure_storage` | [x] |
| 2 | Create `api_client.dart`: Dio, base URL, headers, timeout | [x] |
| 3 | Auth interceptor: attach Bearer when token exists | [x] |
| 4 | Error interceptor: 401/419 + generation check, `onUnauthorized` | [x] |
| 5 | Create `api.dart`: apiGet, apiPost, apiPut, apiDelete, apiPatch | [x] |
| 6 | Auth uses api helpers (AuthApi in core/auth) | [x] |
| 7 | Token stored after login; `onUnauthorized` wired in main; auth/check on startup | [x] |
