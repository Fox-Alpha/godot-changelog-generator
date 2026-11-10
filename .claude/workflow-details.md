# Git-Workflow – Details

> Quelle: Kopie von `claudeprojekte/.claude/workflow-details.md` (Projektsammlung).

> Nur bei Bedarf lesen. Ergänzt `workflow.md`.

## Release-Trailer

- Setzen: `git commit --trailer "Release: skip"` oder als letzte Zeile von Hand.
- Auslesen: `git log --format='%h %s %(trailers:key=Release,valueonly)'`

Bei jedem Commit prüfen, ob die Sichtbarkeit nach Typ passt. Typische Fälle für einen Trailer:

| Fall | Trailer |
|---|---|
| `Docs:` an der Nutzer-Doku (Anleitung, README, Hilfe), nicht an Entwickler-Doku oder Notizen | `Release: show` |
| `Cfg:`, die ändert, was Nutzer bekommen (z. B. Inhalt von Release-Archiven, Installationsweg) | `Release: show` |
| `Upd:` nur für die Versionsnummer eines Releases | `Release: skip` |
| `Fix:` an einem Fehler, der im selben, noch nicht veröffentlichten Stand entstanden ist | `Release: skip` |
| `Fix:`/`Upd:` ohne für Nutzer bemerkbare Wirkung (Tippfehler im Log, interne Texte) | `Release: skip` |

Was in einem Projekt als Nutzer-Doku gilt, legt die Projektdatei fest.

## Branches umbenennen

- Branches umbenennen: auf der Hosting-Plattform (z. B. GitHub) umbenennen, damit PRs und Schutzregeln mitwandern,
  danach lokal `git branch -m`, `git fetch --prune` und `git branch -u` auf jedem Rechner.
