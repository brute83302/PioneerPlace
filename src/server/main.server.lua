--[[
    init.server.lua
    Server initialization script. This runs automatically when the server starts.
]]

print("=== Server initialization starting ===")

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Load the central GameSystems module, which handles requiring all other systems
local GameSystems = require(ServerScriptService.Server.GameSystems)

-- Initialize all systems through GameSystems
GameSystems.initialize()

-- Load and run the AssetTest script to create initial resources
local success, result = pcall(function()
    print("Loading AssetTest module...")
    local AssetTest = require(ServerScriptService.Server.AssetTest)
    print("Module required successfully. Running test...")
    AssetTest.runTest()
end)

if not success then
    warn("Error running server test:", result)
end

print("=== Server initialization complete ===")
print("=== Starting main server game loop... ===")

-- Save all player data when the server closes
game:BindToClose(function()
    if not game:GetService("RunService"):IsStudio() then
        -- This is a live server, give it time to save
        task.wait(5)
    end
    print("Server is closing. Saving all player data...")
    for _, player in ipairs(game.Players:GetPlayers()) do
        GameSystems.PlayerService.savePlayerData(player)
    end
    print("All player data saved.")
end)

-- This function sets up and runs the entire server
local function main()
    print("Server Init: Starting main game loop...")
    -- The main server game loop
    while true do
        local currentTime = tick()
        
        -- Update all player-specific systems
        for _, player in ipairs(Players:GetPlayers()) do
            GameSystems.EnergySystem.update(player, currentTime)
        end

        -- Update all global systems
        GameSystems.FarmingSystem.update(currentTime)
        GameSystems.RespawnSystem.update()
        if GameSystems.AnimalSystem and GameSystems.AnimalSystem.update then
            GameSystems.AnimalSystem.update()
        end
        if GameSystems.WorldService and GameSystems.WorldService.update then
            GameSystems.WorldService.update(currentTime)
        end

        wait(1) -- The main server tick rate
    end
end

-- Run the server
main() 