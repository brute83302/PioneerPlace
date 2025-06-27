--[[
    FarmingSystem.lua
    Handles all logic related to planting, growing, and harvesting crops.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)
local CropModels = require(ReplicatedStorage.Assets.CropModels)

-- This will be the template for the fully grown, harvestable crop model.
-- We require it once and clone it as needed.
local GROWN_CROP_TEMPLATE = CropModels.createGrownCrop()
local WITHERED_CROP_TEMPLATE = CropModels.createWitheredCrop()

local FarmingSystem = {}

-- Forward declare the GameSystems table
local GameSystems

-- Table to keep track of all active farm plots in the world
local activePlots = {}

function FarmingSystem.initialize(gameSystems)
    GameSystems = gameSystems
    -- Find all farm plots that already exist in the workspace when the game starts
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Model") and instance:GetAttribute("ObjectType") == "FARM_PLOT" then
            table.insert(activePlots, instance)
        end
    end
    print("FarmingSystem initialized. Found", #activePlots, "active farm plots.")
end

function FarmingSystem.registerPlot(plot)
    if plot and plot:IsA("Model") and plot:GetAttribute("ObjectType") == "FARM_PLOT" then
        table.insert(activePlots, plot)
        print("A new farm plot has been registered with the FarmingSystem.")
    else
        warn("FarmingSystem.registerPlot was called with an invalid plot object.")
    end
end

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

    -- Create and place the visual sprout FIRST to ensure it always appears
    local sprout = CropConfig.createSprout()
    local basePart = plot:FindFirstChild("Base")
    if not basePart then
        warn("Could not find 'Base' part in farm plot:", plot)
        if sprout then sprout:Destroy() end
        return
    end
    sprout.Position = basePart.Position + Vector3.new(0, 1, 0)
    sprout.Parent = plot

    -- Check for seed requirement
    if cropType == "APPLE_TREE" then
        local data = GameSystems.PlayerService.getPlayerData(player)
        if (data.Inventory.APPLE_SEED or 0) <= 0 then
            warn(player.Name, "does not have Apple Seeds to plant.")
            return
        end
        data.Inventory.APPLE_SEED -= 1
        ReplicatedStorage.Remotes.InventoryUpdated:FireClient(player, "APPLE_SEED", data.Inventory.APPLE_SEED)
    elseif cropType == "CLOVER" then
        local data = GameSystems.PlayerService.getPlayerData(player)
        if (data.Inventory.CLOVER_SEED or 0) <= 0 then
            warn(player.Name, "does not have Clover Seeds to plant.")
            return
        end
        data.Inventory.CLOVER_SEED -= 1
        ReplicatedStorage.Remotes.InventoryUpdated:FireClient(player, "CLOVER_SEED", data.Inventory.CLOVER_SEED)
    end

    -- Update planting quests AFTER the visual has been created
    GameSystems.QuestSystem.updateQuestProgress(player, "PLANT_FIRST_CROP", "PLANT_CROP", 1)

    -- Social Boost: reward player for helping neighbors (up to 5 times daily)
    local ownerId = plot:GetAttribute("OwnerId")
    if ownerId and ownerId ~= player.UserId then
        if GameSystems.PlayerService.canGrantHelpReward(player) then
            GameSystems.PlayerService.recordHelpTask(player)
            GameSystems.EnergySystem.addEnergy(player, 2)
            print(player.Name, "received neighbor-help energy bonus.")
        end
    end
end

function FarmingSystem.harvest(player, plot)
    local state = plot:GetAttribute("PlotState")
    if state ~= "READY" then
        warn("Player", player.Name, "tried to harvest a plot that wasn't ready. State:", state)
        return
    end
    
    local cropType = plot:GetAttribute("CropType")
    local cropData = CropConfig[cropType]
    if not cropData then
        warn("Could not find crop data for type:", cropType)
        return
    end
    
    -- Determine which resource to grant
    local resourceKey = cropData.OutputResource or cropType
    GameSystems.ResourceManager.addResource(player, resourceKey, cropData.Yield)
    GameSystems.ProgressionSystem.addXP(player, 10) -- 10 XP for any harvest

    -- Send reward explosion event to client for visual effect
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local rewardEvent = remotes:FindFirstChild("RewardExplosion")
    if rewardEvent then
        local basePart = plot:FindFirstChild("Base")
        local pos = basePart and basePart.Position or plot.PrimaryPart and plot.PrimaryPart.Position or Vector3.new()
        rewardEvent:FireClient(player, pos, resourceKey, cropData.Yield)
    end

    -- Clean up the grown crop model
    local grownCrop = plot:FindFirstChild("GrownCrop")
    if grownCrop then
        grownCrop:Destroy()
    end
    
    -- Reset the plot
    plot:SetAttribute("PlotState", "EMPTY")
    plot:SetAttribute("CropType", nil)
    plot:SetAttribute("GrowthStartTime", nil)
    plot:SetAttribute("WitherStartTime", nil)
    
    -- Quest progress: harvest crops quest
    GameSystems.QuestSystem.updateQuestProgress(player, "HARVEST_CROPS", "HARVEST_CROP", 1)

    print("Player", player.Name, "harvested", cropType, "from plot.")
end

function FarmingSystem.clearWithered(player, model)
    local plot = model.Parent
    if not plot or plot:GetAttribute("ObjectType") ~= "FARM_PLOT" then
        warn("Could not find parent plot for withered crop:", model)
        return
    end

    print("Clearing withered crop for player", player.Name)
    model:Destroy()
    
    -- Reset the plot attributes
    plot:SetAttribute("PlotState", "EMPTY")
    plot:SetAttribute("CropType", nil)
    plot:SetAttribute("GrowthStartTime", nil)
    plot:SetAttribute("WitherStartTime", nil)

    GameSystems.ProgressionSystem.addXP(player, 2) -- Small XP reward for cleaning up
end

-- This is the main game loop function for the farming system
function FarmingSystem.update(currentTime)
    for i = #activePlots, 1, -1 do
        local plot = activePlots[i]
        -- Check if plot is still valid
        if not plot.Parent then
            table.remove(activePlots, i)
            continue
        end

        local state = plot:GetAttribute("PlotState")
        
        if state == "GROWING" then
            local cropType = plot:GetAttribute("CropType")
            local cropData = CropConfig[cropType]
            local startTime = plot:GetAttribute("GrowthStartTime")
            
            -- Weather-based growth acceleration: crops grow 25% faster when raining
            local weatherMultiplier = 1
            if GameSystems and GameSystems.WorldService and GameSystems.WorldService.getCurrentWeather then
                local weather = GameSystems.WorldService.getCurrentWeather()
                if weather == "RAIN" then
                    weatherMultiplier = 0.75 -- 25% faster
                end
            end
            local requiredGrowthTime = cropData and cropData.GrowthTime and (cropData.GrowthTime * weatherMultiplier) or nil
            
            if cropData and startTime and requiredGrowthTime and (currentTime - startTime >= requiredGrowthTime) then
                print("A", cropType, "plant has finished growing.")
                
                -- Remove the sprout
                local sprout = plot:FindFirstChild("Sprout")
                if sprout then sprout:Destroy() end
                
                -- Create the grown crop
                local grownCrop = GROWN_CROP_TEMPLATE:Clone()
                grownCrop.Name = "GrownCrop"
                grownCrop:SetAttribute("ObjectType", "GROWN_CROP")
                
                local basePart = plot:FindFirstChild("Base")
                if basePart then
                    local targetCFrame = basePart.CFrame * CFrame.new(0, 2, 0)
                    grownCrop:SetPrimaryPartCFrame(targetCFrame)
                    grownCrop.Parent = plot
                    
                    plot:SetAttribute("PlotState", "READY")
                    plot:SetAttribute("WitherStartTime", currentTime) -- The wither clock starts now
                else
                    warn("Could not find Base part to position grown crop on plot:", plot)
                    grownCrop:Destroy() -- Cleanup
                end
            end
        elseif state == "READY" then
            local cropType = plot:GetAttribute("CropType")
            local cropData = CropConfig[cropType]
            local witherStartTime = plot:GetAttribute("WitherStartTime")
            
            if cropData and witherStartTime and (currentTime - witherStartTime >= cropData.WitherTime) then
                print("A", cropType, "plant has withered.")
                
                -- Remove the grown crop
                local grownCrop = plot:FindFirstChild("GrownCrop")
                if grownCrop then grownCrop:Destroy() end
                
                -- Create the withered crop
                local witheredCrop = WITHERED_CROP_TEMPLATE:Clone()
                witheredCrop:SetAttribute("ObjectType", "WITHERED_CROP")

                local basePart = plot:FindFirstChild("Base")
                if basePart then
                    local targetCFrame = basePart.CFrame * CFrame.new(0, 2, 0)
                    witheredCrop:SetPrimaryPartCFrame(targetCFrame)
                    witheredCrop.Parent = plot
                    
                    plot:SetAttribute("PlotState", "WITHERED")
                else
                    warn("Could not find Base part to position withered crop on plot:", plot)
                    witheredCrop:Destroy() -- Cleanup
                end
            end
        end
    end
end

return FarmingSystem
