--[[
	InventoryTypes.lua
	Location: ReplicatedStorage

	Shared item definitions. Both client and server require this module
	so they always agree on what a given item ID represents.
]]

local InventoryTypes = {}

InventoryTypes.Items = {
	["sword_basic"] = {
		Name = "Basic Sword",
		MaxStack = 1,
		Icon = "rbxassetid://0000000000",
		Category = "Weapon",
	},
	["health_potion"] = {
		Name = "Health Potion",
		MaxStack = 20,
		Icon = "rbxassetid://0000000000",
		Category = "Consumable",
	},
	["gold_coin"] = {
		Name = "Gold Coin",
		MaxStack = 999,
		Icon = "rbxassetid://0000000000",
		Category = "Currency",
	},
}

function InventoryTypes.IsValidItem(itemId)
	return InventoryTypes.Items[itemId] ~= nil
end

function InventoryTypes.GetMaxStack(itemId)
	local item = InventoryTypes.Items[itemId]
	return item and item.MaxStack or 1
end

return InventoryTypes
