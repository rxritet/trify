# Проверки

| Изменение | Минимальная проверка |
| --- | --- |
| Документация и структура | ссылки, `git diff --check` |
| Dart-код | `dart format`, `flutter analyze` |
| Логика или интерфейс | `flutter test` и релевантный ручной сценарий |
| Android-конфигурация | `flutter build apk --debug`, если окружение готово |
| Web-конфигурация | `flutter build web --release`, если окружение готово |

Перед коммитом выполните `git status --short`. Не включайте `build/`, `.dart_tool/`, Gradle-кэши, `android/local.properties`, `android/key.properties` или файлы подписи.
