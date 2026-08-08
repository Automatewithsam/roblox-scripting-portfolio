--[[
	CombatRemotes.lua
	Location: ReplicatedStorage
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatRemotes = {}

local folder = ReplicatedStorage:FindFirstChild("CombatRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "CombatRemotes"
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

-- Client -> Server: "I swung my weapon, here's roughly where"
CombatRemotes.RequestAttack = getOrCreate("RemoteEvent", "RequestAttack")

-- Server -> Client: broadcast a confirmed hit (for VFX/sound on all clients)
CombatRemotes.HitConfirmed = getOrCreate("RemoteEvent", "HitConfirmed")

return CombatRemotes
