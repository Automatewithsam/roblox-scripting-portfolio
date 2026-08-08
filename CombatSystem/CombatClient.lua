--[[
	CombatClient.lua
	Location: StarterPlayerScripts

	Handles player input and swing animation. Deliberately contains no
	damage logic — it only asks the server to resolve an attack.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local CombatRemotes = require(ReplicatedStorage:WaitForChild("CombatRemotes"))

local player = Players.LocalPlayer

local CLIENT_COOLDOWN = 0.6 -- mirrors server cooldown, purely for UX (disabling spam clicks)
local lastLocalAttack = 0

local function playSwingAnimation(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	-- In a real project: humanoid:LoadAnimation(swingAnim):Play()
	-- Omitted here since it depends on the specific rig/animation asset.
end

local function tryAttack()
	local now = os.clock()
	if (now - lastLocalAttack) < CLIENT_COOLDOWN then
		return -- purely cosmetic; server enforces the real cooldown
	end
	lastLocalAttack = now

	local character = player.Character
	if not character then
		return
	end

	playSwingAnimation(character)
	CombatRemotes.RequestAttack:FireServer()
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		tryAttack()
	end
end)

-- Play hit VFX/sound whenever the server confirms a hit involving anyone
CombatRemotes.HitConfirmed.OnClientEvent:Connect(function(attacker, target)
	-- e.g. spawn a hit spark at target.Character.HumanoidRootPart.Position
	-- Omitted: depends on specific VFX assets used in the project.
end)
