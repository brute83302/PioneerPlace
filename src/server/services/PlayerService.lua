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

local resourceUpdatedEvent
local energyUpdatedEvent

-- Sends a player's current data to their client to update the UI
function PlayerService.syncClientData(player)
    local data = playerData[player]
    if not data then return end

    -- Sync resources
    for resourceType, amount in pairs(data.Resources) do
        resourceUpdatedEvent:FireClient(player, resourceType, amount)
    end
    -- Sync energy
    energyUpdatedEvent:FireClient(player, data.Energy)
    
    -- Sync inventory items
    local inventoryUpdatedEvent = ReplicatedStorage.Remotes.InventoryUpdated
    for itemId, count in pairs(data.Inventory or {}) do
        inventoryUpdatedEvent:FireClient(player, itemId, count)
    end
    
    -- Ensure coins field exists for older saves
    if data.Resources and data.Resources.COINS == nil then
        data.Resources.COINS = 0
    end
    
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

        -- 1) Deduplicate buildings by position hash to avoid exponential growth
        if playerData[player].Buildings and #playerData[player].Buildings > 0 then
            local unique = {}
            local deduped = {}
            for _, b in ipairs(playerData[player].Buildings) do
                if b.CFrameComponents and #b.CFrameComponents >= 3 then
                    local x, y, z = b.CFrameComponents[1], b.CFrameComponents[2], b.CFrameComponents[3]
                    -- Round to 0.1 studs to avoid floating-point jitter
                    local key = math.floor(x*10+0.5)..","..math.floor(y*10+0.5)..","..math.floor(z*10+0.5).."_"..(b.ObjectType or b.Type)
                    if not unique[key] then
                        unique[key] = true
                        table.insert(deduped, b)
                    end
                end
            end
            local removed = #playerData[player].Buildings - #deduped
            if removed > 0 then
                print("[DataFix] Removed", removed, "duplicate buildings for", player.Name)
            end
            playerData[player].Buildings = deduped
        end

        -- 2) Hard cap total buildings to 200 to protect performance
        if playerData[player].Buildings and #playerData[player].Buildings > 200 then
            print("[DataFix] Trimming", #playerData[player].Buildings - 200, "excess buildings for", player.Name)
            while #playerData[player].Buildings > 200 do
                table.remove(playerData[player].Buildings)
            end
        end

        -- Data Migration: Ensure essential fields exist
        if not playerData[player].Level then
            print("Old save file detected. Adding 'Level' and 'XP' fields.")
            playerData[player].Level = 1
            playerData[player].XP = 0
            playerData[player].XPToNextLevel = 100
        end
        if not playerData[player].Quests then
            print("Old save file detected. Adding 'Quests' table.")
            playerData[player].Quests = {}
        end
        if not playerData[player].Collections then
            print("Old save file detected. Adding 'Collections' table.")
            playerData[player].Collections = {}
        end
        if not playerData[player].Inventory then
            print("Old save file detected. Adding 'Inventory' table.")
            playerData[player].Inventory = {}
        end
        if playerData[player].HelpTasksToday == nil then
            playerData[player].HelpTasksToday = 0
            playerData[player].HelpResetDay = os.date("*t").yday
        end
        if playerData[player].EquippedTool == nil then
            print("Adding 'EquippedTool' field.")
            playerData[player].EquippedTool = nil
        end
        if playerData[player].RestedStartTime == nil then
            playerData[player].RestedStartTime = nil
        end
        if playerData[player].LastPosition == nil then
            playerData[player].LastPosition = nil
        end

        if savedData.Buildings then
            print("Loaded", #savedData.Buildings, "buildings from DataStore.")
        else
            print("No building data found in loaded save.")
        end

        -- Apply offline passive energy regeneration
        local currentTime = tick()
        local lastGain = playerData[player].LastEnergyGainTimestamp or currentTime
        local timeOffline = currentTime - lastGain
        local REGEN_INTERVAL = 60 -- seconds per 1 energy (matches EnergySystem)
        if timeOffline >= REGEN_INTERVAL and playerData[player].Energy < playerData[player].MaxEnergy then
            local energyToGain = math.floor(timeOffline / REGEN_INTERVAL)
            playerData[player].Energy = math.min(playerData[player].Energy + energyToGain, playerData[player].MaxEnergy)
            print("Offline regen:", player.Name, "gained", energyToGain, "energy while offline. New total:", playerData[player].Energy)
        end

        -- Reset the timestamp for future online regeneration tracking
        playerData[player].LastEnergyGainTimestamp = currentTime

        -- Grant any Rested Energy bonus will be done after client UI is ready (see below)

        if not playerData[player].PlotOrigin then
            local origin = GameSystems.PlotService.assignPlot(player)
            if origin then
                playerData[player].PlotOrigin = {origin.X, origin.Y, origin.Z}
            end
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
            Resources = { WOOD = 0, STONE = 0, FOOD = 0, COINS = 0 },
            Buildings = {}, -- To store placed buildings
            Quests = {}, -- To store quest progress
            Collections = {}, -- Rare collectibles discovered
            Inventory = {}, -- To store crafted items
            EquippedTool = nil,
            Energy = 20,
            MaxEnergy = 20,
            LastEnergyGainTimestamp = tick(),
            Level = 1,
            XP = 0,
            XPToNextLevel = 100, -- First level requires 100 XP
            HelpTasksToday = 0,
            HelpResetDay = os.date("*t").yday,
            RestedStartTime = nil, -- Timestamp when player logged out in their tent (for Rested Energy bonus)
            LastPosition = nil,
        }

        -- Ensure player has a plot
        local origin = GameSystems.PlotService.assignPlot(player)
        if origin then
            playerData[player].PlotOrigin = {origin.X, origin.Y, origin.Z}
        end
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
    if not playerData[player].Quests then
        print("Old save file detected. Adding 'Quests' table.")
        playerData[player].Quests = {}
    end
    if not playerData[player].Collections then
        print("Old save file detected. Adding 'Collections' table.")
        playerData[player].Collections = {}
    end
    if not playerData[player].Inventory then
        print("Old save file detected. Adding 'Inventory' table.")
        playerData[player].Inventory = {}
    end
    if playerData[player].HelpTasksToday == nil then
        playerData[player].HelpTasksToday = 0
        playerData[player].HelpResetDay = os.date("*t").yday
    end
    if playerData[player].EquippedTool == nil then
        print("Adding 'EquippedTool' field.")
        playerData[player].EquippedTool = nil
    end
    if playerData[player].RestedStartTime == nil then
        playerData[player].RestedStartTime = nil
    end
    if playerData[player].LastPosition == nil then
        playerData[player].LastPosition = nil
    end

    -- Ensure timestamp is fresh
    -- (timestamp has already been updated above)
    PlayerService.syncClientData(player)
    
    -- Use the stored GameSystems reference to access WorldService
    GameSystems.WorldService.loadPlayerBuildings(player, playerData[player].Buildings)

    -- Signal the client that the server is ready for them
    local serverInitializedEvent = ReplicatedStorage.Remotes.ServerInitialized
    serverInitializedEvent:FireClient(player)
    print("Signaled to client that server is initialized for player:", player.Name)

    -- After a short delay, grant any Rested Energy bonus so the client has time to set up its UI listeners
    task.delay(1, function()
        PlayerService.grantRestedEnergyBonus(player)
    end)

    -- Assign starting quest or advance quest chain for returning players
    local QuestSystem = GameSystems.QuestSystem

    -- Helper: ensure quest exists if needed
    local function ensureQuest(questId)
        if not QuestSystem.hasQuest(player, questId) then
            QuestSystem.assignQuest(player, questId)
        end
    end

    local questsTable = playerData[player].Quests or {}

    if questsTable["GATHER_WOOD"] and questsTable["GATHER_WOOD"].Completed then
        if questsTable["PLANT_FIRST_CROP"] and questsTable["PLANT_FIRST_CROP"].Completed then
            -- Both first quests done, move to tent build
            ensureQuest("BUILD_TENT")
        else
            -- Gather wood done, but planting not completed yet
            ensureQuest("PLANT_FIRST_CROP")
        end
    else
        -- Player has not yet completed the first quest; make sure they have it.
        ensureQuest("GATHER_WOOD")
    end
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
        dataToSave.LastPosition = nil -- avoid DataStore issues with Vector3
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
        -- Update RestedStartTime before saving
        local data = playerData[player]
        -- Check if player is currently inside their own Tent
        local char = player.Character
        if char then
            local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                for _, model in ipairs(workspace:GetChildren()) do
                    if model:IsA("Model") and model:GetAttribute("ObjectType") == "TENT" and model:GetAttribute("OwnerId") == player.UserId and model.PrimaryPart then
                        local dist = (model.PrimaryPart.Position - pos).Magnitude
                        if dist <= 8 then -- allow wider radius
                            data.RestedStartTime = tick()
                            print("[Rested]", player.Name, "logged out inside their Tent. StartTime set.")
                            break
                        else
                            print("[Rested] Tent found but distance", math.floor(dist), "> 8. Not counting as inside.")
                        end
                    end
                end
            else
                print("[Rested] Character found but no root part for", player.Name)
            end
        else
            -- Fallback: use last recorded position from gameplay
            if data.LastPosition then
                local pos = data.LastPosition
                for _, model in ipairs(workspace:GetChildren()) do
                    if model:IsA("Model") and model:GetAttribute("ObjectType") == "TENT" and model:GetAttribute("OwnerId") == player.UserId and model.PrimaryPart then
                        local dist = (model.PrimaryPart.Position - pos).Magnitude
                        if dist <= 8 then
                            data.RestedStartTime = tick()
                            print("[Rested] (fallback)", player.Name, "logged out inside Tent based on last position.")
                            break
                        end
                    end
                end
            else
                print("[Rested] No character and LastPosition is nil for", player.Name)
            end
        end

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
function PlayerService.initialize(gameSystems)
    -- Store GameSystems for later use
    GameSystems = gameSystems
    
    -- Define remote events here to ensure they exist
    resourceUpdatedEvent = ReplicatedStorage.Remotes.ResourceUpdated
    energyUpdatedEvent = ReplicatedStorage.Remotes.EnergyUpdated

    Players.PlayerAdded:Connect(PlayerService.setupPlayerData)
    Players.PlayerRemoving:Connect(PlayerService.cleanupPlayerData)

    -- Handle players who might already be in the game when the script runs
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerService.setupPlayerData(player)
    end
    
    print("PlayerService initialized.")
end

-- Utility: Get list of currently online players for other systems (e.g., Neighborhood Boost)
function PlayerService.getOnlinePlayers()
    return game:GetService("Players"):GetPlayers()
end

-- Help task tracking
function PlayerService.canGrantHelpReward(player)
    local data = playerData[player]
    if not data then return false end

    -- Reset daily counter if a new day has started
    local today = os.date("*t").yday
    if data.HelpResetDay ~= today then
        data.HelpResetDay = today
        data.HelpTasksToday = 0
    end

    return data.HelpTasksToday < 5
end

function PlayerService.recordHelpTask(player)
    local data = playerData[player]
    if not data then return end
    local today = os.date("*t").yday
    if data.HelpResetDay ~= today then
        data.HelpResetDay = today
        data.HelpTasksToday = 0
    end
    data.HelpTasksToday += 1
end

-- Grant Rested Energy bonus, if any
function PlayerService.grantRestedEnergyBonus(player)
    local data = playerData[player]
    if not data then return end

    local currentTime = tick()
    if data.RestedStartTime then
        local restedTime = currentTime - data.RestedStartTime
        -- 1 energy per 2 minutes of rested time, capped at 10
        local bonusEnergy = math.clamp(math.floor(restedTime / 120), 0, 10)
        if bonusEnergy > 0 and data.Energy < data.MaxEnergy then
            local before = data.Energy
            data.Energy = math.min(data.Energy + bonusEnergy, data.MaxEnergy)
            print("Rested bonus:", player.Name, "gained", data.Energy - before, "energy after resting.")

            -- Notify client for UI feedback
            local restedBonusEvent = ReplicatedStorage.Remotes.RestedBonusGranted
            if restedBonusEvent then
                restedBonusEvent:FireClient(player, data.Energy - before)
            end
        end
        data.RestedStartTime = nil -- Reset after granting.
    end
end

return PlayerService 