# CozyCards

iOS-приложение для изучения слов: чат с on-device моделью (Foundation Models) генерирует
карточки, которые копятся в библиотеке.

## Настройка после клона

Подпись у каждого разработчика своя и намеренно не лежит в git. Перед первой сборкой
скопируйте шаблон:

```
cp Local.xcconfig.example Local.xcconfig
```

Затем откройте `Local.xcconfig` и подставьте свои `DEVELOPMENT_TEAM` и
`PRODUCT_BUNDLE_IDENTIFIER`. Без этого шага Xcode не подпишет таргет.

`Local.xcconfig` подключён как `baseConfigurationReference` к Debug- и Release-конфигурациям
таргета, поэтому настройки подписи вынесены из `project.pbxproj` и вы больше не
перезаписываете их друг другу.

Важно: меняйте команду и bundle id **только в `Local.xcconfig`**. Правка в Xcode UI
(Signing & Capabilities) запишет значения обратно в `project.pbxproj` и вернёт конфликты.

## Требования

Xcode 27+, iOS 27 SDK. Модель работает только on-device (Apple Foundation Models),
без fallback на Private Cloud Compute.
