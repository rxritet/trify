# Архитектура Trify

Trify — одно Flutter-приложение для Android и web. Платформы используют общую Dart-кодовую базу, а различия находятся только в адаптерах и конфигурации.

```text
main.dart
  ├── core/                 # Firebase, тема, общие виджеты и локальная база
  └── features/
      ├── auth/             # пользователь, local/Google-вход
      └── planner/          # поездки, места, заметки, избранное и синхронизация
```

## Поток данных

1. `main.dart` инициализирует Firebase, восстанавливает сессию и открывает `PlannerState`.
2. `PlannerState` управляет состоянием поездок, заметок и избранного.
3. `PlannerRepository` сохраняет локальную копию данных; после Google-входа `CloudPlannerStore` синхронизирует снимок с приватным документом Firestore.
4. `PlacesController` получает данные через `PlacesRepository`; рабочая реализация обращается к Wikimedia REST API.

## Платформенные границы

- `android/` — Gradle, манифест, launcher-иконки и Firebase-конфигурация Android.
- `web/` — HTML-оболочка браузерного приложения.
- У профиля используются платформенные реализации: SQLite через `sqflite` на Android и `shared_preferences` в web.

Подробности запуска находятся в `docs/platforms/`; эта схема описывает только уже существующую структуру.
