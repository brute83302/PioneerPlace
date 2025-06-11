--[[
    FarmingSystem.lua
    Manages the state and growth of all crops on farm plots.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CROP_CONFIG = require(ReplicatedStorage.Shared.CropConfig)
local CropTemplate = require(ReplicatedStorage.Assets.templates.crops.CropTemplate)

local FarmingSystem = {}
local GameSystems

function FarmingSystem.initialize(gameSystems)
    GameSystems = gameSystems
end

-- This function will now be called by a dedicated remote event
function FarmingSystem.plant(player, plot, cropType)
    local state = plot:GetAttribute("PlotState")
    if state ~= "EMPTY" then
        warn(player.Name, "tried to plant on a plot that wasn't empty. State:", state)
        return
    end

    print("Planting", cropType, "for player", player.Name)
    plot:SetAttribute("PlotState", "GROWING")
    plot:SetAttribute("CropType", cropType)
    plot:SetAttribute("GrowthStartTime", tick())

    -- Create and place the visual sprout
    local sprout = CropTemplate.createSprout()
    sprout.Position = plot.PrimaryPart.Position + Vector3.new(0, 1, 0)
    sprout.Parent = plot
end

function FarmingSystem.harvest(player, plot)
    local state = plot:GetAttribute("PlotState")
    if state ~= "GROWN" then
        warn(player.Name, "tried to harvest a plot that wasn't grown. State:", state)
        return
    end

    local cropType = plot:GetAttribute("CropType")
    if not cropType then return end

    local config = CROP_CONFIG[cropType]
    print("Harvesting", cropType, "for player", player.Name)
    
    GameSystems.ResourceManager.addResource(player, "FOOD", config.Yield)
    
    plot:SetAttribute("PlotState", "EMPTY")
    plot:SetAttribute("CropType", nil)
    plot:SetAttribute("GrowthStartTime", nil)

    for _, child in ipairs(plot:GetChildren()) do
        if child.Name == "CropSprout" or child.Name == "GrownCrop" then
            child:Destroy()
        end
    end
end

-- This function will be called by the main game loop
function FarmingSystem.update(currentTime)
    for _, plot in ipairs(workspace:GetChildren()) do
        if plot:GetAttribute("ObjectType") == "FARM_PLOT" and plot:GetAttribute("PlotState") == "GROWING" then
            local startTime = plot:GetAttribute("GrowthStartTime")
            local cropType = plot:GetAttribute("CropType")
            local config = CROP_CONFIG[cropType]

            if currentTime - startTime >= config.GrowthTime then
                plot:SetAttribute("PlotState", "GROWN")
                print("A", cropType, "plant has finished growing.")
                
                -- Remove the sprout
                local sprout = plot:FindFirstChild("CropSprout")
                if sprout then
                    sprout:Destroy()
                end

                -- Create and place the grown crop
                local grownCrop = CropTemplate.createGrownCrop()
                grownCrop.Position = plot.PrimaryPart.Position + Vector3.new(0, 2, 0)
                grownCrop.Parent = plot
            end
        end
    end
end

return FarmingSystem 