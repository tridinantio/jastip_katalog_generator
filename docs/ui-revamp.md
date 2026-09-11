# Travel atelier UI

The app now uses an editorial travel identity: ivory surfaces, forest green trip tickets, terracotta accents, Fraunces headings, and Manrope body text. Fonts and their SIL Open Font Licenses are bundled locally; the interface does not need a font CDN or additional runtime packages.

## Design references

- [Privé Porter / The Skins Factory](https://www.theskinsfactory.com/prive-porter): premium retail presentation with clear inventory and buyer workflows.
- [Cosmos interface collection](https://www.cosmos.so/explore/ui-ux): a visual collection that puts imagery first.
- [Cosmos collections](https://help.cosmos.so/en/articles/11717938-collections-subcollections): clear organization of collected items.

These informed the visual direction; the implementation and artwork are original Flutter widgets and drawing code.

## Coverage

- Trip dashboard: currency ticket, shopping totals, purchase progress, recent products, and existing trip switcher.
- Collection: responsive image grid, search and filters, item editing and deletion menus.
- Buyers: trip totals, initials, and expandable purchase checklists.
- Settings: consistent cards, inputs, trip management, Excel export, backup and restore.
- Product form: editorial introduction, numbered sections, camera/gallery controls, pricing preview, and location inputs.
- Catalog: arched photo, category, product title, selling price, and original sharing/gallery controls. A fixed 360 × 640 design canvas preserves the 9:16 export; the existing capture pipeline outputs 1080 × 1920 pixels. Catalog artwork has fixed typography, while the surrounding app respects accessibility text scaling.
- Splash, dialogs, sheets, menus, buttons, and navigation share the same design system.
- At 840 logical pixels, navigation switches to a rail. The dashboard splits into columns when there is sufficient content width. Forms and detail pages cap their readable width.

Repositories, database schema, calculations, native service contracts, and stored user data retain their existing implementation.

## Verification and previews

```sh
flutter analyze
flutter test
flutter test test/ui/ui_revamp_test.dart --dart-define=UPDATE_UI_PREVIEWS=true
flutter build apk --debug
```

The UI tests exercise the production home navigation, buyer expansion, product search, filters, catalog route, and product form at 320, 390, and 1100 logical pixels, including 1.8× text scaling and empty collections. They use local fixtures and generated sample product illustrations, never customer data or network images.

The preview command writes actual Flutter captures to `build/ui-preview/`. They are review artifacts, not permanent golden baselines. Native camera, maps, gallery permissions, and the OS share sheet still require device smoke testing.
