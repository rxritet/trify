# Trify

<p align="center">
  <img src="assets/branding/trify-avatar-concept-04.png" width="132" alt="Символ Trify: город и маршрут">
</p>

<p align="center"><strong>Путешествия в твоём ритме.</strong><br>Планируйте поездки, открывайте места и собирайте маршрут по дням.</p>

<p align="center">
  <a href="#запуск"><img src="https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="#платформы"><img src="https://img.shields.io/badge/platform-Android%20%7C%20Web-111413" alt="Android и web"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-FFB000" alt="MIT License"></a>
</p>

Trify — учебное Flutter-приложение для планирования путешествий. Проект поддерживает Android и web из единой кодовой базы: платформенные настройки расположены в `android/` и `web/`, а результаты сборок не хранятся в репозитории.

## Что уже работает

- Тёмная и светлая темы, адаптивная навигация для узких и широких экранов.
- Локальная регистрация и вход: SQLite на Android, `shared_preferences` в web.
- Google-вход через Firebase: web и Android.
- Приватная синхронизация планировщика в Cloud Firestore для Google-пользователей и локальная резервная копия.
- Создание поездок, дни маршрута, заметки, избранное и восстановление сохранённых данных.
- Поиск мест через русскоязычный Wikimedia REST API.
- 19 автоматизированных Flutter-тестов успешно выполнены 17 октября 2026 года.

## Платформы

| Платформа | Статус | Сборка | Подробнее |
| --- | --- | --- | --- |
| Android | Основная | APK / AAB | [Android](docs/ANDROID.md) |
| Web | Поддерживается | Статические файлы | [Web](docs/WEB.md) |

У Android и web общий Dart-код в `lib/`. Платформенные файлы не смешиваются с артефактами: `build/`, Gradle-кэши, локальные настройки Android и ключи подписи исключены через `.gitignore`.

## Интерфейс

<p align="center">
  <img src="assets/images/almaty.jpg" width="31%" alt="Алматы">
  <img src="assets/images/astana.jpg" width="31%" alt="Астана">
  <img src="assets/images/canyon.jpg" width="31%" alt="Каньон">
</p>

Визуальный язык Trify — графитовый фон, крупные фотографии и яркие сине-оранжевые акценты. Символ приложения — компактный город с маршрутом, без текста.

## Запуск

Требуется Flutter SDK с Dart `^3.13.4` и зависимости выбранной платформы.

```bash
flutter pub get
flutter analyze
flutter test
```

Android-устройство или эмулятор:

```bash
flutter run
```

Браузер:

```bash
flutter run -d chrome
```

Для поиска мест нужен интернет. Подробные команды и особенности каждой цели собраны в [Android](docs/ANDROID.md) и [Web](docs/WEB.md).

## Технологии

| Область | Решение |
| --- | --- |
| Приложение | Flutter, Dart, Material 3 |
| Состояние | `ChangeNotifier`, `InheritedNotifier` |
| Локальные данные | `sqflite` на Android, `shared_preferences` в web |
| Облачные данные и вход | Firebase Authentication, Cloud Firestore, Google Sign-In |
| Поиск мест | `http`, Wikimedia REST API |
| Тесты | `flutter_test` |

## Структура

```text
lib/        # тема, Firebase, авторизация и планировщик
android/    # Gradle, AndroidManifest и нативная интеграция
web/        # оболочка браузерного приложения
assets/     # изображения и брендовые материалы
docs/       # инструкции для каждой платформы
test/       # unit- и widget-тесты
```

## Важные ограничения

- Локальные email/password-аккаунты — прототип: они не создают Firebase Auth-пользователей автоматически. Перед публичным релизом необходимо пересмотреть модель аутентификации и хранение паролей.
- Firebase для Android настроен и Google-вход проверен на Android-эмуляторе 19 октября 2026 года. Для Play-релиза всё ещё нужна проверка входа с release/upload-подписью.
- Карты, уведомления, бронирования, платежи, AI-планирование и офлайн-карты пока не реализованы.
- Технический AAB без постоянного upload-ключа не является пакетом для публикации в Google Play.

## Документация

- [Руководство Android](docs/ANDROID.md)
- [Руководство Web](docs/WEB.md)
- [Описание дизайна](Trify/design.md)
- [План и границы MVP](Trify/plan.md)
- [Технические заметки для разработки](Trify/AGENTS.md)

## Лицензия

Проект распространяется по лицензии [MIT](LICENSE).
