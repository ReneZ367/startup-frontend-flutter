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
| `lib/core/network/api_error.dart` | `parseApiError` – parses Laravel-style validation errors from `DioException`, returns user-friendly message. |

---

## Interceptors

- **Request** – Reads token from secure storage (`authTokenStorageKey`); if present, sets `Authorization: Bearer <token>` and `_tokenGeneration` (current counter) on the request. No token stored in request.
- **Error** – On 401 or 419: skip for path `login` (wrong credentials). Otherwise only clear token and call `onUnauthorized` when the request’s `_tokenGeneration` matches the current generation (avoids stale 401 wiping a new token). Then `bumpTokenGeneration()`.

---

## Token generation

Used so that a delayed 401 from an old request does not clear a newly stored token. See [auth.md](auth.md#token-generation-401-handling).

---

## Error message handling

API validation errors use a common format (Laravel-style):

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The provided credentials are incorrect."],
    "password": ["The password field is required."]
  }
}
```

When a request fails, Dio throws `DioException`. The response body is in `e.response?.data`.

**Parsing steps:**

1. Check `e is DioException`; otherwise use `e.toString()`.
2. Cast `e.response?.data` to `Map<String, dynamic>`.
3. If `errors` exists and is a map, iterate over its values (arrays of strings) and return the first message.
4. Else use `message` if present.
5. Else fall back to a generic message (e.g. `"Failed: ${e.response?.statusCode ?? e.type}"`).

**UI display:**

- For forms with multiple related fields (e.g. login email + password), show a **single shared error message** below the inputs, in `colorScheme.error`.
- For single-field forms (e.g. forgot password), use `InputDecoration.errorText` on the field.
- Clear the error when the user edits any relevant field.

Use the shared helper `parseApiError` from `lib/core/network/api_error.dart`:

```dart
import 'package:founta_app/core/network/api_error.dart';

// In catch block:
setState(() => _error = parseApiError(e, fallbackPrefix: 'Login failed'));
```

See `login_screen.dart`, `register_screen.dart`, and `forgot_password_screen.dart` for examples.

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
