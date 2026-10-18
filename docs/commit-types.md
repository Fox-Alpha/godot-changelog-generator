# Commit-Typen

Das Tool gliedert und filtert Commits nach dem Typ am Anfang der Betreffzeile. Diese Seite beschreibt die Typen, die
es erkennt, und wie sie in Changelog und Release-Notes erscheinen.

## Format

```text
<Typ>: <kurze Beschreibung>

- optionale Details als Liste
```

- Ausgewertet wird nur die erste Zeile der Message. Details im Body erscheinen weder im Changelog noch in den
  Release-Notes.
- Nach der Betreffzeile eine Leerzeile lassen, sonst zählt Git den Body zum Betreff.
- Ein Typ pro Commit. Braucht ein Commit mehrere Typen, gehört er aufgeteilt.
- Die Groß- und Kleinschreibung zählt: `Fix:` ist ein Typ, `fix:` nicht.

## Typen

| Typ | Bedeutung | Beispiel | Release-Notes |
|---|---|---|---|
| `Add:` | Neue Dateien, Funktionen oder Features | `Add: Inventarsystem für Spieler` | sichtbar |
| `Chg:` | Geänderte Logik, Struktur oder geändertes Verhalten | `Chg: Kollisionsbehandlung in eigene Funktionen aufgeteilt` | sichtbar |
| `Upd:` | Anpassung ohne neues Verhalten: Werte, Parameter, Versionen, Texte | `Upd: Sprungkraft von 400 auf 500` | sichtbar |
| `Ref:` | Refactoring ohne Verhaltensänderung | `Ref: Schadensberechnung in Hilfsfunktion ausgelagert` | intern |
| `Rem:` | Entfernen von Dateien oder Code | `Rem: ungenutzte Minimap-Variante` | sichtbar |
| `Fix:` | Fehlerbehebung | `Fix: Kollision an steilen Hängen nicht erkannt` | sichtbar |
| `Docs:` | Reine Dokumentationsänderung (Markdown, Kommentare ohne Codeänderung) | `Docs: Einrichtung im README ergänzt` | intern |
| `Ren:` | Umbenennen von Dateien, Ordnern, Branches oder Bezeichnern | `Ren: Ordner doc zu docs` | intern |
| `Mov:` | Verschieben von Dateien oder Code an einen anderen Ort | `Mov: Arbeitsnotizen nach docs/notes` | intern |
| `Cfg:` | Konfiguration und Tooling: Ignore-Dateien, Editor- und Projekteinstellungen, CI | `Cfg: Lint-Dateien ignorieren` | intern |
| `Fmt:` | Nur Formatierung und Linter-Korrekturen, keine inhaltliche Änderung | `Fmt: scenes/ui formatiert` | intern |

Commits ohne erkannten Typ erscheinen im Changelog als „sonstige“ und in den Release-Notes nicht.

### Abgrenzung in Zweifelsfällen

- `Upd:` oder `Chg:`? Verhält sich das Programm danach anders → `Chg:`. Nur ein Wert oder Text anders → `Upd:`.
- `Docs:` oder `Add:`? Neue Doku-Datei → `Docs:`. Der Typ beschreibt die Art der Änderung, nicht ob eine Datei neu ist.
- `Ren:` oder `Mov:`? Gleicher Ort, neuer Name → `Ren:`. Neuer Ort → `Mov:`. Beides → `Mov:`.
- `Fmt:` oder `Ref:`? Nur Leerzeichen, Einrückung, Zeilenumbrüche, Linter-Hinweise → `Fmt:`. Code umgebaut → `Ref:`.

## Reihenfolge

Im Changelog werden die Commits innerhalb eines Datums in dieser Reihenfolge sortiert, die Release-Notes sind in
derselben Reihenfolge gegliedert:

`Add` → `Chg` → `Upd` → `Ref` → `Rem` → `Fix` → `Docs` → `Ren` → `Mov` → `Cfg` → `Fmt` → sonstige

Innerhalb eines Typs bleibt die Reihenfolge aus `git log` erhalten, also der neueste Commit zuerst.

## Release-Trailer

Mit einem Git-Trailer in der letzten Zeile des Bodys lässt sich die Sichtbarkeit in den Release-Notes übersteuern:

```text
Fix: Tippfehler im Log-Aufruf

Release: skip
```

- `Release: skip` blendet einen sonst sichtbaren Commit aus, z. B. einen `Fix:`, den kein Nutzer bemerkt.
- `Release: show` nimmt einen sonst internen Commit auf, z. B. `Docs:` für eine neue Anleitung. Ohne erkannten Typ
  erscheint er unter „Sonstige“.
- Setzen: `git commit --trailer "Release: skip"` oder als letzte Zeile von Hand.
- Prüfen: `git log --format='%h %s %(trailers:key=Release,valueonly)'`

Der Changelog zeigt immer alle Commits, unabhängig vom Trailer.

## Ältere Historien

Damit auch ältere Repositorys sauber gegliedert werden, erkennt das Tool zusätzlich:

| Alter Präfix | wird gezählt als |
|---|---|
| `Del` | `Rem` |
| `Mve` | `Mov` |
| `Ign`, `Dis` | `Cfg` |
| `TryFix` | `Fix` |

Toleriert werden außerdem alte Schreibweisen ohne Doppelpunkt: `Fix;`, `Chg.` und ein Präfix nur mit Leerzeichen
(`Add Kommentare`). Im Changelog erscheint die Message unverändert, in den Release-Notes ohne Präfix unter der
zugeordneten Typ-Überschrift.
