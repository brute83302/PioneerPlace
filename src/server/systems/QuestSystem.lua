--[[
    QuestSystem.lua
    Manages player quests, tracks progress, and grants rewards.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for the config file to exist to prevent race conditions on server startup
local SharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
if not SharedFolder then
    error("QuestSystem: 'Shared' folder not found in ReplicatedStorage. Cannot load QuestConfig.")
end
local QUEST_CONFIG = require(SharedFolder:WaitForChild("QuestConfig"))

local QuestSystem = {}
local GameSystems

-- Cache references to quest RemoteEvents for efficiency
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local QuestAssignedEvent = RemotesFolder:WaitForChild("QuestAssigned")
local QuestProgressEvent = RemotesFolder:WaitForChild("QuestProgressUpdated")
local QuestCompletedEvent = RemotesFolder:WaitForChild("QuestCompleted")

function QuestSystem.initialize(gameSystems)
    GameSystems = gameSystems
    print("QuestSystem initialized.")
end

-- Checks if a player has a specific quest
function QuestSystem.hasQuest(player, questId)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data or not data.Quests then return false end
    
    return data.Quests[questId] ~= nil
end

-- Gives a new quest to the player if they don't already have it
function QuestSystem.assignQuest(player, questId)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return end
    if QuestSystem.hasQuest(player, questId) then return end

    local questConfig = QUEST_CONFIG[questId]
    if not questConfig then
        warn("Attempted to assign invalid questId:", questId)
        return
    end

    if not data.Quests then
        data.Quests = {}
    end
    
    data.Quests[questId] = {
        Completed = false,
        Progress = {}
    }

    print("Assigned Quest [", questId, "] to", player.Name)
    -- Notify the client so their UI can display the new quest
    QuestAssignedEvent:FireClient(player, questId, data.Quests[questId])
    -- TODO: Fire a remote event to update the client's quest UI
end

-- Updates a player's progress on a quest objective
function QuestSystem.updateQuestProgress(player, questId, objective, amount)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if not QuestSystem.hasQuest(player, questId) or data.Quests[questId].Completed then
        return
    end

    local questData = data.Quests[questId]
    local currentProgress = questData.Progress[objective] or 0
    questData.Progress[objective] = currentProgress + amount
    
    print("Updated Quest [", questId, "] Progress for", player.Name, ":", objective, questData.Progress[objective])
    
    -- Sync progress to the client UI
    QuestProgressEvent:FireClient(player, questId, questData.Progress, questData.Completed)
    
    QuestSystem.checkQuestCompletion(player, questId)
end

-- Checks if all objectives for a quest are met
function QuestSystem.checkQuestCompletion(player, questId)
    local data = GameSystems.PlayerService.getPlayerData(player)
    local questData = data.Quests[questId]
    local questConfig = QUEST_CONFIG[questId]

    for objective, requiredAmount in pairs(questConfig.Objectives) do
        if (questData.Progress[objective] or 0) < requiredAmount then
            return -- Not yet complete
        end
    end

    -- If all objectives are met, complete the quest
    questData.Completed = true
    print("Player", player.Name, "completed quest:", questId)
    -- Inform client of completion before rewards (visual feedback)
    QuestCompletedEvent:FireClient(player, questId)
    QuestSystem.grantQuestRewards(player, questId)
end

-- Grants the rewards for a completed quest
function QuestSystem.grantQuestRewards(player, questId)
    local questConfig = QUEST_CONFIG[questId]
    if not questConfig.Rewards then return end

    for rewardType, amount in pairs(questConfig.Rewards) do
        if rewardType == "XP" then
            GameSystems.ProgressionSystem.addXP(player, amount)
        elseif rewardType == "COINS" then
            -- Assuming COINS is a resource type. This may need to be adjusted.
            GameSystems.ResourceManager.addResource(player, "COINS", amount)
        else
            -- For other resources like WOOD, STONE, etc.
            GameSystems.ResourceManager.addResource(player, rewardType, amount)
        end
        print("Granted reward:", amount, rewardType, "to", player.Name)
    end
    
    -- TODO: Fire remote event to client to show quest completion UI

    -- Simple linear quest chain: grant the next quest when one finishes
    if questId == "GATHER_WOOD" then
        QuestSystem.assignQuest(player, "PLANT_FIRST_CROP")
    elseif questId == "PLANT_FIRST_CROP" then
        QuestSystem.assignQuest(player, "BUILD_TENT")
    elseif questId == "BUILD_TENT" then
        QuestSystem.assignQuest(player, "CRAFT_PLANK")
    elseif questId == "CRAFT_PLANK" then
        QuestSystem.assignQuest(player, "COOK_MEAL")
    elseif questId == "COOK_MEAL" then
        QuestSystem.assignQuest(player, "HARVEST_CROPS")
    elseif questId == "HARVEST_CROPS" then
        QuestSystem.assignQuest(player, "SLEEP_IN_BED")
    end
end

return QuestSystem 