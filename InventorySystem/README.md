# Inventory System

A server-authoritative inventory system with DataStore persistence, session locking (to prevent duplication across multiple servers), and a simple client API for UI hookup.

## Structure

- `InventoryService.lua` (ServerScriptService) — owns all inventory state, handles saving/loading, validates every add/remove request.
- `InventoryTypes.lua` (ReplicatedStorage) — shared item definitions so client and server agree on what an item "is".
- `InventoryRemotes.lua` (ReplicatedStorage) — defines the RemoteEvent/RemoteFunction used for client-server communication.

## Key Design Points

- **Server owns the truth.** The client never modifies inventory data directly — it fires a request, the server validates it (does the player actually have this item? is there room?), and only then applies the change and fires an update back to the client.
- **DataStore session locking.** Prevents the classic "join on two servers, duplicate items" exploit by tracking an active session key per player.
- **Retry logic on save.** DataStore calls can fail transiently; saves retry with backoff rather than silently failing.



