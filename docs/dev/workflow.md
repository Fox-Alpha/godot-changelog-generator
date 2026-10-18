# Git-Workflow

> Quelle: Kopie von `Multiplayer-Template/docs/dev/workflow.md`. Änderungen am Kern dort vornehmen und hierher übernehmen.

> Vor jedem Commit, Branch-Wechsel oder Merge lesen.
> Neutraler Kern für alle Projekte. Projektspezifisches steht in Zusätzen (z. B. `workflow-godot.md`) oder in der
> `CLAUDE.md` bzw. `AGENTS.md` des Projekts. Bei Widersprüchen gilt die Projektdatei.

---

## Projekteinstellungen

Diese Punkte legt jedes Projekt in seiner eigenen Anweisungsdatei fest. Fehlt eine Angabe, gilt der Standard.

| Einstellung | Standard | Beispiel für die Projektdatei |
|---|---|---|
| Sprache der Commit-Messages | Sprache der bisherigen Historie | `Commit-Sprache: Deutsch` |
| Quellordner | Repo-Wurzel (keiner getrennt) | `Quellordner: src/` |
| Zusätze | keine | `Zusatz: workflow-godot.md` |

---

## Commit-Messages

### Format

```
<Typ>: <kurze Beschreibung>

- optionale Details als Liste
- Hinweise wie offene Punkte oder Einschränkungen
```

- **Nach der Betreffzeile immer eine Leerzeile.** Ohne sie zählt Git den Body zum Betreff und fügt alles zu einer
  langen Zeile zusammen (`git log --oneline`, GitHub, Changelog).
- **Ein logischer Schritt pro Commit.** Nicht zusammengehörige Änderungen nie in einen Commit packen.
- **Genau ein Typ pro Betreff.** Braucht ein Commit mehrere Typen, ist er zu groß und wird aufgeteilt.
- Betreffzeile kurz und konkret (Richtwert 72 Zeichen), Details gehören in den Body.
- Offene Punkte (`TODO`, „noch nicht getestet“) stehen im Body, nicht im Betreff.
- Eigene Typen statt Conventional Commits: **kein** `feat:`, `chore:`, `fix:` usw. (Groß geschrieben, drei bis vier
  Buchstaben.)

### Typen

| Typ | Bedeutung | Beispiel |
|---|---|---|
| `Add:` | Neue Dateien, Funktionen oder Features | `Add: Inventarsystem für Spieler` |
| `Fix:` | Fehlerbehebung | `Fix: Kollision an steilen Hängen nicht erkannt` |
| `Chg:` | Geänderte Logik, Struktur oder geändertes Verhalten | `Chg: Kollisionsbehandlung in eigene Funktionen aufgeteilt` |
| `Upd:` | Anpassung ohne neues Verhalten: Werte, Parameter, Versionen, Texte | `Upd: Sprungkraft von 400 auf 500` |
| `Ref:` | Refactoring ohne Verhaltensänderung | `Ref: Schadensberechnung in Hilfsfunktion ausgelagert` |
| `Rem:` | Entfernen von Dateien oder Code | `Rem: ungenutzte Minimap-Variante` |
| `Ren:` | Umbenennen von Dateien, Ordnern, Branches oder Bezeichnern | `Ren: Ordner doc zu docs` |
| `Mov:` | Verschieben von Dateien oder Code an einen anderen Ort | `Mov: Arbeitsnotizen nach docs/notes` |
| `Docs:` | Reine Dokumentationsänderung (Markdown, Kommentare ohne Codeänderung) | `Docs: Einrichtung im README ergänzt` |
| `Cfg:` | Konfiguration und Tooling: Ignore-Dateien, Editor-/Projekteinstellungen, Addons an/aus, CI | `Cfg: Lint-Dateien ignorieren` |
| `Fmt:` | Nur Formatierung und Linter-Korrekturen, keine inhaltliche Änderung | `Fmt: scenes/ui formatiert` |

Abgrenzung in Zweifelsfällen:
- `Upd:` oder `Chg:`? Verhält sich das Programm danach anders → `Chg:`. Nur ein Wert/Text anders → `Upd:`.
- `Docs:` oder `Add:`? Neue Doku-Datei → `Docs:`. Der Typ beschreibt die Art der Änderung, nicht ob eine Datei neu ist.
- `Ren:` oder `Mov:`? Gleicher Ort, neuer Name → `Ren:`. Neuer Ort → `Mov:`. Beides → `Mov:`.
- `Fmt:` oder `Ref:`? Nur Leerzeichen, Einrückung, Zeilenumbrüche, Linter-Hinweise → `Fmt:`. Code umgebaut → `Ref:`.

### Release-Notes

Der Typ legt fest, ob ein Commit in Release-Notes und Changelog-Zusammenfassungen erscheint:

- **Sichtbar:** `Add:`, `Fix:`, `Chg:`, `Upd:`, `Rem:`
- **Intern (ausgeblendet):** `Docs:`, `Cfg:`, `Fmt:`, `Ref:`, `Ren:`, `Mov:`

Ausnahmen werden mit einem **Git-Trailer** in der letzten Zeile des Bodys markiert (Format wie `Co-Authored-By:`):

```
Fix: Tippfehler im Log-Aufruf

Release: skip
```

