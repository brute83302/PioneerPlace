--[[
    RemoteManager.lua
    Handles the creation and connection of RemoteEvents.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteManager = {}

function RemoteManager.setup(GameSystems) -- Accept GameSystems as an argument
    -- Get required systems from the passed-in table
    local PlayerService = GameSystems.PlayerService
    local BuildingSystem = GameSystems.BuildingSystem
    local ResourceManager = GameSystems.ResourceManager
    local EnergySystem = GameSystems.EnergySystem

    -- Find or create the Remotes folder
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    -- Find or create the RemoteEvent
    local requestAssetEvent = remotesFolder:FindFirstChild("RequestAssetCreation")
    if not requestAssetEvent then
        requestAssetEvent = Instance.new("RemoteEvent")
        requestAssetEvent.Name = "RequestAssetCreation"
        requestAssetEvent.Parent = remotesFolder
    end

    -- Find or create the event for updating client UIs
    local resourceUpdatedEvent = remotesFolder:FindFirstChild("ResourceUpdated")
    if not resourceUpdatedEvent then
        resourceUpdatedEvent = Instance.new("RemoteEvent")
        resourceUpdatedEvent.Name = "ResourceUpdated"
        resourceUpdatedEvent.Parent = remotesFolder
    end

    -- Find or create the event for building actions
    local requestBuildEvent = remotesFolder:FindFirstChild("RequestBuildAction")
    if not requestBuildEvent then
        requestBuildEvent = Instance.new("RemoteEvent")
        requestBuildEvent.Name = "RequestBuildAction"
        requestBuildEvent.Parent = remotesFolder
    end

    local energyUpdatedEvent = remotesFolder:FindFirstChild("EnergyUpdated")
    if not energyUpdatedEvent then
        energyUpdatedEvent = Instance.new("RemoteEvent")
        energyUpdatedEvent.Name = "EnergyUpdated"
        energyUpdatedEvent.Parent = remotesFolder
    end

    -- Events for progression UI
    local xpUpdatedEvent = remotesFolder:FindFirstChild("XPUpdated")
    if not xpUpdatedEvent then
        xpUpdatedEvent = Instance.new("RemoteEvent")
        xpUpdatedEvent.Name = "XPUpdated"
        xpUpdatedEvent.Parent = remotesFolder
    end

    local playerLeveledUpEvent = remotesFolder:FindFirstChild("PlayerLeveledUp")
    if not playerLeveledUpEvent then
        playerLeveledUpEvent = Instance.new("RemoteEvent")
        playerLeveledUpEvent.Name = "PlayerLeveledUp"
        playerLeveledUpEvent.Parent = remotesFolder
    end

    -- RemoteFunction for the client to get its initial data
    local getPlayerDataEvent = remotesFolder:FindFirstChild("GetPlayerData")
    if not getPlayerDataEvent then
        getPlayerDataEvent = Instance.new("RemoteFunction")
        getPlayerDataEvent.Name = "GetPlayerData"
        getPlayerDataEvent.Parent = remotesFolder
    end

    -- Event for generic model interactions (harvesting, farming, etc.)
    local requestActionEvent = remotesFolder:FindFirstChild("RequestAction")
    if not requestActionEvent then
        requestActionEvent = Instance.new("RemoteEvent")
        requestActionEvent.Name = "RequestAction"
        requestActionEvent.Parent = remotesFolder
    end

    -- Event for eating food
    local requestEatFoodEvent = remotesFolder:FindFirstChild("RequestEatFood")
    if not requestEatFoodEvent then
        requestEatFoodEvent = Instance.new("RemoteEvent")
        requestEatFoodEvent.Name = "RequestEatFood"
        requestEatFoodEvent.Parent = remotesFolder
    end

    -- Event for planting a specific crop
    local requestPlantCropEvent = remotesFolder:FindFirstChild("RequestPlantCrop")
    if not requestPlantCropEvent then
        requestPlantCropEvent = Instance.new("RemoteEvent")
        requestPlantCropEvent.Name = "RequestPlantCrop"
        requestPlantCropEvent.Parent = remotesFolder
    end

    getPlayerDataEvent.OnServerInvoke = function(player)
        print("Received request for initial data from", player.Name)
        return PlayerService.getPlayerData(player)
    end

    -- The client fires this to request some kind of action on a model
    requestActionEvent.OnServerEvent:Connect(function(player, model)
        print("Received RequestAction for model:", model.Name)
        
        -- Basic validation to make sure what the client sent is a real model
        if not model or not model:IsA("Model") or model.Parent ~= Workspace then
            warn("Invalid model sent by client. Action rejected.")
            return
        end

        local objectType = model:GetAttribute("ObjectType")

        if objectType == "RESOURCE_NODE" then
            GameSystems.EnergySystem.tryHarvest(player, model)
        elseif objectType == "FARM_PLOT" then
            -- When a farm plot is clicked directly, it can only be to harvest
            GameSystems.FarmingSystem.harvest(player, model)
        else
            warn("Player requested action on unknown object type:", objectType)
        end
    end)

    -- The client fires this to build a structure
    requestBuildEvent.OnServerEvent:Connect(function(player, buildingType)
        GameSystems.BuildingSystem.onBuildRequest(player, buildingType)
    end)

    requestEatFoodEvent.OnServerEvent:Connect(function(player)
        GameSystems.EnergySystem.gainEnergyFromFood(player)
    end)

    requestPlantCropEvent.OnServerEvent:Connect(function(player, plot, cropType)
        GameSystems.FarmingSystem.plant(player, plot, cropType)
    end)

    print("RemoteManager setup complete.")
end

return RemoteManager 