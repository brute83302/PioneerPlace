--[[
    AdminCommands.lua
    Handles special chat commands for server admins.
]]

local Players = game:GetService("Players")

-- No longer need direct requires. Systems will be accessed via GameSystems table.
local GameSystems

local AdminCommands = {}

-- A list of admin usernames. For now, it's just you.
local ADMIN_USERS = {
    ["YoStoniee"] = true
}

function AdminCommands.onPlayerChatted(player, message)
    if not ADMIN_USERS[player.Name] then return end

    local messageLower = string.lower(message)
    local args = string.split(messageLower, " ")
    local command = args[1]

    if command == "/refill" then
        print("Admin command received from", player.Name, ": /refill")
        local data = GameSystems.PlayerService.getPlayerData(player)
        if data then
            GameSystems.EnergySystem.setEnergy(player, data.MaxEnergy)
        end
    elseif command == "/reset" then
        print("Admin command received from", player.Name, ": /reset")
        GameSystems.ProgressionSystem.resetProgression(player)
    end
end

function AdminCommands.initialize(gameSystems)
    GameSystems = gameSystems -- Store the GameSystems table
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            AdminCommands.onPlayerChatted(player, message)
        end)
    end)
    print("AdminCommands initialized. Listening for chat commands from admins.")
end

return AdminCommands 