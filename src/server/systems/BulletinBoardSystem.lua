--[[
    BulletinBoardSystem.lua
    Manages the daily bulletin board tasks and player acceptance.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BulletinBoardSystem = {}
local GameSystems

local TASK_IDS = require(ReplicatedStorage.Shared.BulletinTasksConfig)
local QuestConfig = require(ReplicatedStorage.Shared.QuestConfig)

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local getBulletinFn = RemotesFolder:FindFirstChild("GetBulletinTasks") or Instance.new("RemoteFunction", RemotesFolder)
getBulletinFn.Name = "GetBulletinTasks"

local acceptTaskEvent = RemotesFolder:FindFirstChild("AcceptBulletinTask") or Instance.new("RemoteEvent", RemotesFolder)
acceptTaskEvent.Name = "AcceptBulletinTask"

-- For now every day just expose first N tasks; could randomize in future
local ACTIVE_TASKS = TASK_IDS -- simple reference

function BulletinBoardSystem.initialize(gs)
    GameSystems = gs

    -- Remote handlers
    getBulletinFn.OnServerInvoke = function(player)
        -- For each active task, return table with id, name, desc, accepted, completed
        local out = {}
        for _,id in ipairs(ACTIVE_TASKS) do
            local cfg = QuestConfig[id]
            if cfg then
                local accepted = GameSystems.QuestSystem.hasQuest(player,id)
                local completed = false
                if accepted then
                    local data = GameSystems.PlayerService.getPlayerData(player)
                    completed = data.Quests[id] and data.Quests[id].Completed or false
                end
                table.insert(out, {
                    Id = id,
                    Name = cfg.Name,
                    Description = cfg.Description,
                    Accepted = accepted,
                    Completed = completed,
                })
            end
        end
        return out
    end

    acceptTaskEvent.OnServerEvent:Connect(function(player, taskId)
        if not taskId then return end
        -- Validate task
        local valid = false
        for _,id in ipairs(ACTIVE_TASKS) do if id==taskId then valid=true break end end
        if not valid then return end
        if not GameSystems.QuestSystem.hasQuest(player, taskId) then
            GameSystems.QuestSystem.assignQuest(player, taskId)
        end
    end)

    print("BulletinBoardSystem initialized.")
end

return BulletinBoardSystem 