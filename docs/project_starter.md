# Project starter

Steps to reach an initial state. These are not app-specific.

## Initial state steps

1. Create the Flutter project (e.g. `flutter create .` or with org/name).
2. Add the feature-based folder structure under `lib/` (see below).
3. Wire `main.dart` to the app shell (e.g. `MaterialApp` with router or initial route).
4. Add shared baseline: theme, constants, and a minimal set of shared components.
5. Add the first feature (e.g. splash or home) with at least one screen to verify navigation and shared usage.
6. (Optional) Add tooling: lint rules, scripts, and any CI that expects this structure.

---

## Feature-based structure

- **Features** live in a top-level `features/` folder under `lib/`.
- Each **feature** has its own folder (name = feature name, e.g. `auth`, `onboarding`, `dashboard`).
- Inside a feature: **screens**, and feature-specific **widgets**, **models**, **services**, etc., as needed.
- The **lowest / shared layer** in `lib/` is **not** feature-specific: e.g. `components/`, `constants/`, `theme/`, `utils/`. These are used across features.

---

## Folder structure (visual)

### `lib/` entries

These are the top-level items that should be under `lib/`:

- `config/`
- `features/`
- `main.dart`
- `models/`
- `screens/`
- `services/`
- `utils/`
- `widgets/`

```
lib/
├── main.dart
├── app.dart                    # optional: MaterialApp / app shell
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── widgets/            # feature-specific widgets
│   │   ├── models/
│   │   └── ...
│   │
│   ├── onboarding/
│   │   ├── screens/
│   │   │   └── welcome_screen.dart
│   │   └── ...
│   │
│   └── dashboard/
│       ├── screens/
│       │   └── home_screen.dart
│       └── ...
│
├── components/                 # shared UI building blocks
│   ├── buttons/
│   ├── inputs/
│   └── ...
│
├── constants/
│   ├── app_constants.dart
│   └── ...
│
├── theme/
│   ├── app_theme.dart
│   └── ...
│
└── utils/                      # shared helpers (optional)
    └── ...
```

**Summary:** `lib/` = app entry + `features/<feature>/` (screens, widgets, …) + shared layer (`components/`, `constants/`, `theme/`, `utils/`).
