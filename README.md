# Roblox Scripting Portfolio

A collection of systems I've built for Roblox games, showcasing server-authoritative architecture, clean module structure, and practical gameplay systems.

## Systems

| System | Description | Key Concepts |
|---|---|---|
| [Inventory System](./InventorySystem) | Drag-and-drop inventory with DataStore persistence | ModuleScripts, RemoteEvents, DataStoreService, session locking |
| [Combat System](./CombatSystem) | Hitbox-based combat with cooldown management | Server-side hit validation, debounce patterns, hitbox tuning |
| [Admin Panel](./AdminPanel) | Role-based admin command system | Permission tiers, RemoteFunctions, command parsing |

## Design Philosophy

- **Server-authoritative**: all game-state-changing logic is validated server-side; clients only request actions, never dictate outcomes.
- **Modular**: systems are split into ModuleScripts with clear single responsibilities, so they're easy to extend or drop into other projects.
- **Defensive**: input from clients is always sanity-checked (type, range, rate-limited) before being trusted.

## About Me

Roblox scripter interested in short or long-term contract work. Comfortable building gameplay systems, UI logic, and backend data handling. Open to discussing rates per project scope.
