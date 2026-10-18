# godot-changelog-generator

Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist Add → Chg → Upd → Ref → Rem → Fix → Docs → Ren → Mov → Cfg → Fmt → sonstige.

## 2026-10-18

- Add: MIT-Lizenz [30cfd80](https://github.com/Fox-Alpha/godot-changelog-generator/commit/30cfd80)
- Add: Release-Notes mit -r/--release [c66f0b0](https://github.com/Fox-Alpha/godot-changelog-generator/commit/c66f0b0)
- Add: Option -V/--version mit Versionskonstante [5335992](https://github.com/Fox-Alpha/godot-changelog-generator/commit/5335992)
- Add: Überschreibschutz mit -f und Standardausgabe mit -o - [5fdee52](https://github.com/Fox-Alpha/godot-changelog-generator/commit/5fdee52)
- Add: Filter auf mehrere Pfade und Dateiendungen [f3a0a87](https://github.com/Fox-Alpha/godot-changelog-generator/commit/f3a0a87)
- Chg: Reihenfolge der Typen besser lesbar [b6c55d1](https://github.com/Fox-Alpha/godot-changelog-generator/commit/b6c55d1)
- Chg: Bereichslogik von -b, -s und -u neu aufgebaut [0220672](https://github.com/Fox-Alpha/godot-changelog-generator/commit/0220672)
- Chg: Merge-Commits im Changelog ausblenden [98953d0](https://github.com/Fox-Alpha/godot-changelog-generator/commit/98953d0)
- Chg: Typen und Reihenfolge nach dem neuen Git-Workflow [299d5a6](https://github.com/Fox-Alpha/godot-changelog-generator/commit/299d5a6)
- Upd: Version 2.1.0 [16a6f31](https://github.com/Fox-Alpha/godot-changelog-generator/commit/16a6f31)
- Upd: Hilfetext an die neue Parameterlogik angepasst [f2d740a](https://github.com/Fox-Alpha/godot-changelog-generator/commit/f2d740a)
- Rem: toten Code hinter dem ersten exit 0 [f6e8cd1](https://github.com/Fox-Alpha/godot-changelog-generator/commit/f6e8cd1)
- Fix: fehlende Leerzeilen nach Überschriften in der Ausgabe [2fe54d3](https://github.com/Fox-Alpha/godot-changelog-generator/commit/2fe54d3)
- Fix: BrokenPipeError bei -o - mit vorzeitig beendetem Leser [94accfb](https://github.com/Fox-Alpha/godot-changelog-generator/commit/94accfb)
- Fix: mehrzeilige Commit-Messages als ein Eintrag zusammengefasst [900a891](https://github.com/Fox-Alpha/godot-changelog-generator/commit/900a891)
- Fix: Commit-Links aus SSH-Remote-URLs fehlerhaft [b6e8626](https://github.com/Fox-Alpha/godot-changelog-generator/commit/b6e8626)
- Docs: Commit-Typen als eigene Nutzer-Doku [7cd79ce](https://github.com/Fox-Alpha/godot-changelog-generator/commit/7cd79ce)
- Docs: CHANGELOG.md für v2.1.0 neu erzeugt [ed5f6f8](https://github.com/Fox-Alpha/godot-changelog-generator/commit/ed5f6f8)
- Docs: Update-Plan auf die offenen Punkte gekürzt [390d21b](https://github.com/Fox-Alpha/godot-changelog-generator/commit/390d21b)
- Docs: CHANGELOG.md vor dem Release neu erzeugt [9ceabc1](https://github.com/Fox-Alpha/godot-changelog-generator/commit/9ceabc1)
- Docs: Teststand und offene Abschlusspunkte im Update-Plan [73d47d5](https://github.com/Fox-Alpha/godot-changelog-generator/commit/73d47d5)
- Docs: CHANGELOG.md mit dem Tool neu erzeugt [e8f4d94](https://github.com/Fox-Alpha/godot-changelog-generator/commit/e8f4d94)
- Docs: usage.md an die neue Parameterlogik angepasst [6ac92ae](https://github.com/Fox-Alpha/godot-changelog-generator/commit/6ac92ae)
- Docs: README an die neue Parameterlogik angepasst [3ee6953](https://github.com/Fox-Alpha/godot-changelog-generator/commit/3ee6953)
- Docs: Parameterkonzept im Update-Plan abgeschlossen [e5ba669](https://github.com/Fox-Alpha/godot-changelog-generator/commit/e5ba669)
- Docs: Pfade beider Rechner im Update-Plan [a1ba831](https://github.com/Fox-Alpha/godot-changelog-generator/commit/a1ba831)
- Docs: Wahl des Autordatums im Script begründet [ea02261](https://github.com/Fox-Alpha/godot-changelog-generator/commit/ea02261)
- Docs: Git-Workflow aus dem Multiplayer-Template übernommen [641b600](https://github.com/Fox-Alpha/godot-changelog-generator/commit/641b600)
- Cfg: Pflegehinweis zu den Commit-Typen in CLAUDE.md [e5de55c](https://github.com/Fox-Alpha/godot-changelog-generator/commit/e5de55c)
- Cfg: Entwickler-Doku docs/dev/ nicht in die Release-Archive [858c2df](https://github.com/Fox-Alpha/godot-changelog-generator/commit/858c2df)
- Cfg: .gitattributes für Release-Archive und Zeilenenden [92fb8b3](https://github.com/Fox-Alpha/godot-changelog-generator/commit/92fb8b3)
- Cfg: CLAUDE.md mit Projekteinstellungen angelegt [8c293db](https://github.com/Fox-Alpha/godot-changelog-generator/commit/8c293db)

## 2026-10-16

- Docs: Formatbeispiel der Release-Notes im Update-Plan [15c7283](https://github.com/Fox-Alpha/godot-changelog-generator/commit/15c7283)
- Docs: Überschreibschutz und git-cliff-Installation im Update-Plan [f7ac4fa](https://github.com/Fox-Alpha/godot-changelog-generator/commit/f7ac4fa)
- Docs: Update-Plan für die Anpassung an den neuen Git-Workflow [0829b22](https://github.com/Fox-Alpha/godot-changelog-generator/commit/0829b22)

## 2026-05-02

- Docs: restructure README, add CHANGELOG and docs/usage.md [b1e9897](https://github.com/Fox-Alpha/godot-changelog-generator/commit/b1e9897)

## 2026-05-01

- Add: README with full usage documentation [118cc27](https://github.com/Fox-Alpha/godot-changelog-generator/commit/118cc27)

## 2026-04-20

- Upd: use repo-root as base for default output path [c424039](https://github.com/Fox-Alpha/godot-changelog-generator/commit/c424039)
- Upd: add short flags, --help, and --title with repo+branch default [afa490c](https://github.com/Fox-Alpha/godot-changelog-generator/commit/afa490c)
- Upd: replace positional args with named flags (--path, --output, --branch, --since, --until) [c58a2a1](https://github.com/Fox-Alpha/godot-changelog-generator/commit/c58a2a1)
- Upd: support - as placeholder for all-files mode to allow custom output path [7b13819](https://github.com/Fox-Alpha/godot-changelog-generator/commit/7b13819)

## 2026-04-19

- Upd: support no-arg and directory modes, update commit type grouping [f8cc4a3](https://github.com/Fox-Alpha/godot-changelog-generator/commit/f8cc4a3)

## 2026-02-27

- Add: Changelog Generator Bash Script [5e0f9b2](https://github.com/Fox-Alpha/godot-changelog-generator/commit/5e0f9b2)
- Fix: CRLF -> LF [a9fb162](https://github.com/Fox-Alpha/godot-changelog-generator/commit/a9fb162)
