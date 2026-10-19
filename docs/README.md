# Документация Trify

В `docs/` собраны материалы, которые не нужны для запуска Flutter-приложения, но помогают разрабатывать и выпускать его.

Инструкции и контекст для автоматизированных агентов находятся отдельно в `.github/agents/`.

```text
docs/
├── ARCHITECTURE.md      # фактическая структура приложения
├── TECHNICAL_DECISIONS.md # принятые технические решения
├── platforms/           # запуск, сборка и нюансы каждой платформы
│   ├── android.md
│   └── web.md
├── product/             # решение о продукте и дизайн
│   ├── design.md
│   └── roadmap.md
└── security/            # проверенные правила доступа
    └── firestore.md
```

| Нужно сделать | Документ |
| --- | --- |
| Запустить или собрать Android | [platforms/android.md](platforms/android.md) |
| Запустить или развернуть web | [platforms/web.md](platforms/web.md) |
| Понять слои и поток данных | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Узнать, почему выбраны текущие решения | [TECHNICAL_DECISIONS.md](TECHNICAL_DECISIONS.md) |
| Понять интерфейс и визуальный язык | [product/design.md](product/design.md) |
| Посмотреть MVP и будущие этапы | [product/roadmap.md](product/roadmap.md) |
| Проверить модель Firestore | [security/firestore.md](security/firestore.md) |
