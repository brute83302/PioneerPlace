--[[
    ProgressionSystem.lua
    Handles player leveling, XP, and progression rewards.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProgressionSystem = {}

function ProgressionSystem.levelUp(player, data)
    local GameSystems = require(ServerScriptService.Server.GameSystems)
    local PlayerService = GameSystems.PlayerService
    local EnergySystem = GameSystems.EnergySystem

    data.Level = data.Level + 1
    data.XP = data.XP - data.XPToNextLevel -- Carry over extra XP
    data.XPToNextLevel = data.Level * 100 -- The next level requires more XP

    print("PLAYER LEVELED UP:", player.Name, "is now Level", data.Level)

    -- Grant level-up rewards
    EnergySystem.setEnergy(player, data.MaxEnergy)
    print("Refilled energy as a level-up reward.")

    -- Notify the client about the level up for special effects
    local playerLeveledUpEvent = ReplicatedStorage.Remotes.PlayerLeveledUp
    playerLeveledUpEvent:FireClient(player, data.Level)

    -- Also update their XP bar
    local xpUpdatedEvent = ReplicatedStorage.Remotes.XPUpdated
    xpUpdatedEvent:FireClient(player, data.XP, data.XPToNextLevel)
end

function ProgressionSystem.addXP(player, amount)
    local GameSystems = require(ServerScriptService.Server.GameSystems)
    local PlayerService = GameSystems.PlayerService

    local data = PlayerService.getPlayerData(player)
    if not data then return end

    data.XP = data.XP + amount
    print("Gave", amount, "XP to", player.Name, ". Total XP:", data.XP, "/", data.XPToNextLevel)

    -- Check for level up
    if data.XP >= data.XPToNextLevel then
        ProgressionSystem.levelUp(player, data)
    end

    -- Notify the client of the XP change to update the UI
    local xpUpdatedEvent = ReplicatedStorage.Remotes.XPUpdated
    xpUpdatedEvent:FireClient(player, data.XP, data.XPToNextLevel)
end

function ProgressionSystem.resetProgression(player)
    local GameSystems = require(ServerScriptService.Server.GameSystems)
    local PlayerService = GameSystems.PlayerService

    local data = PlayerService.getPlayerData(player)
    if not data then return end

    data.Level = 1
    data.XP = 0
    data.XPToNextLevel = 100

    print("ADMIN: Reset progression for", player.Name)

    -- Notify the client of the changes
    local playerLeveledUpEvent = ReplicatedStorage.Remotes.PlayerLeveledUp
    playerLeveledUpEvent:FireClient(player, data.Level)
    local xpUpdatedEvent = ReplicatedStorage.Remotes.XPUpdated
    xpUpdatedEvent:FireClient(player, data.XP, data.XPToNextLevel)
end

return ProgressionSystem 