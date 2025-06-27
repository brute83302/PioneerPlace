--[[
    ResourceManager.lua
    Manages the logic for player resources.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ResourceTemplate = require(ReplicatedStorage.Assets.templates.ResourceTemplate)
local ResourceConfig = require(ReplicatedStorage.Shared.ResourceConfig)

local ResourceManager = {}
local GameSystems -- Store the GameSystems table

-- Fallback yields when not defined in config (legacy support)
local LEGACY_BASE_YIELD = {
    WOOD = 10,
    STONE = 5,
}

local DEFAULT_CAPACITY = { WOOD = 100, STONE = 100, FOOD = 100 }

function ResourceManager.initialize(gameSystems)
    GameSystems = gameSystems
    print("ResourceManager initialized.")
end

-- Ensure capacity table exists on player data
local function ensureCapacityTable(data)
    data.Capacity = data.Capacity or {}
    for res, cap in pairs(DEFAULT_CAPACITY) do
        if data.Capacity[res] == nil then
            data.Capacity[res] = cap
        end
    end
end

function ResourceManager.increaseCapacity(player, resourceType, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return end
    ensureCapacityTable(data)
    data.Capacity[resourceType] = (data.Capacity[resourceType] or 0) + amount
    print("Increased", resourceType, "capacity for", player.Name, "to", data.Capacity[resourceType])
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

    ensureCapacityTable(data)

    local baseAmount = amount or ResourceConfig.getBaseYield(resourceTypeMapped) or LEGACY_BASE_YIELD[resourceTypeMapped] or 1
    local bonusMultiplier = GameSystems.ToolSystem and GameSystems.ToolSystem.getBonus(player, resourceType) or 1
    local amountToAdd = baseAmount * bonusMultiplier
    
    local current = data.Resources[resourceTypeMapped] or 0
    local capacity = data.Capacity[resourceTypeMapped] or DEFAULT_CAPACITY[resourceTypeMapped] or 9999
    local newTotal = math.clamp(current + amountToAdd, 0, capacity)

    data.Resources[resourceTypeMapped] = newTotal

    if newTotal == capacity then
        print("[Capacity]", player.Name, resourceTypeMapped, "storage full (", capacity, ")")
    end
    
    print(
        "Gave", amountToAdd, resourceType, "to", player.Name,
        ". They now have:", data.Resources[resourceTypeMapped]
    )

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
    return ResourceConfig.getBaseXP(resourceType)
end

function ResourceManager.createResourceNode(resourceType, position)
    local resourceNode = ResourceTemplate.create(resourceType)
    if not resourceNode then
        warn("ResourceTemplate failed to create a model for type:", resourceType)
        return
    end
    
    resourceNode:SetPrimaryPartCFrame(CFrame.new(position))
    resourceNode.Parent = workspace

    -- Initialise hit points attribute for multi-hit obstacles
    local baseHP = ResourceConfig.getBaseHP(resourceType)
    resourceNode:SetAttribute("HP", baseHP)

    print("RESPAWN_DEBUG: Successfully created new resource node:", resourceType, "at", position)
    return resourceNode
end

return ResourceManager 