--[[
    PlayerService.lua
    Manages player data and sessions, including saving and loading.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local pioneerDataStore = DataStoreService:GetDataStore("PioneerPlaceData_v3")

local WorldService
local PlayerService = {}
local playerData = {} -- In-memory storage for player data. Key is player object.

-- Sends a player's current data to their client to update the UI
function PlayerService.syncClientData(player)
    local data = playerData[player]
    if not data then return end

    local resourceUpdatedEvent = ReplicatedStorage.Remotes.ResourceUpdated
    local energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated

    -- Sync resources
    for resourceType, amount in pairs(data.Resources) do
        resourceUpdatedEvent:FireClient(player, resourceType, amount)
    end
    -- Sync energy
    energyUpdatedEvent:FireClient(player, data.Energy)
    
    print("Synced data to client for", player.Name)
end

-- Loads a player's data from the DataStore
function PlayerService.setupPlayerData(player)
    if playerData[player] then return end

    local success, savedData = pcall(function()
        return pioneerDataStore:GetAsync(player.UserId)
    end)

    if success and savedData then
        -- Player has existing data, load it
        playerData[player] = savedData
        print("Successfully loaded data for player:", player.Name)

        -- Data Migration: Ensure essential fields exist
        if not playerData[player].Buildings then
            print("Old save file detected. Adding 'Buildings' table.")
            playerData[player].Buildings = {}
        end
        if not playerData[player].Level then
            print("Old save file detected. Adding 'Level' and 'XP' fields.")
            playerData[player].Level = 1
            playerData[player].XP = 0
            playerData[player].XPToNextLevel = 100
        end

        if savedData.Buildings then
            print("Loaded", #savedData.Buildings, "buildings from DataStore.")
        else
            print("No building data found in loaded save.")
        end
    else
        -- New player or data load error, create default profile
        print("Creating new data profile for player:", player.Name)
        playerData[player] = {
            Resources = { WOOD = 0, STONE = 0, FOOD = 0 },
            Buildings = {}, -- To store placed buildings
            Energy = 20,
            MaxEnergy = 20,
            LastEnergyGainTimestamp = tick(),
            Level = 1,
            XP = 0,
            XPToNextLevel = 100, -- First level requires 100 XP
        }
    end
    -- Data Migration: Ensure essential fields exist
    if not playerData[player].Buildings then
        print("Old save file detected. Adding 'Buildings' table.")
        playerData[player].Buildings = {}
    end
    if not playerData[player].Level then
        print("Old save file detected. Adding 'Level' and 'XP' fields.")
        playerData[player].Level = 1
        playerData[player].XP = 0
        playerData[player].XPToNextLevel = 100
    end

    -- Ensure timestamp is fresh
    playerData[player].LastEnergyGainTimestamp = tick()
    PlayerService.syncClientData(player)
    
    -- Lazily require WorldService to prevent cycles
    if not WorldService then
        WorldService = require(ServerScriptService.Server.services.WorldService)
    end
    WorldService.loadPlayerBuildings(player, playerData[player].Buildings)
end

-- Saves a player's data
function PlayerService.savePlayerData(player)
    local dataToSave = playerData[player]
    if not dataToSave then return end

    if dataToSave.Buildings then
        print("Preparing to save", #dataToSave.Buildings, "buildings for player:", player.Name)
    end

    local success, err = pcall(function()
        print("Attempting to save data for:", player.Name)
        pioneerDataStore:SetAsync(player.UserId, dataToSave)
    end)

    if success then
        print("Successfully saved data for", player.Name)
    else
        warn("Failed to save data for", player.Name, ":", err)
    end
end

-- Removes a player's data from memory after saving it
function PlayerService.cleanupPlayerData(player)
    if playerData[player] then
        PlayerService.savePlayerData(player)
        playerData[player] = nil
        print("Cleaned up session data for player:", player.Name)
    end
end

-- Returns the data table for a specific player
function PlayerService.getPlayerData(player)
    -- Wait until the player's data has been loaded.
    -- This prevents a race condition where the client requests data
    -- before the server has finished loading it from the DataStore.
    while not playerData[player] do
        wait(0.1)
    end
    return playerData[player]
end

-- Initialize the service by connecting to player join/leave events
function PlayerService.initialize()
    Players.PlayerAdded:Connect(PlayerService.setupPlayerData)
    Players.PlayerRemoving:Connect(PlayerService.cleanupPlayerData)

    -- Handle players who might already be in the game when the script runs
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerService.setupPlayerData(player)
    end
    
    print("PlayerService initialized.")
end

return PlayerService 