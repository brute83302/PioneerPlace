--[[
    ResourceManager.lua
    Manages the logic for player resources.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptS" .. "ervice")

local ResourceManager = {}

-- The amount of resources to give for each type
local HARVEST_AMOUNTS = {
    WOOD = 10,
    STONE = 5
}

function ResourceManager.addResource(player, resourceType, amount)
    local GameSystems = require(ServerScriptService.Server.GameSystems)
    local PlayerService = GameSystems.PlayerService
    local ProgressionSystem = GameSystems.ProgressionSystem

    local data = PlayerService.getPlayerData(player)
    if not data then
        warn("Could not find player data for:", player.Name)
        return
    end

    local amountToAdd = amount or HARVEST_AMOUNTS[resourceType] or 1
    
    data.Resources[resourceType] = (data.Resources[resourceType] or 0) + amountToAdd
    
    print(
        "Gave", amountToAdd, resourceType, "to", player.Name,
        ". They now have:", data.Resources[resourceType]
    )

    -- Grant XP for harvesting
    ProgressionSystem.addXP(player, 5) -- 5 XP for any harvest

    -- Notify the client that their resources have been updated
    local resourceUpdatedEvent = ReplicatedStorage.Remotes.ResourceUpdated
    resourceUpdatedEvent:FireClient(player, resourceType, data.Resources[resourceType])
end

function ResourceManager.removeResources(player, cost)
    local GameSystems = require(ServerScriptService.Server.GameSystems)
    local PlayerService = GameSystems.PlayerService
    local data = PlayerService.getPlayerData(player)
    if not data then return false end

    -- First, check if the player can afford it
    for resourceType, requiredAmount in pairs(cost) do
        if data.Resources[resourceType] < requiredAmount then
            print("Player", player.Name, "cannot afford to build. Missing", resourceType)
            return false -- Not enough resources
        end
    end

    -- If they can afford it, subtract the resources
    for resourceType, requiredAmount in pairs(cost) do
        data.Resources[resourceType] = data.Resources[resourceType] - requiredAmount
        -- Notify the client of the change
        local resourceUpdatedEvent = ReplicatedStorage.Remotes.ResourceUpdated
        resourceUpdatedEvent:FireClient(player, resourceType, data.Resources[resourceType])
    end

    print("Subtracted building cost from", player.Name)
    return true -- Success
end

return ResourceManager 