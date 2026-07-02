-- ServerScriptService/World/PlotManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GridConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GridConfig"))
local PlotFolder = ReplicatedStorage:WaitForChild("PlotAssets"):WaitForChild("Plots")

local PlotManager = {}

-- Internal storage for spawned plots
local activePlots = {}

-- =========================================================
-- Select a plot template
-- =========================================================

function PlotManager:GetPlotTemplate(plotType)
	local template = PlotFolder:FindFirstChild(plotType)
	return template
end

-- =========================================================
-- Place a plot at a grid coordinate
-- =========================================================

function PlotManager:SpawnPlot(x, z, plotType, parentFolder)
	parentFolder = parentFolder or workspace:FindFirstChild("GeneratedWorld"):FindFirstChild("Plots")

	if activePlots[x] == nil then
		activePlots[x] = {}
	end

	-- Prevent duplicate spawning
	if activePlots[x][z] then
		return activePlots[x][z]
	end

	local template = self:GetPlotTemplate(plotType)
	if not template then
		warn("Plot type not found:", plotType)
		return nil
	end

	local plot = template:Clone()
	plot:SetAttribute("GridX", x)
	plot:SetAttribute("GridZ", z)
	plot:SetAttribute("PlotType", plotType)

	local position = GridConfig:GridToWorld(x, z)
	plot:PivotTo(CFrame.new(position))

	plot.Parent = parentFolder

	activePlots[x][z] = plot

	return plot
end

-- =========================================================
-- Remove a plot
-- =========================================================

function PlotManager:DestroyPlot(x, z)
	if activePlots[x] and activePlots[x][z] then
		activePlots[x][z]:Destroy()
		activePlots[x][z] = nil
	end
end

-- =========================================================
-- Get plot at coordinate
-- =========================================================

function PlotManager:GetPlot(x, z)
	if activePlots[x] then
		return activePlots[x][z]
	end
	return nil
end

-- =========================================================
-- Check if plot exists
-- =========================================================

function PlotManager:IsOccupied(x, z)
	return self:GetPlot(x, z) ~= nil
end

-- =========================================================
-- Get all active plots
-- =========================================================

function PlotManager:GetAllPlots()
	return activePlots
end

-- =========================================================
-- Clear all plots (useful for resets/testing)
-- =========================================================

function PlotManager:ClearAll()
	for x, row in pairs(activePlots) do
		for z, plot in pairs(row) do
			if plot then
				plot:Destroy()
			end
		end
	end

	activePlots = {}
end

return PlotManager
