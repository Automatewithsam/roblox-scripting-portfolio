--[[
	InventoryRemotes.lua
	Location: ReplicatedStorage

	Central place to fetch/create the remotes used by the inventory system.
	Keeping remote creation in one module avoids duplicate-instance bugs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryRemotes = {}

local folder = ReplicatedStorage:FindFirstChild("InventoryRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "InventoryRemotes"
	folder.Parent = ReplicatedStorage
end

local function getOrCreate(className, name)
	local existing = folder:FindFirstChild(name)
	if existing then
		return existing
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = folder
	return inst
end

-- Client -> Server: request to use/drop an item
InventoryRemotes.RequestUseItem = getOrCreate("RemoteEvent", "RequestUseItem")
InventoryRemotes.RequestDropItem = getOrCreate("RemoteEvent", "RequestDropItem")

-- Server -> Client: inventory state changed
InventoryRemotes.InventoryUpdated = getOrCreate("RemoteEvent", "InventoryUpdated")

-- Client -> Server: initial fetch on join
InventoryRemotes.GetInventory = getOrCreate("RemoteFunction", "GetInventory")

return InventoryRemotes
