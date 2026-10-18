# godot-changelog-generator

Bash-Script mit eingebettetem Python 3, das aus der Git-Historie einen Markdown-Changelog oder Release-Notes
erzeugt. Der Changelog ist nach Datum gegliedert und innerhalb eines Datums nach Commit-Typ sortiert, die
Release-Notes sind nach Typ gegliedert.

## Features

- Quelle ist ein Branch (lokal oder Remote), das Zeitfenster wird über Tags, Datum oder `FIRST`/`LATEST` gesetzt
- Filter auf einen oder mehrere Pfade und auf Dateiendungen
- Release-Notes mit sichtbaren Typen und Git-Trailer `Release: skip`/`Release: show`
- Commit-Links aus der Remote-URL (SSH oder HTTPS, GitHub, GitLab)
- [Commit-Typen](docs/commit-types.md) mit fester Reihenfolge, alte Präfixe werden zugeordnet
- Merge-Commits ausgeblendet, je Commit nur die erste Zeile der Message
- Überschreibschutz, Ausgabe auch auf die Standardausgabe

## Voraussetzungen

- Bash
- Python 3
- Git, Aufruf innerhalb eines Repositorys

## Installation

Empfohlen ist die Installation als Git-Unterbefehl `git chlog`. Git führt jedes Programm namens `git-<name>` im
`PATH` als `git <name>` aus. Das Script liegt dabei in einem eigenen Ordner für freigegebene Versionen und nicht im
Arbeitsstand des Repos, damit Branch-Wechsel und halbfertige Änderungen das installierte Tool nicht verändern.

Aus einem Klon des Repos, `<tag>` ist der Release-Tag der gewünschten Version, z. B. `v2.1.0`:

```bash
mkdir -p ~/.local/lib/tools/changelog-generator
git -C <pfad-zum-klon> show <tag>:generate_changelog.sh > ~/.local/lib/tools/changelog-generator/generate_changelog.sh
chmod 755 ~/.local/lib/tools/changelog-generator/generate_changelog.sh
ln -s ~/.local/lib/tools/changelog-generator/generate_changelog.sh ~/.local/bin/git-chlog
```

Ohne Klon geht es genauso mit `generate_changelog.sh` aus den Anhängen eines
[Releases](https://github.com/Fox-Alpha/godot-changelog-generator/releases). `~/.local/bin` muss im `PATH` liegen.
Prüfen mit `git chlog -V`.

**Aktualisieren:** die Datei im Ordner mit dem Stand des neuen Tags überschreiben, der Link bleibt.

## Verwendung

```bash
git chlog [OPTIONEN]
# oder ohne Installation
./generate_changelog.sh [OPTIONEN]
```

Hilfe mit `git chlog -h`. `git chlog --help` sucht stattdessen eine Manpage `git-chlog`, die es nicht gibt.

| Option | Kurzform | Beschreibung | Standard |
|---|---|---|---|
| `--branch <Branch>` | `-b` | Quelle: lokaler oder Remote-Branch. Tags sind nicht erlaubt. | aktueller Branch, bei detached HEAD `HEAD` |
| `--since <Start>` | `-s` | Beginn: Tag (ausgeschlossen), Datum `JJJJ-MM-TT` (eingeschlossen) oder `FIRST` | `FIRST` |
| `--until <Ende>` | `-u` | Ende: Tag (eingeschlossen), Datum (ganzer Tag eingeschlossen) oder `LATEST` | `LATEST` |
| `--path <Pfad> …` | `-p` | ein oder mehrere Pfade, alle Argumente bis zur nächsten Option | ganzes Repo |
| `--ext <Endungen>` | `-e` | Dateiendungen kommagetrennt ohne Punkt, z. B. `gd,tscn` | alle |
| `--release` | `-r` | Release-Notes statt vollständigem Changelog | aus |
| `--output <Datei>` | `-o` | Ausgabedatei relativ zum Aufrufverzeichnis, `-` = Standardausgabe | siehe unten |
| `--force` | `-f` | vorhandene Ausgabedatei überschreiben | aus |
| `--title <Titel>` | `-t` | Überschrift | `<Repo> (<Branch>)`, bei `-r` `<Repo> <Version>` |
| `--version` | `-V` | Version anzeigen | – |
| `--help` | `-h` | Hilfe anzeigen | – |

Tags in `-s` und `-u` müssen in der Historie von `-b` liegen, sonst bricht das Script mit Fehler ab.

**Standard-Ausgabepfade (ohne `-o`):**

| Aufruf | Ausgabepfad |
|---|---|
| ohne Filter | `<repo-root>/CHANGELOG.md` |
| `-p src/player/` | `<repo-root>/docs/CHANGELOG_src_player.md` |
| `-p src/player/player.gd` | `<repo-root>/docs/CHANGELOG_src_player_player.md` |
| `-p src/player/ -e gd` | `<repo-root>/docs/CHANGELOG_src_player_gd.md` |
| `-e gd,tscn` | `<repo-root>/docs/CHANGELOG_gd_tscn.md` |
| `-r -u v1.2.0` | `<repo-root>/docs/releases/v1.2.0.md` |
| `-r` ohne Tag in `-u` | `<repo-root>/docs/releases/unreleased.md` |

Bei `-r` mit `-p`/`-e` wird der Filter an den Dateinamen angehängt, z. B. `docs/releases/v1.2.0_gd.md`. Existiert
die Ausgabedatei, bricht das Script ohne `-f` ab. Gibt es keine Treffer, entsteht keine Datei (Exit-Code 0).

## Dokumentation

- [Beispiele, Ausgabeformat und Einschränkungen](docs/usage.md)
- [Commit-Typen, Reihenfolge und Release-Trailer](docs/commit-types.md)

## Lizenz

[MIT](LICENSE)

## Part of godot-dev-toolkit

Dieses Tool ist Teil des [godot-dev-toolkit](https://github.com/Fox-Alpha/godot-dev-toolkit) Hubs.

> Ein C#/Avalonia-Port ist optional für die Zukunft geplant, aber aktuell nicht priorisiert.
