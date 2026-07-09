# CozyCards

iOS-приложение для изучения слов: чат с on-device моделью (Foundation Models) генерирует
карточки, которые копятся в библиотеке.

## Настройка после клона

Подпись у каждого разработчика своя и намеренно не лежит в git. Перед первой сборкой:

```
cp Local.xcconfig.example Local.xcconfig
```

Затем открой `Local.xcconfig` и подставь свои `DEVELOPMENT_TEAM` и
`PRODUCT_BUNDLE_IDENTIFIER`. Без этого шага Xcode не подпишет таргет.

`Local.xcconfig` подключён как `baseConfigurationReference` к Debug- и Release-конфигурациям
таргета, поэтому в `project.pbxproj` настроек подписи больше нет и вы не перезаписываете
их друг другу.

Важно: меняй команду и bundle id **только в `Local.xcconfig`**. Если поправить их в
Xcode UI (Signing & Capabilities), Xcode запишет значения обратно в `project.pbxproj`
и конфликты вернутся.

## Требования

Xcode 26+, iOS 27 SDK. Модель работает только on-device (Apple Foundation Models),
fallback на Private Cloud Compute не используется.
