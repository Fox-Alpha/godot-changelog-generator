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

## Release-Trailer

Regeln im Workflow, Abschnitt „Release-Notes“. In diesem Repo:

- `Release: show`: `Docs:` an der Nutzer-Doku (`README.md`, `LICENSE`, `docs/*.md` ohne `docs/dev/`) und `Cfg:`,
  die den Inhalt der Release-Archive ändern (`.gitattributes`)
- `Release: skip`: `Upd: Version x.y.z` und Fixes an Fehlern aus dem noch nicht veröffentlichten Stand
- ohne Trailer, also intern: `CHANGELOG.md` neu erzeugt, `CLAUDE.md`, `docs/dev/`
- Den Trailer im selben Block wie `Co-Authored-By:` setzen, ohne Leerzeile dazwischen.

## Sprache

- Antworten und Code-Kommentare auf Deutsch.
