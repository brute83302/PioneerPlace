--[[
    ResourceManager.lua
    Manages the logic for player resources.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptS" .. "ervice")
local ResourceTemplate = require(ReplicatedStorage.Assets.templates.ResourceTemplate)

local ResourceManager = {}
local GameSystems -- Store the GameSystems table

-- The amount of resources to give for each type
local HARVEST_AMOUNTS = {
    WOOD = 10,
    STONE = 5
}

-- The amount of XP to give for each resource type
local XP_AMOUNTS = {
    WOOD = 5,
    STONE = 5,
    DEFAULT = 3
}

function ResourceManager.initialize(gameSystems)
    GameSystems = gameSystems
    print("ResourceManager initialized.")
end

function ResourceManager.addResource(player, resourceType, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then
        warn("Could not find player data for:", player.Name)
        return
    end

    local resourceTypeMapped = resourceType
    if resourceType == "CLOVER" or resourceType == "APPLE_TREE" or resourceType == "APPLE" then
        resourceTypeMapped = "FOOD"
    end

    local baseAmount = amount or HARVEST_AMOUNTS[resourceTypeMapped] or 1
    local bonusMultiplier = GameSystems.ToolSystem and GameSystems.ToolSystem.getBonus(player, resourceType) or 1
    local amountToAdd = baseAmount * bonusMultiplier
    
    data.Resources[resourceTypeMapped] = (data.Resources[resourceTypeMapped] or 0) + amountToAdd
    
    print(
        "Gave", amountToAdd, resourceType, "to", player.Name,
        ". They now have:", data.Resources[resourceTypeMapped]
    )

    -- The EnergySystem will now handle granting XP directly.

    -- Update relevant quests
    if resourceTypeMapped == "WOOD" then
        GameSystems.QuestSystem.updateQuestProgress(player, "GATHER_WOOD", "GATHER_WOOD", amountToAdd)
        GameSystems.QuestSystem.updateQuestProgress(player, "DAILY_WOOD_DELIVERY", "GATHER_WOOD", amountToAdd)
    elseif resourceTypeMapped == "STONE" then
        GameSystems.QuestSystem.updateQuestProgress(player, "DAILY_STONE_DELIVERY", "GATHER_STONE", amountToAdd)
    end

    -- Notify the client that their resources have been updated
    local resourceUpdatedEvent = ReplicatedStorage.Remotes.ResourceUpdated
    resourceUpdatedEvent:FireClient(player, resourceTypeMapped, data.Resources[resourceTypeMapped])
    
    -- Potentially award rare collectible
    if GameSystems.CollectionSystem and GameSystems.CollectionSystem.tryGrantCollectible then
        GameSystems.CollectionSystem.tryGrantCollectible(player)
    end

    return amountToAdd
end

function ResourceManager.removeResources(player, cost)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return false end

    -- First, check if the player can afford it
    for resourceType, requiredAmount in pairs(cost) do
        if (data.Resources[resourceType] or 0) < requiredAmount then
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

function ResourceManager.getXPForResource(resourceType)
    return XP_AMOUNTS[resourceType] or XP_AMOUNTS.DEFAULT
end

function ResourceManager.createResourceNode(resourceType, position)
    local resourceNode = ResourceTemplate.create(resourceType)
    if not resourceNode then
        warn("ResourceTemplate failed to create a model for type:", resourceType)
        return
    end
    
    resourceNode:SetPrimaryPartCFrame(CFrame.new(position))
    resourceNode.Parent = workspace

    print("RESPAWN_DEBUG: Successfully created new resource node:", resourceType, "at", position)
    return resourceNode
end

return ResourceManager 