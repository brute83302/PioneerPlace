--[[
    FarmPlotTemplate.lua
    Defines the visual appearance and properties of a farm plot.
]]

local FarmPlotTemplate = {}

function FarmPlotTemplate.create()
    local plot = Instance.new("Model")
    plot.Name = "FarmPlot"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(8, 0.5, 8)
    base.Position = Vector3.new(0, 0.25, 0)
    base.Color = Color3.fromRGB(139, 69, 19) -- Brown
    base.Anchored = true
    base.Parent = plot
    
    -- Designate the base as the primary part for CFrame operations
    plot.PrimaryPart = base
    
    -- Add an attribute to identify this model as a farm plot
    plot:SetAttribute("ObjectType", "FARM_PLOT")
    -- Add an attribute to track the plot's state (e.g., "EMPTY", "GROWING", "GROWN")
    plot:SetAttribute("PlotState", "EMPTY")

    return plot
end

return FarmPlotTemplate 