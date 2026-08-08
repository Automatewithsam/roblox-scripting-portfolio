--[[
	AdminRemotes.lua
	Location: ReplicatedStorage
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminRemotes = {}

local folder = ReplicatedStorage:FindFirstChild("AdminRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "AdminRemotes"
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

-- Client -> Server: run a command, get a result back (success, message)
AdminRemotes.RunCommand = getOrCreate("RemoteFunction", "RunCommand")

return AdminRemotes
