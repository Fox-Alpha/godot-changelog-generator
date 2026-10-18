# godot-changelog-generator

Bash-Script (`generate_changelog.sh`) mit eingebettetem Python 3, das aus der Git-Historie einen Markdown-Changelog
erzeugt. Keine weiteren Abhängigkeiten außer Git, Bash und Python 3.

## Git-Workflow

@docs/dev/workflow.md

## Projekteinstellungen

- Commit-Sprache: Deutsch (die bisherige englische Historie bleibt unverändert)
- Standardbranch: `main`
- Quellordner: Repo-Wurzel
- Zusätze: keine

## Pflegehinweise

- Die Commit-Typen stehen an mehreren Stellen und müssen zusammen geändert werden:
  - `docs/dev/workflow.md`: Quelle der Typen, Kopie aus dem Multiplayer-Template, dort zuerst ändern
  - `docs/commit-types.md`: Nutzer-Doku mit Typen, Reihenfolge, Sichtbarkeit und alten Präfixen
  - `generate_changelog.sh`: `TYPE_ORDER`, `TYPE_ALIASES`, `VISIBLE_TYPES` und der Abschnitt „Inhalt“ in `usage()`
- Ändert sich der Workflow im Template, prüfen, ob `docs/commit-types.md` und das Script nachgezogen werden müssen.
- `docs/dev/` gehört nicht in die Release-Archive (`.gitattributes`), Nutzer-Doku liegt direkt in `docs/`.

## Sprache

- Antworten und Code-Kommentare auf Deutsch.