- `Release: skip` blendet einen sonst sichtbaren Commit aus (z. B. ein `Fix:`, den kein Nutzer bemerkt).
- `Release: show` nimmt einen sonst internen Commit auf (z. B. `Docs:` für eine neue Anleitung).
- Setzen: `git commit --trailer "Release: skip"` oder als letzte Zeile von Hand.
- Auslesen: `git log --format='%h %s %(trailers:key=Release,valueonly)'`

### Merge-Commits

```
Merge: <Beschreibung des Features>

- Zusammenfassung, was der Branch enthält
```

---

## Branches

| Branch | Zweck |
|---|---|
| Standardbranch des Repos (`main` oder `master`) | Nur stabile Stände und Releases. **Nie direkt committen.** |
| `development` | Laufende Entwicklung, Basis für alle Feature-Branches |
| `feature/<thema>` | Ein Branch pro Thema, zweigt immer von `development` ab |

### Regeln

- Existiert `development` nicht, wird er vom Standardbranch abgezweigt.
- Ein Feature-Branch gehört zu **einem Thema**, nicht zu einer Sitzung. Er darf über mehrere Sitzungen laufen.
- Feature-Branches bleiben thematisch sauber. Fällt unterwegs Arbeit für ein anderes Thema an, kommt sie in einen
  eigenen Branch (bei Bedarf per Cherry-Pick).
- Nach dem Merge in `development` wird der Feature-Branch gelöscht, lokal und auf dem Remote.
- **Merges in `development` oder den Standardbranch nie selbstständig**, immer erst nach ausdrücklicher Freigabe.
- Merges in den Standardbranch nur, wenn der Stand vollständig und fehlerfrei ist.
- Releases auf dem Standardbranch bekommen einen **Versions-Tag** (z. B. `v0.1.0`, `v1.0.0`).
- Branches umbenennen: auf der Hosting-Plattform (z. B. GitHub) umbenennen, damit PRs und Schutzregeln mitwandern,
  danach lokal `git branch -m`, `git fetch --prune` und `git branch -u` auf jedem Rechner.

---

## Ablauf einer Sitzung

### Start

1. Prüfen, ob das Verzeichnis ein Git-Repo ist.
   - **Kein Repo oder leeres Verzeichnis:** nachfragen, ob ein neues Git-Repo angelegt werden soll. Wenn ja: Repo
     anlegen, `development` vom Standardbranch abzweigen und einen ersten Feature-Branch anlegen.
   - **Repo vorhanden:** aktueller Branch, `git status`, letzte Commits und nicht committete Änderungen kurz melden.
2. Passt der aktuelle Branch nicht zum Thema der Aufgabe (oder steht man auf `development`/Standardbranch), einen
   passenden `feature/<thema>`-Branch vorschlagen bzw. anlegen.
3. Ist Aufgabe oder Umfang unklar, vor der Arbeit nachfragen.

### Während der Sitzung

- Vor der Umsetzung kurz das geplante Vorgehen beschreiben und auf Bestätigung warten.
- **Selbstständig in kleinen Schritten committen**, nach jedem logischen Schritt. Nicht alles in einen Abschluss-Commit.
- **Pushen nur auf Anweisung.** Ist ein Branch oder Thema abgeschlossen, nachfragen, ob gepusht werden soll.
- Wird eine Aufgabe größer als erwartet, anhalten und den Umfang neu abstimmen.

### Ende

1. Prüfschritte aus den Zusätzen ausführen (z. B. Audit), falls vorhanden.
2. Kurze Zusammenfassung:
   - Was geändert wurde (Dateien, Commits)
   - Was offen oder unfertig ist
   - Vorgeschlagene nächste Schritte

---

## Eigenständigkeit und Entscheidungen

- **Neue Dateien und Ordner:**
  - Außerhalb des Quellordners (Repo-Wurzel, `docs/`, Tool- und Konfigurationsordner) vorher nachfragen.
  - Innerhalb des Quellordners frei anlegen, wenn es zur Aufgabe gehört.
- Vor strukturellen oder architektonischen Änderungen nachfragen, auch innerhalb des Quellordners (z. B. neue
  Ordnerstruktur, verschobene Module).
- Kleine, klar abgegrenzte Änderungen direkt umsetzen.
- Fällt bei der Umsetzung eine bessere Lösung auf: nennen und empfehlen, aber nicht ohne Bestätigung umsetzen.
- Fehler außerhalb der Aufgabe sofort melden, nicht stillschweigend beheben.
- Bei mehrdeutigen Anforderungen nachfragen statt annehmen.

---

## Shell-Befehle

- **Verketten erlaubt,** wenn die Befehle zusammen *einen* nachvollziehbaren Schritt bilden (z. B. `git add` und
  `git commit`). Die Beschreibung des Aufrufs nennt, was passiert.
- **Destruktive Befehle immer einzeln und nie verkettet:** `rm -r`, `git reset --hard`, `git clean`,
  `git push --force`, `git branch -D` usw. So bleibt jeder einzeln prüf- und freigebbar.
- **Variablen in Pfaden absichern:** `"${VAR:?}"` statt `$VAR`. Ist die Variable leer, bricht der Befehl ab, statt
  z. B. `rm -rf /` auszuführen.
- Technische Absicherung zusätzlich über Deny-Regeln des Werkzeugs (Claude Code: `permissions.deny` in
  `~/.claude/settings.json`).
