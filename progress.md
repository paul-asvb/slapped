# Progress

## Phase 1: Core Foundation ✅
- Projektstruktur, Vehicle mit Arcade-Steuerung, Teststrecke, Kollisionen

## Phase 2: Multiplayer Local ✅
- Input für 2 Spieler (WASD + Pfeiltasten), Controller-Support vorbereitet
- Out-of-Bounds System, Rundensystem, HUD
- Score-System: Punkte bei Out-of-Bounds

## 3D-Umbau ✅
- Doge-Car GLB-Modell mit 4 Rädern
- Sprung-Physik mit Rampen-Erkennung
- Zentrale Konfiguration: GameConfig + WeaponConfig

## Phase 3: Combat System ✅

### Waffen-System
- **Base Weapon Klasse** für Erweiterbarkeit
- **MachineGun**: 30 Schuss, 10/Sek, feuert aus Frontscheinwerfern
- **Projektile**: 3D leuchtende Kugeln mit Kollision
- Input: Space (P1), Enter (P2)

### Power-Up System
- **WeaponPickup**: Schwebendes, rotierendes Pickup
- Verschwindet nach Einsammeln bis zur nächsten Runde
- 3 Pickups auf Teststrecke platziert

### Treffer-Reaktion
- **Lenkungs-Debuff**: Reduzierte Lenkfähigkeit während Beschuss
- **Zuck-Effekt**: Auto zuckt links/rechts bei Treffern
- **Winkel-Begrenzung**: Max 90° Fenster (±45°) für Zucken

## Konfiguration

### weapon_config.tres
```
MachineGun:
  fire_rate: 10, ammo: 30, speed: 80, spread: 2°

Hit Effects:
  debuff_duration: 0.5s
  steering_multiplier: 0.3 (30%)
  jerk_strength: 0.15 rad
  jerk_max_angle: 0.785 rad (45°)
  jerk_randomness: 0.5

PowerUps:
  bob, rotation, respawn next round
```

## Wichtige Dateien

| Datei | Beschreibung |
|-------|--------------|
| `scripts/weapons/weapon.gd` | Base Weapon Klasse |
| `scripts/weapons/machine_gun.gd` | MachineGun |
| `scripts/weapons/projectile.gd` | Projektil |
| `scripts/powerups/power_up.gd` | Base PowerUp |
| `scripts/powerups/weapon_pickup.gd` | Waffen-Pickup |
| `resources/weapon_config.tres` | Waffen-Konfiguration |

## Nächste Schritte
- Visuelles Feedback (Mündungsfeuer, Treffer-Funken)
- Sound-Effekte
- Weitere Waffen (Rakete, Boost, Schild, Mine)
