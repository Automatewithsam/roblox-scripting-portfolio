# Combat System

Server-side hit detection with hitbox tuning, cooldown/debounce handling, and basic anti-exploit checks (range + rate limiting).

## Structure

- `CombatService.lua` (ServerScriptService) — validates and applies every hit; the only place damage is actually dealt.
- `CombatClient.lua` (StarterPlayerScripts) — plays swing animation and fires a hit request; does no damage itself.
- `CombatRemotes.lua` (ReplicatedStorage) — shared remote definitions.

## Key Design Points

- **Server decides who got hit, not the client.** The client tells the server "I attacked," and the server performs its own spatial check (distance + angle) against nearby characters before applying damage. A modified client can't just claim arbitrary hits.
- **Cooldown enforced server-side.** A debounce table keyed by player prevents attack-spam exploits, independent of whatever the client-side animation timing shows.
- **Range/angle sanity check.** Rejects hits against targets that are clearly out of weapon range, catching common "hitbox extender" exploits.
