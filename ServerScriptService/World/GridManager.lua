-- ServerScriptService/World/GridManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GridConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GridConfig"))

local ServerScriptService = game:GetService("ServerScriptService")
local PlotManager = require(ServerScriptService:WaitForChild("World"):WaitForChild("PlotManager"))
local PathManager = require(ServerScriptService:WaitForChild("World"):WaitForChild("PathManager"))

local GridManager = {}

-- =========================================================
-- Internal grid state
-- =========================================================

local grid = {}

-- grid[x][z] = { plotType = string, initialized = true }

-- =========================================================
-- Ensure grid table exists
-- =========================================================

function GridManager:EnsureCell(x, z)
	if not grid[x] then
		grid[x] = {}
	end

	if not grid[x][z] then
		grid[x][z] = {
			initialized = false,
			plotType = nil
		}
	end

	return grid[x][z]
end

-- =========================================================
-- Check if cell is already generated
-- =========================================================

function GridManager:IsGenerated(x, z)
	local cell = self:EnsureCell(x, z)
	return cell.initialized
end

-- =========================================================
-- Mark cell as generated
-- =========================================================

function GridManager:SetGenerated(x, z, plotType)
	local cell = self:EnsureCell(x, z)

	cell.initialized = true
	cell.plotType = plotType
end

-- =========================================================
-- Get cell data
-- =========================================================

function GridManager:GetCell(x, z)
	return self:EnsureCell(x, z)
end

-- =========================================================
-- Generate a single cell (plot + roads)
-- =========================================================

function GridManager:GenerateCell(x, z, plotType)
	if self:IsGenerated(x, z) then
		return
	end

	-- 1. Spawn plot
	PlotManager:SpawnPlot(x, z, plotType)

	-- 2. Build roads around it
	PathManager:BuildRoadsAroundPlot(x, z)

	-- 3. Mark as generated
	self:SetGenerated(x, z, plotType)
end

-- =========================================================
-- Generate a rectangular area
-- =========================================================

function GridManager:GenerateArea(minX, maxX, minZ, maxZ, plotType)
	for x = minX, maxX do
		for z = minZ, maxZ do
			self:GenerateCell(x, z, plotType or "Plot_A")
		end
	end
end

-- =========================================================
-- Get neighbors (useful for future logic, still grid-only)
-- =========================================================

function GridManager:GetNeighbors(x, z)
	return {
		{ x + 1, z },
		{ x - 1, z },
		{ x, z + 1 },
		{ x, z - 1 }
	}
end

-- =========================================================
-- Clear world state (does not destroy instances directly here)
-- =========================================================

function GridManager:Reset()
	grid = {}
end

return GridManager
