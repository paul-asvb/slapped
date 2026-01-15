# State-of-the-Art Race Position Tracking System

**Status: ✅ IMPLEMENTIERT**

---

## Problem mit vorherigem Ansatz

Der Winkel-basierte Ansatz (`atan2` vom Track-Zentrum) funktioniert **NUR für kreisförmige/ovale Strecken**. Bei komplexen Streckenformen (S-Kurven, Haarnadelkurven, sich kreuzende Strecken) versagt er komplett.

---

## State-of-the-Art Ansätze in der Spieleentwicklung

### 1. Spline/Path-basiertes Tracking (INDUSTRIE-STANDARD)

Die Strecken-Mittellinie wird als Kurve (Spline) definiert. Jeder Punkt auf der Kurve hat einen Offset-Wert von 0 (Start) bis `total_length` (Ziellinie).

**Funktionsweise:**
```
Track-Centerline: Path2D mit Curve2D
     |
     v
Fahrzeug-Position --> Finde nächsten Punkt auf Kurve
     |
     v
Offset auf Kurve = Fortschritt (z.B. 1250.5 von 5000 Metern)
     |
     v
+ Rundenzähler x Streckenlänge = Gesamt-Fortschritt
```

**Vorteile:**
- Funktioniert mit JEDER Streckenform
- Sehr präzise
- Godot hat eingebaute Unterstützung (`Path2D`, `Curve2D`)
- Kann auch für KI-Pfadfindung wiederverwendet werden

**Nachteile:**
- Erfordert Pfad-Erstellung pro Strecke (aber einfach im Editor)

---

### 2. Checkpoint/Sektor-System

Unsichtbare Trigger-Zonen über die Strecke verteilt.

**Funktionsweise:**
```
Checkpoint 0 --> 1 --> 2 --> 3 --> ... --> N --> (zurück zu 0 = neue Runde)
     |
     v
Position = Checkpoint-Index + Zeit seit letztem Checkpoint
```

**Vorteile:** Sehr einfach, gut für Arcade-Spiele
**Nachteile:** Ungenau zwischen Checkpoints, viele Trigger nötig

---

### 3. Waypoint-Pfad (diskret)

Ähnlich wie Spline, aber mit diskreten Punkten statt Kurve.

**Funktionsweise:**
- Array von Vector2-Punkten entlang der Mittellinie
- Finde nächstes Segment zum Fahrzeug
- Berechne Position auf diesem Segment

**Vorteile:** Einfacher als Splines
**Nachteile:** Weniger glatt, mehr Punkte für Genauigkeit nötig

---

### 4. Track-Textur / Signed Distance Field

Vorberechnete Textur wo Helligkeit = Fortschritt.

**Vorteile:** Extrem schnelles Lookup
**Nachteile:** Komplex zu generieren, auflösungsabhängig

---

## Gewählter Ansatz: Path2D-basiertes System

Godot bietet **eingebaute Unterstützung** für genau diesen Ansatz:

```gdscript
# Godot's Path2D/Curve2D Funktionen:
var curve: Curve2D = path.curve
var closest_offset = curve.get_closest_offset(vehicle.global_position)
var progress_percent = closest_offset / curve.get_baked_length()
```

---

## Architektur

```
+-----------------------------------------------------------+
|                    RaceTracker.gd                         |
|  (Autoload oder Node im Track)                            |
+-----------------------------------------------------------+
|  - racing_line: Path2D (Referenz zur Track-Kurve)         |
|  - vehicles: Array[Vehicle]                               |
|  - lap_counts: Dictionary[Vehicle, int]                   |
|  - last_offsets: Dictionary[Vehicle, float]               |
+-----------------------------------------------------------+
|  get_progress(vehicle) -> float (Gesamt-Fortschritt)      |
|  get_position(vehicle) -> int (Platzierung 1, 2, 3...)    |
|  get_lap(vehicle) -> int                                  |
|  get_leader() -> Vehicle                                  |
|  _detect_lap_crossing(vehicle, old_offset, new_offset)    |
+-----------------------------------------------------------+
         ^
         | verwendet
         |
+-----------------------------------------------------------+
|              Track Scene (z.B. test_track.tscn)           |
+-----------------------------------------------------------+
|  +-- RacingLine (Path2D)                                  |
|       +-- Curve2D mit Punkten entlang der Ideallinie      |
+-----------------------------------------------------------+
```

---

## Runden-Erkennung

```
Wenn Fahrzeug von Offset 4900 --> 100 springt (bei Streckenlänge 5000):
  --> Neue Runde begonnen!

Wenn Fahrzeug von Offset 100 --> 4900 springt:
  --> Rückwärts über Startlinie (Runde abziehen oder ignorieren)
```

---

## Implementierungs-Schritte

### Schritt 1: Path2D "RacingLine" zur Test-Strecke hinzufügen ✅
- Punkte entlang der Strecken-Mittellinie platziert (8 Punkte für Oval)
- Path2D Node in `test_track.tscn` erstellt

### Schritt 2: RaceTracker.gd erstellen ✅
- Zentrales Modul für Positions-Tracking
- API: `get_progress()`, `get_position()`, `get_leader()`
- Runden-Erkennung implementiert

### Schritt 3: Integration ✅
- Kamera: Alte Winkel-Logik entfernt, RaceTracker verwendet
- HUD: Positionen von RaceTracker geholt, zeigt Fortschritt in %
- Game: Leader-Ermittlung über RaceTracker

### Schritt 4: Bestehende Strecke anpassen ✅
- Racing-Line Path2D mit 8 Punkten für ovale Mittellinie

---

## Dateien die erstellt/geändert wurden

| Datei | Status |
|-------|--------|
| `scripts/race/race_tracker.gd` | ✅ NEU - Zentrales Tracking-Modul |
| `scenes/tracks/test_track.tscn` | ✅ GEÄNDERT - RacingLine Path2D hinzugefügt |
| `scripts/vehicles/dynamic_camera.gd` | ✅ GEÄNDERT - Nutzt jetzt RaceTracker |
| `scripts/ui/hud.gd` | ✅ GEÄNDERT - Nutzt jetzt RaceTracker |
| `scripts/game.gd` | ✅ GEÄNDERT - RaceTracker integriert |

---

## Vorteile dieses Systems

1. **Universell** - Funktioniert mit jeder Streckenform
2. **Präzise** - Kontinuierlicher Fortschritt, keine Sprünge
3. **Erweiterbar** - Kann für KI, Geisterfahrer, Bestzeiten genutzt werden
4. **Godot-Native** - Nutzt eingebaute Path2D/Curve2D Funktionen
5. **Visuell editierbar** - Racing-Line kann im Editor angepasst werden
