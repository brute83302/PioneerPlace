--[[
    EnergySystem.lua
    Handles all energy-related logic for players.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- No longer need direct requires. Systems will be injected via initialize().
local PlayerService
local ResourceManager

local EnergySystem = {}

function EnergySystem.initialize(gameSystems)
    PlayerService = gameSystems.PlayerService
    ResourceManager = gameSystems.ResourceManager
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

    -- Give the player the resources
    ResourceManager.addResource(player, resourceType)

    -- Destroy the resource
    print("Successfully harvested and destroyed", resourceModel.Name)
    resourceModel:Destroy()
end

function EnergySystem.consumeEnergy(player, amount)
    local data = PlayerService.getPlayerData(player)
    if not data then return false end

    if data.Energy >= amount then
        data.Energy = data.Energy - amount
        print("Consumed", amount, "energy from", player.Name, ". Remaining:", data.Energy)
        
        -- Notify the client of their new energy total
        local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
        energyUpdatedEvent:FireClient(player, data.Energy)
        
        return true -- Success
    else
        print("Player", player.Name, "does not have enough energy. Required:", amount, "Has:", data.Energy)
        return false -- Not enough energy
    end
end

function EnergySystem.update(player, currentTime)
    local data = PlayerService.getPlayerData(player)
    if not data or data.Energy >= data.MaxEnergy then
        return
    end

    local timeSinceLastGain = currentTime - data.LastEnergyGainTimestamp
    local REGEN_INTERVAL = 60 -- Time in seconds to gain 1 energy (1 minute)

    if timeSinceLastGain >= REGEN_INTERVAL then
        local energyToGain = math.floor(timeSinceLastGain / REGEN_INTERVAL)
        data.Energy = math.min(data.Energy + energyToGain, data.MaxEnergy)
        data.LastEnergyGainTimestamp = currentTime

        print("Player", player.Name, "regenerated", energyToGain, "energy. New total:", data.Energy)

        -- Notify the client of their new energy total
        local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
        energyUpdatedEvent:FireClient(player, data.Energy)
    end
end

function EnergySystem.setEnergy(player, amount)
    local data = PlayerService.getPlayerData(player)
    if not data then return end

    data.Energy = math.min(amount, data.MaxEnergy)
    print("ADMIN: Set", player.Name, "'s energy to", data.Energy)

    -- Notify the client of their new energy total
    local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
    energyUpdatedEvent:FireClient(player, data.Energy)
end

function EnergySystem.addEnergy(player, amount)
    local data = PlayerService.getPlayerData(player)
    if not data then return end

    data.Energy = math.min(data.Energy + amount, data.MaxEnergy)
    print("Player", player.Name, "gained", amount, "energy. New total:", data.Energy)

    -- Notify the client of their new energy total
    local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated
    energyUpdatedEvent:FireClient(player, data.Energy)
end

function EnergySystem.gainEnergyFromFood(player)
    local cost = { FOOD = 10 }
    local hasEnoughFood = ResourceManager.removeResources(player, cost)

    if hasEnoughFood then
        print("Player", player.Name, "ate 10 food.")
        EnergySystem.addEnergy(player, 1) -- 10 food gives 1 energy
    else
        print("Player", player.Name, "does not have enough food to eat.")
        -- TODO: Notify player they don't have enough food
    end
end

return EnergySystem 