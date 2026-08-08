--[[
	AdminCommands.lua
	Location: ServerScriptService

	Individual command implementations. Kept separate from AdminService
	so adding a command never requires touching permission/dispatch code.

	Each command function receives (executor, args) and returns
	(success: boolean, message: string).
]]

local Players = game:GetService("Players")

local AdminCommands = {}

-- MinRank: the minimum rank tier (see AdminService.RankOf) required to run this.
AdminCommands.Registry = {}

local function register(name, minRank, fn)
	AdminCommands.Registry[name] = {
		MinRank = minRank,
		Run = fn,
	}
end

register("kick", 1, function(executor, args)
	local targetName = args[1]
	local reason = args[2] or "No reason given"

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Player not found: " .. tostring(targetName)
	end

	target:Kick(("Kicked by %s: %s"):format(executor.Name, reason))
	return true, ("Kicked %s"):format(target.Name)
end)

register("teleport", 1, function(executor, args)
	local targetName = args[1]
	local target = Players:FindFirstChild(targetName)
	if not target or not target.Character then
		return false, "Player not found or has no character: " .. tostring(targetName)
	end

	local execRoot = executor.Character and executor.Character:FindFirstChild("HumanoidRootPart")
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not execRoot or not targetRoot then
		return false, "Missing character parts"
	end

	execRoot.CFrame = targetRoot.CFrame + Vector3.new(3, 0, 0)
	return true, ("Teleported to %s"):format(target.Name)
end)

-- Higher rank required: grants items, so it's economy-affecting.
register("giveitem", 2, function(executor, args)
	local targetName = args[1]
	local itemId = args[2]

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Player not found: " .. tostring(targetName)
	end

	-- In a real project: require InventoryService and call
	-- InventoryService.AddItem(target, itemId, 1)
	return true, ("(demo) Would give %s to %s"):format(tostring(itemId), target.Name)
end)

return AdminCommands
