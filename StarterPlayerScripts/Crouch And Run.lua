local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- SETTINGS
local SPEED_WALK = 16
local SPEED_RUN = 24
local SPEED_CROUCH = 8

local FOV_NORMAL = 70
local FOV_RUN = 85

local CROUCH_OFFSET = Vector3.new(0, -1.5, 0)

-- STATE
local running = false
local crouching = false

local char, hum, root, cam

local function setup(character)
	char = character
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	cam = workspace.CurrentCamera

	hum.WalkSpeed = SPEED_WALK
	cam.FieldOfView = FOV_NORMAL
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end

-- INPUT
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		running = true
	elseif input.KeyCode == Enum.KeyCode.C then
		crouching = not crouching
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		running = false
	end
end)

-- UPDATE LOOP
RunService.RenderStepped:Connect(function()
	if not hum or not cam then return end

	-- movement priority
	if crouching then
		hum.WalkSpeed = SPEED_CROUCH
	elseif running then
		hum.WalkSpeed = SPEED_RUN
	else
		hum.WalkSpeed = SPEED_WALK
	end

	-- FOV
	local targetFOV = running and FOV_RUN or FOV_NORMAL
	cam.FieldOfView += (targetFOV - cam.FieldOfView) * 0.15

	-- crouch camera offset
	if crouching then
		hum.CameraOffset = CROUCH_OFFSET
	else
		hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.new(), 0.15)
	end
end)
