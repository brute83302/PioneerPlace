--[[
    EnergySystem.lua
    Handles all energy-related logic for players.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- No longer need direct requires. Systems will be injected via initialize().
local GameSystems

local EnergySystem = {}

-- Track neighborhood boost state per player
local boostState = {}

local WorldConstants = require(ReplicatedStorage.Shared.WorldConstants)

local lastSleepTimes = {}
local SLEEP_COOLDOWN = 60 * 10 -- 10 minutes real time

function EnergySystem.initialize(gameSystems)
    GameSystems = gameSystems
end

function EnergySystem.tryHarvest(player, resourceModel)
    -- First, check if the player has enough energy
    local hasEnergy = EnergySystem.consumeEnergy(player, 1) -- Cost to harvest is 1
    if not hasEnergy then
        print(player.Name, "is out of energy. Harvest cancelled.")
        return
    end

    -- Get the resource type from the model's attribute
    local resourceType = resourceModel:GetAttribute("ResourceType")
    if not resourceType then
        warn("Harvested object is missing a 'ResourceType' attribute:", resourceModel.Name)
        return
    end

    -- Special logic for weed: 1/3 chance to drop clover seed, no direct resource
    if resourceType == "WEED" then
        local chance = math.random()
        if chance <= 0.333 then
            local data = GameSystems.PlayerService.getPlayerData(player)
            data.Inventory.CLOVER_SEED = (data.Inventory.CLOVER_SEED or 0) + 1

            -- Notify client inventory update
            local inventoryUpdatedEvent = ReplicatedStorage.Remotes.InventoryUpdated
            inventoryUpdatedEvent:FireClient(player, "CLOVER_SEED", data.Inventory.CLOVER_SEED)

            -- XP for finding seed
            GameSystems.ProgressionSystem.addXP(player, 5)
            -- Optionally reward explosion for seed
            local remotes = ReplicatedStorage:WaitForChild("Remotes")
            local rewardEvent = remotes:FindFirstChild("RewardExplosion")
            if rewardEvent and resourceType ~= "WEED" then
                local pos = resourceModel.PrimaryPart and resourceModel.PrimaryPart.Position or player.Character and player.Character.PrimaryPart.Position or Vector3.new()
                rewardEvent:FireClient(player, pos, "FOOD", 1) -- reuse green icon
            end
        end
    else
        -- Give the player the resources
        GameSystems.ResourceManager.addResource(player, resourceType)
    end

    -- Reward explosion visual
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local rewardEvent = remotes:FindFirstChild("RewardExplosion")
    if rewardEvent and resourceType ~= "WEED" then
        local pos
        if resourceModel.PrimaryPart then
            pos = resourceModel.PrimaryPart.Position
        else
            local bp = resourceModel:FindFirstChildWhichIsA("BasePart")
            pos = bp and bp.Position or player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position or Vector3.new()
        end
        rewardEvent:FireClient(player, pos, resourceType, 1)
    end

    -- Give the player XP for harvesting
    local xpGained = GameSystems.ResourceManager.getXPForResource(resourceType)
    GameSystems.ProgressionSystem.addXP(player, xpGained)

    -- Add the resource to the respawn queue, which also handles destroying it
    GameSystems.RespawnSystem.addToQueue(resourceModel)
end

function EnergySystem.consumeEnergy(player, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return false end

    if data.Energy >= amount then
        data.Energy = data.Energy - amount
        print("Consumed", amount, "energy from", player.Name, ". Remaining:", data.Energy)
        
        -- Notify the client of their new energy total
        local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
        energyUpdatedEvent:FireClient(player, data.Energy, 60)
        
        return true -- Success
    else
        print("Player", player.Name, "does not have enough energy. Required:", amount, "Has:", data.Energy)
        return false -- Not enough energy
    end
end

function EnergySystem.update(player, currentTime)
    local data = GameSystems.PlayerService.getPlayerData(player)
    -- Record last known position for rested bonus logic
    if player.Character and player.Character.PrimaryPart then
        data.LastPosition = player.Character.PrimaryPart.Position
    end

    if not data or data.Energy >= data.MaxEnergy then
        -- Still send boost status if it changed even when energy full
        local currentBoost = EnergySystem.isInNeighborPlot(player)
        if boostState[player] ~= currentBoost then
            boostState[player] = currentBoost
            local boostEvent = ReplicatedStorage.Remotes.NeighborBoostChanged
            boostEvent:FireClient(player, currentBoost)
        end
        return
    end

    local currentBoost = EnergySystem.isInNeighborPlot(player)
    local timeSinceLastGain = currentTime - data.LastEnergyGainTimestamp
    local REGEN_INTERVAL = 60 -- Base time in seconds to gain 1 energy (1 minute)

    -- Neighborhood Boost: being on an online neighbor's plot speeds up regeneration.
    if currentBoost then
        REGEN_INTERVAL = 30 -- 2x faster while visiting a neighbor
    end

    if timeSinceLastGain >= REGEN_INTERVAL then
        local energyToGain = math.floor(timeSinceLastGain / REGEN_INTERVAL)
        data.Energy = math.min(data.Energy + energyToGain, data.MaxEnergy)
        data.LastEnergyGainTimestamp = currentTime

        -- Record last position for Rested bonus
        if player.Character and player.Character.PrimaryPart then
            data.LastPosition = player.Character.PrimaryPart.Position
        end

        print("Player", player.Name, "regenerated", energyToGain, "energy. New total:", data.Energy)

        -- Notify the client of their new energy total
        local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
        -- seconds until next energy tick
        local secondsLeft = REGEN_INTERVAL - (timeSinceLastGain % REGEN_INTERVAL)
        energyUpdatedEvent:FireClient(player, data.Energy, secondsLeft)
    end

    -- Fire boost status if changed
    if boostState[player] ~= currentBoost then
        boostState[player] = currentBoost
        local boostEvent = ReplicatedStorage.Remotes.NeighborBoostChanged
        boostEvent:FireClient(player, currentBoost)
    end
end

function EnergySystem.setEnergy(player, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return end

    data.Energy = math.min(amount, data.MaxEnergy)
    print("ADMIN: Set", player.Name, "'s energy to", data.Energy)

    -- Notify the client of their new energy total
    local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
    energyUpdatedEvent:FireClient(player, data.Energy, 60) -- default full timer
end

function EnergySystem.addEnergy(player, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return end

    data.Energy = math.min(data.Energy + amount, data.MaxEnergy)
    print("Player", player.Name, "gained", amount, "energy. New total:", data.Energy)

    -- Notify the client of their new energy total
    local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
    energyUpdatedEvent:FireClient(player, data.Energy, 0)
end

function EnergySystem.gainEnergyFromFood(player)
    local cost = { FOOD = 10 }
    local hasEnoughFood = GameSystems.ResourceManager.removeResources(player, cost)

    if hasEnoughFood then
        print("Player", player.Name, "ate 10 food.")
        EnergySystem.addEnergy(player, 2) -- Rate: 5 food = 1 energy
    else
        print("Player", player.Name, "does not have enough food to eat.")
        -- TODO: Notify player they don't have enough food
    end
end

function EnergySystem.isInNeighborPlot(player)
    -- Determine if the player is currently standing inside an ONLINE neighbor's plot.
    -- Returns true when the player is within the bounds of a plot that is owned by
    -- someone else who is currently in the server. This grants the Neighborhood Boost.
    if not player.Character or not player.Character.PrimaryPart then return false end
    local pos = player.Character.PrimaryPart.Position

    -- Iterate through all players to compare plot bounds
    for _, other in ipairs(GameSystems.PlayerService.getOnlinePlayers()) do
        if other ~= player then
            local origin = GameSystems.PlotService.getPlotOrigin(other)
            if origin then
                -- Plot bounds using shared constant
                if math.abs(pos.X - origin.X) <= WorldConstants.PLOT_HALF and math.abs(pos.Z - origin.Z) <= WorldConstants.PLOT_HALF then
                    return true
                end
            end
        end
    end
    return false
end

function EnergySystem.sleep(player, bedModel)
    -- Verify ownership – optional: only owner's bed grants energy
    local ownerId = bedModel:GetAttribute("OwnerId")
    if ownerId and ownerId ~= player.UserId then
        warn("Player", player.Name, "attempted to sleep in another's bed.")
        return
    end

    local now = tick()
    local last = lastSleepTimes[player]
    if last and now - last < SLEEP_COOLDOWN then
        local remaining = math.ceil(SLEEP_COOLDOWN - (now - last))
        print("Sleep cooldown not finished:" , remaining .. "s left")
        return
    end

    -- Ensure player is close enough (<= 6 studs)
    if player.Character and player.Character.PrimaryPart and bedModel.PrimaryPart then
        local dist = (player.Character.PrimaryPart.Position - bedModel.PrimaryPart.Position).Magnitude
        if dist > 6 then
            warn("Player", player.Name, "is too far from bed to sleep.")
            return
        end
    end

    lastSleepTimes[player] = now
    EnergySystem.addEnergy(player, 5) -- grant 5 energy per nap

    -- Quest progress
    if GameSystems and GameSystems.QuestSystem then
        GameSystems.QuestSystem.updateQuestProgress(player, "SLEEP_IN_BED", "SLEEP_IN_BED", 1)
    end

    -- Optional: teleport player onto bed
    if player.Character and player.Character.PrimaryPart then
        player.Character:SetPrimaryPartCFrame(bedModel.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
    end

    print(player.Name, "took a nap and regained energy.")

    -- Fire client effect
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local sleepEvent = remotes:FindFirstChild("SleepEffect")
    if sleepEvent then
        sleepEvent:FireClient(player, bedModel.PrimaryPart.Position)
    end
end

-- cleanup when player leaves
local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(p)
    lastSleepTimes[p] = nil
end)

return EnergySystem 