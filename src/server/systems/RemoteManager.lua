--[[
    RemoteManager.lua
    Handles the creation and connection of RemoteEvents.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteManager = {}
local GameSystems -- Declare GameSystems here, to be set in initialize

function RemoteManager.initialize(gameSystems) -- Renamed from setup
    GameSystems = gameSystems -- Store the reference to GameSystems

    -- This system no longer needs to store references to other systems,
    -- as it will access them dynamically when an event is fired.

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

    -- Rested bonus event
    local restedBonusEvent = remotesFolder:FindFirstChild("RestedBonusGranted")
    if not restedBonusEvent then
        restedBonusEvent = Instance.new("RemoteEvent")
        restedBonusEvent.Name = "RestedBonusGranted"
        restedBonusEvent.Parent = remotesFolder
    end

    -- Quest system events
    local questAssignedEvent = remotesFolder:FindFirstChild("QuestAssigned")
    if not questAssignedEvent then
        questAssignedEvent = Instance.new("RemoteEvent")
        questAssignedEvent.Name = "QuestAssigned"
        questAssignedEvent.Parent = remotesFolder
    end

    local questProgressEvent = remotesFolder:FindFirstChild("QuestProgressUpdated")
    if not questProgressEvent then
        questProgressEvent = Instance.new("RemoteEvent")
        questProgressEvent.Name = "QuestProgressUpdated"
        questProgressEvent.Parent = remotesFolder
    end

    local questCompletedEvent = remotesFolder:FindFirstChild("QuestCompleted")
    if not questCompletedEvent then
        questCompletedEvent = Instance.new("RemoteEvent")
        questCompletedEvent.Name = "QuestCompleted"
        questCompletedEvent.Parent = remotesFolder
    end

    -- Crafting events
    local requestCraftItemEvent = remotesFolder:FindFirstChild("RequestCraftItem")
    if not requestCraftItemEvent then
        requestCraftItemEvent = Instance.new("RemoteEvent")
        requestCraftItemEvent.Name = "RequestCraftItem"
        requestCraftItemEvent.Parent = remotesFolder
    end

    local craftingResultEvent = remotesFolder:FindFirstChild("CraftingResult")
    if not craftingResultEvent then
        craftingResultEvent = Instance.new("RemoteEvent")
        craftingResultEvent.Name = "CraftingResult"
        craftingResultEvent.Parent = remotesFolder
    end

    -- Inventory sync/updates
    local inventoryUpdatedEvent = remotesFolder:FindFirstChild("InventoryUpdated")
    if not inventoryUpdatedEvent then
        inventoryUpdatedEvent = Instance.new("RemoteEvent")
        inventoryUpdatedEvent.Name = "InventoryUpdated"
        inventoryUpdatedEvent.Parent = remotesFolder
    end

    -- Tool equip events
    local requestEquipToolEvent = remotesFolder:FindFirstChild("RequestEquipTool")
    if not requestEquipToolEvent then
        requestEquipToolEvent = Instance.new("RemoteEvent")
        requestEquipToolEvent.Name = "RequestEquipTool"
        requestEquipToolEvent.Parent = remotesFolder
    end

    local toolEquippedEvent = remotesFolder:FindFirstChild("ToolEquipped")
    if not toolEquippedEvent then
        toolEquippedEvent = Instance.new("RemoteEvent")
        toolEquippedEvent.Name = "ToolEquipped"
        toolEquippedEvent.Parent = remotesFolder
    end

    local requestSellItemEvent = remotesFolder:FindFirstChild("RequestSellItem")
    if not requestSellItemEvent then
        requestSellItemEvent = Instance.new("RemoteEvent")
        requestSellItemEvent.Name = "RequestSellItem"
        requestSellItemEvent.Parent = remotesFolder
    end

    local requestCookItemEvent = remotesFolder:FindFirstChild("RequestCookItem")
    if not requestCookItemEvent then
        requestCookItemEvent = Instance.new("RemoteEvent")
        requestCookItemEvent.Name = "RequestCookItem"
        requestCookItemEvent.Parent = remotesFolder
    end

    local requestEatMealEvent = remotesFolder:FindFirstChild("RequestEatMeal")
    if not requestEatMealEvent then
        requestEatMealEvent = Instance.new("RemoteEvent")
        requestEatMealEvent.Name = "RequestEatMeal"
        requestEatMealEvent.Parent = remotesFolder
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

    -- Event to signal that the server has loaded all player data and is ready
    local serverInitializedEvent = remotesFolder:FindFirstChild("ServerInitialized")
    if not serverInitializedEvent then
        serverInitializedEvent = Instance.new("RemoteEvent")
        serverInitializedEvent.Name = "ServerInitialized"
        serverInitializedEvent.Parent = remotesFolder
    end

    -- Event for deleting a placed object
    local requestDeleteObjectEvent = remotesFolder:FindFirstChild("RequestDeleteObject")
    if not requestDeleteObjectEvent then
        requestDeleteObjectEvent = Instance.new("RemoteEvent")
        requestDeleteObjectEvent.Name = "RequestDeleteObject"
        requestDeleteObjectEvent.Parent = remotesFolder
    end

    -- Event for sleeping in bed
    local requestSleepEvent = remotesFolder:FindFirstChild("RequestSleep")
    if not requestSleepEvent then
        requestSleepEvent = Instance.new("RemoteEvent")
        requestSleepEvent.Name = "RequestSleep"
        requestSleepEvent.Parent = remotesFolder
    end

    -- Event when neighborhood boost becomes active/inactive
    local neighborBoostEvent = remotesFolder:FindFirstChild("NeighborBoostChanged")
    if not neighborBoostEvent then
        neighborBoostEvent = Instance.new("RemoteEvent")
        neighborBoostEvent.Name = "NeighborBoostChanged"
        neighborBoostEvent.Parent = remotesFolder
    end

    -- Weather change event
    local weatherChangedEvent = remotesFolder:FindFirstChild("WeatherChanged")
    if not weatherChangedEvent then
        weatherChangedEvent = Instance.new("RemoteEvent")
        weatherChangedEvent.Name = "WeatherChanged"
        weatherChangedEvent.Parent = remotesFolder
    end

    -- Sleep effect event
    local sleepEffectEvent = remotesFolder:FindFirstChild("SleepEffect")
    if not sleepEffectEvent then
        sleepEffectEvent = Instance.new("RemoteEvent")
        sleepEffectEvent.Name = "SleepEffect"
        sleepEffectEvent.Parent = remotesFolder
    end

    -- Reward explosion event
    local rewardExplosionEvent = remotesFolder:FindFirstChild("RewardExplosion")
    if not rewardExplosionEvent then
        rewardExplosionEvent = Instance.new("RemoteEvent")
        rewardExplosionEvent.Name = "RewardExplosion"
        rewardExplosionEvent.Parent = remotesFolder
    end

    -- Hit spark event (single-hit feedback)
    local hitSparkEvent = remotesFolder:FindFirstChild("HitSpark")
    if not hitSparkEvent then
        hitSparkEvent = Instance.new("RemoteEvent")
        hitSparkEvent.Name = "HitSpark"
        hitSparkEvent.Parent = remotesFolder
    end

    -- Collection found event
    local collectionFoundEvent = remotesFolder:FindFirstChild("CollectionFound")
    if not collectionFoundEvent then
        collectionFoundEvent = Instance.new("RemoteEvent")
        collectionFoundEvent.Name = "CollectionFound"
        collectionFoundEvent.Parent = remotesFolder
    end

    -- Events for Chicken Coop
    local requestFeedChicken = remotesFolder:FindFirstChild("RequestFeedChicken")
    if not requestFeedChicken then
        requestFeedChicken = Instance.new("RemoteEvent")
        requestFeedChicken.Name = "RequestFeedChicken"
        requestFeedChicken.Parent = remotesFolder
    end

    local requestCollectEggs = remotesFolder:FindFirstChild("RequestCollectEggs")
    if not requestCollectEggs then
        requestCollectEggs = Instance.new("RemoteEvent")
        requestCollectEggs.Name = "RequestCollectEggs"
        requestCollectEggs.Parent = remotesFolder
    end

    -- Teleport to merchant request
    local teleportMerchantEvent = remotesFolder:FindFirstChild("RequestTeleportToMerchant")
    if not teleportMerchantEvent then
        teleportMerchantEvent = Instance.new("RemoteEvent")
        teleportMerchantEvent.Name = "RequestTeleportToMerchant"
        teleportMerchantEvent.Parent = remotesFolder
    end

    -- Event for building placement confirmation from client (ghost placement)
    local confirmBuildEvent = remotesFolder:FindFirstChild("ConfirmBuildRequest")
    if not confirmBuildEvent then
        confirmBuildEvent = Instance.new("RemoteEvent")
        confirmBuildEvent.Name = "ConfirmBuildRequest"
        confirmBuildEvent.Parent = remotesFolder
    end

    getPlayerDataEvent.OnServerInvoke = function(player)
        print("Received request for initial data from", player.Name)
        -- Use the stored GameSystems reference
        return GameSystems.PlayerService.getPlayerData(player)
    end

    -- The client fires this to request some kind of action on a model
    requestActionEvent.OnServerEvent:Connect(function(player, model)
        -- Validate first to avoid nil errors
        if not model or not model:IsA("Model") or not model:IsDescendantOf(Workspace) then
            -- Silently ignore bad input instead of spamming the log
            return
        end

        print("Received RequestAction for model:", model.Name)
        
        -- WORKAROUND: If the player clicks the visible "GrownCrop" model, we know they mean to harvest its parent plot.
        if model.Name == "GrownCrop" then
            local plot = model.Parent
            if plot and plot:GetAttribute("ObjectType") == "FARM_PLOT" then
                GameSystems.FarmingSystem.harvest(player, plot)
                return -- Action handled, no need to continue.
            end
        end

        local objectType = model:GetAttribute("ObjectType")

        if objectType == "RESOURCE_NODE" then
            GameSystems.EnergySystem.tryHarvest(player, model)
        elseif objectType == "FARM_PLOT" then
            -- When a farm plot is clicked directly, it can only be to harvest
            GameSystems.FarmingSystem.harvest(player, model)
        elseif objectType == "GROWN_CROP" then
             GameSystems.FarmingSystem.harvest(player, model.Parent)
        elseif objectType == "WITHERED_CROP" then
            GameSystems.FarmingSystem.clearWithered(player, model)
        elseif objectType == "TENT" then
            -- Active regeneration: allow player to take a quick nap for +2 energy every 5 min
            local lastNap = model:GetAttribute("LastNapTimestamp") or 0
            if tick() - lastNap >= 300 then -- 5-minute cooldown
                GameSystems.EnergySystem.addEnergy(player, 2)
                model:SetAttribute("LastNapTimestamp", tick())
                print(player.Name, "took a nap in their tent and gained 2 energy.")
            else
                local remaining = 300 - math.floor(tick() - lastNap)
                print("Nap on cooldown for", remaining, "seconds.")
            end
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

    -- Client requests crafting an item at a crafting bench
    requestCraftItemEvent.OnServerEvent:Connect(function(player, recipeId)
        GameSystems.CraftingSystem.craft(player, recipeId)
    end)

    requestEquipToolEvent.OnServerEvent:Connect(function(player, toolId)
        GameSystems.ToolSystem.equipTool(player, toolId)
    end)

    requestSellItemEvent.OnServerEvent:Connect(function(player, itemId, amount)
        GameSystems.SellingSystem.sell(player, itemId, amount)
    end)

    requestCookItemEvent.OnServerEvent:Connect(function(player, recipeId)
        GameSystems.CookingSystem.cook(player, recipeId)
    end)

    requestEatMealEvent.OnServerEvent:Connect(function(player)
        GameSystems.CookingSystem.consumeMeal(player)
    end)

    requestDeleteObjectEvent.OnServerEvent:Connect(function(player, model)
        GameSystems.BuildingSystem.deleteStructure(player, model)
    end)

    -- Connect sleep handling
    requestSleepEvent.OnServerEvent:Connect(function(player, bedModel)
        if bedModel and bedModel:IsA("Model") and bedModel:GetAttribute("ObjectType") == "BED" then
            GameSystems.EnergySystem.sleep(player, bedModel)
        end
    end)

    -- Chicken coop handlers
    requestFeedChicken.OnServerEvent:Connect(function(player, coopModel)
        GameSystems.AnimalSystem.feed(player, coopModel)
    end)

    requestCollectEggs.OnServerEvent:Connect(function(player, coopModel)
        GameSystems.AnimalSystem.collect(player, coopModel)
    end)

    print("RemoteManager initialized.")
end

return RemoteManager 