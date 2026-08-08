--[[
	CombatService.lua
	Location: ServerScriptService

	Validates and applies all combat damage. The client can request an
	attack, but the server independently determines what (if anything)
	actually got hit.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatRemotes = require(ReplicatedStorage:WaitForChild("CombatRemotes"))

local CombatService = {}

local CONFIG = {
	AttackRange = 6,        -- studs
	AttackAngle = 90,       -- degrees, cone in front of the attacker
	AttackCooldown = 0.6,   -- seconds between attacks per player
	BaseDamage = 15,
}

-- [player] = last attack timestamp (os.clock())
local lastAttackTime = {}

local function isOnCooldown(player)
	local last = lastAttackTime[player]
	if not last then
		return false
	end
	return (os.clock() - last) < CONFIG.AttackCooldown
end

--[[
	Finds valid targets in front of the attacker within range + angle.
	Returns a list of humanoids that were legitimately hit.
]]
local function findTargetsInCone(attackerCharacter)
	local hits = {}

	local root = attackerCharacter:FindFirstChild("HumanoidRootPart")
	if not root then
		return hits
	end

	local originPos = root.Position
	local lookVector = root.CFrame.LookVector

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character ~= attackerCharacter then
			local targetRoot = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if targetRoot and humanoid and humanoid.Health > 0 then
				local toTarget = targetRoot.Position - originPos
				local distance = toTarget.Magnitude

				if distance <= CONFIG.AttackRange then
					local direction = toTarget.Unit
					local angle = math.deg(math.acos(lookVector:Dot(direction)))

					if angle <= CONFIG.AttackAngle / 2 then
						table.insert(hits, { Player = player, Humanoid = humanoid })
					end
				end
			end
		end
	end

	return hits
end

CombatRemotes.RequestAttack.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then
		return
	end

	-- Server-side cooldown check — ignores whatever the client thinks
	-- its own cooldown state is.
	if isOnCooldown(player) then
		return
	end
	lastAttackTime[player] = os.clock()

	local targets = findTargetsInCone(character)

	for _, target in ipairs(targets) do
		target.Humanoid:TakeDamage(CONFIG.BaseDamage)
		CombatRemotes.HitConfirmed:FireAllClients(player, target.Player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastAttackTime[player] = nil
end)

return CombatService
