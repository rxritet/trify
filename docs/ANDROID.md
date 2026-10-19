# Trify для Android

Android — основная платформа Trify. Нативная часть находится только в `android/`, а общий интерфейс и логика — в `lib/`.

## Требования

- Flutter SDK с Dart `^3.13.4`;
- Android SDK, эмулятор или физическое устройство;
- для релизного AAB: установленный Android SDK Command-line Tools и принятые лицензии.

Проверить окружение:

```bash
flutter doctor
flutter devices
```

## Запуск и проверка

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Сборки

Debug APK для локальной проверки:

```bash
flutter build apk --debug
```

Release APK для прямой установки:

```bash
flutter build apk --release
```

Android App Bundle для Play Console:

```bash
flutter build appbundle --release
```

Flutter помещает результаты в `build/app/outputs/`. Эта папка намеренно не отслеживается Git: загрузите APK/AAB в GitHub Releases или другое хранилище релизов, а не в исходный код.

## Подпись и Firebase

`android/key.properties.example` показывает формат локального файла подписи. Не добавляйте `key.properties`, keystore-файлы или пароли в Git.

Конфигурационный `android/app/google-services.json` требуется для Firebase Android. Google-вход уже проверен в debug-сборке на эмуляторе. Перед публикацией добавьте SHA-1 настоящего release/upload-ключа и проверьте авторизацию в подписанной сборке.
