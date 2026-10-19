# Контекст проекта

- Trify — одно Flutter-приложение для Android и web; общий код находится в `lib/`.
- `core/` содержит общие механизмы, а `features/auth` и `features/planner` — пользовательские сценарии.
- Локальные профили хранятся через SQLite на Android и `shared_preferences` в web.
- Google-пользователь синхронизирует планировщик с приватным документом Cloud Firestore; локальная копия остаётся резервом.
- Поиск мест использует Wikimedia REST API через слой `PlacesRepository`.
- Конфигурация и правила Firebase CLI лежат в `config/firebase/`.
- Основная документация: [архитектура](../../docs/ARCHITECTURE.md), [платформы](../../docs/platforms/), [дизайн](../../docs/product/design.md), [безопасность Firestore](../../docs/security/firestore.md).
- Перед публичным релизом нужно пересмотреть прототип локальной аутентификации, настроить постоянную release-подпись и выполнить проверку на устройстве.
