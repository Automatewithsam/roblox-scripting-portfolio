--[[
	AdminService.lua
	Location: ServerScriptService

	Permission checking + command dispatch. Every command run is
	re-validated against the executor's current rank — no caching
	"is admin" on the client and trusting it later.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminRemotes = require(ReplicatedStorage:WaitForChild("AdminRemotes"))
local AdminCommands = require(script.Parent:WaitForChild("AdminCommands"))

local AdminService = {}

-- Rank tiers: 0 = none, 1 = moderator, 2 = admin.
-- In a real project this would likely be pulled from a group rank,
-- a DataStore-backed staff list, or an external permissions API.
local RANK_TABLE = {
	[123456789] = 2, -- example UserId -> Admin
	[987654321] = 1, -- example UserId -> Moderator
}

function AdminService.RankOf(player)
	return RANK_TABLE[player.UserId] or 0
end

local function parseCommandString(input)
	local parts = {}
	for word in input:gmatch("%S+") do
		table.insert(parts, word)
	end

	local commandName = table.remove(parts, 1)
	return commandName, parts
end

AdminRemotes.RunCommand.OnServerInvoke = function(executor, rawInput)
	if type(rawInput) ~= "string" or #rawInput == 0 or #rawInput > 200 then
		return false, "Invalid input"
	end

	local commandName, args = parseCommandString(rawInput)
	if not commandName then
		return false, "No command given"
	end

	local command = AdminCommands.Registry[commandName:lower()]
	if not command then
		return false, "Unknown command: " .. commandName
	end

	local executorRank = AdminService.RankOf(executor)
	if executorRank < command.MinRank then
		-- Deliberately vague message — don't reveal rank thresholds
		-- to a client that might be probing for exploitable commands.
		return false, "You don't have permission to run this command"
	end

	local ok, success, message = pcall(command.Run, executor, args)
	if not ok then
		warn(("AdminService: command '%s' errored: %s"):format(commandName, tostring(success)))
		return false, "Command failed to execute"
	end

	return success, message
end

return AdminService
