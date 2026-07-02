-- ServerScriptService/World/PathManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GridConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GridConfig"))

local PathManager = {}

-- Storage for created path parts (optional tracking)
local activePaths = {}

-- =========================================================
-- Internal utility: ensure folder exists
-- =========================================================

local function getPathFolder()
	local world = workspace:WaitForChild("GeneratedWorld")
	local folder = world:FindFirstChild("Paths")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Paths"
		folder.Parent = world
	end

	return folder
end

-- =========================================================
-- Create a road segment between two world positions
-- =========================================================

function PathManager:CreateRoadSegment(posA, posB)
	local folder = getPathFolder()

	local direction = (posB - posA)
	local distance = direction.Magnitude

	if distance == 0 then return end

	local road = Instance.new("Part")
	road.Anchored = true
	road.CanCollide = true
	road.Size = Vector3.new(GridConfig.ROAD_WIDTH, 1, distance)
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(40, 40, 40)

	road.CFrame = CFrame.new(posA:Lerp(posB, 0.5), posB)

	road.Parent = folder

	table.insert(activePaths, road)

	return road
end

-- =========================================================
-- Create intersection marker at a grid node
-- =========================================================

function PathManager:CreateIntersection(x, z)
	local folder = getPathFolder()

	local pos = GridConfig:GridToWorld(x, z)

	local node = Instance.new("Part")
	node.Anchored = true
	node.CanCollide = false
	node.Size = Vector3.new(2, 1, 2)
	node.Transparency = 1
	node.Name = "Node_" .. x .. "_" .. z

	node.Position = pos
	node.Parent = folder

	return node
end

-- =========================================================
-- Connect two grid intersections (horizontal/vertical only)
-- =========================================================

function PathManager:ConnectNodes(x1, z1, x2, z2)
	local p1 = GridConfig:GridToWorld(x1, z1)
	local p2 = GridConfig:GridToWorld(x2, z2)

	return self:CreateRoadSegment(p1, p2)
end

-- =========================================================
-- Build roads around a plot cell
-- Creates a cross-road pattern around the plot
-- =========================================================

function PathManager:BuildRoadsAroundPlot(x, z)
	-- intersection at plot corners (logical grid nodes)
	self:CreateIntersection(x, z)

	-- connect to right neighbor
	self:ConnectNodes(x, z, x + 1, z)

	-- connect to bottom neighbor
	self:ConnectNodes(x, z, x, z + 1)
end

-- =========================================================
-- Clear all paths (debug/reset)
-- =========================================================

function PathManager:ClearAll()
	for _, part in ipairs(activePaths) do
		if part then
			part:Destroy()
		end
	end

	activePaths = {}
end

return PathManager
