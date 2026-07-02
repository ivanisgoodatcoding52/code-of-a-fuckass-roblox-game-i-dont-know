local Hitbox = {}

function Hitbox.CreateBox(character, size, offset)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local box = Instance.new("Part")
	box.Size = size
	box.CFrame = root.CFrame * offset
	box.Anchored = true
	box.CanCollide = false
	box.Transparency = 1
	box.Parent = workspace

	local hits = {}

	for _, part in ipairs(workspace:GetPartsInPart(box)) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model ~= character then
			local hum = model:FindFirstChild("Humanoid")
			if hum and not hits[model] then
				hits[model] = true
				hum:TakeDamage(10)
			end
		end
	end

	game:GetService("Debris"):AddItem(box, 0.1)

	return hits
end

return Hitbox
