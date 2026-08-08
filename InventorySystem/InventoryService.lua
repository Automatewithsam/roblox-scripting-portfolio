--[[
	InventoryService.lua
	Location: ServerScriptService

	Owns all inventory state server-side. Handles loading/saving via
	DataStoreService, validates every mutation, and pushes updates to
	the owning client.

	This is a portfolio/demo excerpt — trimmed for readability but
	structured the way I'd actually ship it.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryTypes = require(ReplicatedStorage:WaitForChild("InventoryTypes"))
local InventoryRemotes = require(ReplicatedStorage:WaitForChild("InventoryRemotes"))

local InventoryService = {}

local inventoryStore = DataStoreService:GetDataStore("PlayerInventory_v1")
local sessionStore = DataStoreService:GetDataStore("InventorySessionLocks_v1")

-- In-memory cache: [player] = { [itemId] = count, ... }
local playerInventories = {}

local SAVE_RETRY_ATTEMPTS = 3
local SAVE_RETRY_DELAY = 2

local function attemptWithRetry(fn, attempts, delaySeconds)
	local lastErr
	for i = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		task.wait(delaySeconds)
	end
	return false, lastErr
end

local function acquireSessionLock(userId)
	local key = tostring(userId)
	local success, currentOwner = pcall(function()
		return sessionStore:GetAsync(key)
	end)

	if success and currentOwner and currentOwner ~= game.JobId then
		-- Another server currently owns this player's data.
		return false
	end

	local setSuccess = pcall(function()
		sessionStore:SetAsync(key, game.JobId)
	end)

	return setSuccess
end

local function releaseSessionLock(userId)
	pcall(function()
		sessionStore:RemoveAsync(tostring(userId))
	end)
end

function InventoryService.LoadInventory(player)
	local locked = acquireSessionLock(player.UserId)
	if not locked then
		player:Kick("Your inventory is loading on another server. Please rejoin in a moment.")
		return
	end

	local success, data = attemptWithRetry(function()
		return inventoryStore:GetAsync(tostring(player.UserId))
	end, SAVE_RETRY_ATTEMPTS, SAVE_RETRY_DELAY)

	if success and data then
		playerInventories[player] = data
	else
		playerInventories[player] = {} -- fresh inventory
	end

	InventoryRemotes.InventoryUpdated:FireClient(player, playerInventories[player])
end

function InventoryService.SaveInventory(player)
	local data = playerInventories[player]
	if not data then
		return
	end

	attemptWithRetry(function()
		inventoryStore:SetAsync(tostring(player.UserId), data)
	end, SAVE_RETRY_ATTEMPTS, SAVE_RETRY_DELAY)

	releaseSessionLock(player.UserId)
end

--[[
	AddItem: the only way items should ever enter a player's inventory.
	Always called from trusted server code (e.g. a purchase handler, a
	quest reward, a loot drop) — never in direct response to a raw
	client remote call.
]]
function InventoryService.AddItem(player, itemId, quantity)
	quantity = quantity or 1

	if not InventoryTypes.IsValidItem(itemId) then
		warn(("AddItem: invalid itemId '%s' for player %s"):format(tostring(itemId), player.Name))
		return false
	end

	local inventory = playerInventories[player]
	if not inventory then
		return false
	end

	local maxStack = InventoryTypes.GetMaxStack(itemId)
	local current = inventory[itemId] or 0
	inventory[itemId] = math.min(current + quantity, maxStack)

	InventoryRemotes.InventoryUpdated:FireClient(player, inventory)
	return true
end

--[[
	RemoveItem: validated removal. Returns false if the player doesn't
	have enough of the item, so callers can react (e.g. reject a trade).
]]
function InventoryService.RemoveItem(player, itemId, quantity)
	quantity = quantity or 1
	local inventory = playerInventories[player]
	if not inventory then
		return false
	end

	local current = inventory[itemId] or 0
	if current < quantity then
		return false
	end

	inventory[itemId] = current - quantity
	if inventory[itemId] <= 0 then
		inventory[itemId] = nil
	end

	InventoryRemotes.InventoryUpdated:FireClient(player, inventory)
	return true
end

-- Client asks to "use" an item (e.g. drink a potion). Server validates
-- ownership and applies the effect; never trusts the client's claim.
InventoryRemotes.RequestUseItem.OnServerEvent:Connect(function(player, itemId)
	if type(itemId) ~= "string" then
		return
	end

	local inventory = playerInventories[player]
	if not inventory or not inventory[itemId] or inventory[itemId] <= 0 then
		return -- player doesn't actually have this item; ignore
	end

	-- Apply item effect here based on category (e.g. heal player for potions)
	-- ... effect logic omitted for brevity ...

	InventoryService.RemoveItem(player, itemId, 1)
end)

InventoryRemotes.GetInventory.OnServerInvoke = function(player)
	return playerInventories[player] or {}
end

Players.PlayerAdded:Connect(InventoryService.LoadInventory)
Players.PlayerRemoving:Connect(InventoryService.SaveInventory)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		InventoryService.SaveInventory(player)
	end
end)

return InventoryService
