local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local NORMAL_FOV = 70
local SPRINT_FOV = 85

local NORMAL_SPEED = 16
local SPRINT_SPEED = 24
local CROUCH_SPEED = 8

local CROUCH_OFFSET = Vector3.new(0, -1.5, 0)

-- STATE
local isSprinting = false
local isCrouching = false

local character, humanoid, rootPart

local function setupChar(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = NORMAL_SPEED
	camera.FieldOfView = NORMAL_FOV
end

player.CharacterAdded:Connect(setupChar)
if player.Character then setupChar(player.Character) end

-- LOCK FIRST PERSON
player.CameraMode = Enum.CameraMode.LockFirstPerson
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- INPUT
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = true
	elseif input.KeyCode == Enum.KeyCode.C then
		isCrouching = not isCrouching
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
	end
end)

-- CAMERA + MOVEMENT LOOP
RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not rootPart then return end

	-- speed logic
	if isCrouching then
		humanoid.WalkSpeed = CROUCH_SPEED
	elseif isSprinting then
		humanoid.WalkSpeed = SPRINT_SPEED
	else
		humanoid.WalkSpeed = NORMAL_SPEED
	end

	-- FOV smoothing
	local targetFOV = isSprinting and SPRINT_FOV or NORMAL_FOV
	camera.FieldOfView += (targetFOV - camera.FieldOfView) * 0.1

	-- crouch camera offset
	if isCrouching then
		humanoid.CameraOffset = CROUCH_OFFSET
	else
		humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.new(0,0,0), 0.2)
	end
end)
