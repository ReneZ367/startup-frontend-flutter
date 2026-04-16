# startup-frontend-flutter

Mobile app frontend project built with Flutter and connected to a Laravel backend through a REST API.

## Overview

`startup-frontend-flutter` is a mobile application template focused on authentication, user state, and API-driven feature flows.

The app retrieves all relevant data from backend HTTP endpoints:

- Backend-Repository: [startup-backend-laravel](https://github.com/ReneZ367/startup-backend-laravel)

## Tech Stack

- **Flutter** (UI framework)
- **Dart** (programming language)
- **Dio** (HTTP client for REST API communication)
- **State management:** service-based approach with `ValueNotifier` (for example, centralized `AuthService` for auth state and email verification state)
- **go_router** (navigation and route guards)
- **flutter_secure_storage** (secure token storage)

## Architecture

The project follows a **Layered Architecture** with clear responsibilities:

- **Core Layer (`lib/core`)**
  - API client, interceptors, error handling
  - Auth service and auth API
- **Feature Layer (`lib/features`)**
  - Feature-specific screens and APIs
  - Domain separation (Auth, Home, Settings, Testing)
- **Config/Composition Layer (`lib/config`, `lib/app.dart`, `lib/main.dart`)**
  - Routing, environment configuration, app bootstrap

This structure supports maintainability, testable business logic, and clear separation between UI and networking concerns.

## API Integration

The app consumes a Laravel-based REST API through a centralized networking layer:

- Shared Dio client with request/response handling
- Token-based authentication
- Consistent API error parsing and handling

API base URLs are configured via `--dart-define` (see Installation).

## Project Structure

```text
lib/
├── app.dart
├── main.dart
├── config/
│   ├── env.dart
│   ├── navigation/
│   └── router/
├── core/
│   ├── auth/
│   └── network/
├── features/
│   ├── auth/
│   ├── home/
│   ├── settings/
│   └── testing/
└── theme/
```

## Installation

### Prerequisites

- Flutter SDK installed
- Dart SDK (included with Flutter)
- Android Studio or Xcode (depending on target platform)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Run the app locally

```bash
flutter run
```

## Development

### Static analysis

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

## Repository Purpose

This repository is a production-oriented Flutter frontend showcase that demonstrates integration with a Laravel backend, with focus on:

- clean API integration
- robust authentication flows
- clear project structure
- testable core logic
