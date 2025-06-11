--[[
    init.server.lua
    Server initialization script. This runs automatically when the server starts.
]]

print("=== Server initialization starting ===")

local GameSystems = require(script.GameSystems)

-- Initialize core services
GameSystems.PlayerService.initialize()
GameSystems.WorldService.initialize(GameSystems) -- Pass GameSystems
GameSystems.BuildingSystem.initialize(GameSystems) -- Pass GameSystems
GameSystems.FarmingSystem.initialize(GameSystems) -- Initialize the new system
GameSystems.EnergySystem.initialize(GameSystems) -- Initialize the energy system

-- Set up the remote event manager
GameSystems.RemoteManager = require(script.RemoteManager) -- RemoteManager is special, not in GameSystems
GameSystems.RemoteManager.setup(GameSystems) -- Pass all game systems in

-- Initialize other systems
GameSystems.AdminCommands.initialize(GameSystems)

-- According to Rojo's 'init' convention, the AssetTest module is a child
-- of this running script. We can require it directly.
local success, result = pcall(function()
    print("Loading AssetTest module from script...")
    local AssetTest = require(script.AssetTest)
    print("Module required successfully. Running test...")
    -- The test function in AssetTest runs automatically when required.
    -- If it were wrapped in a function, we would call it here:
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

-- The main server game loop
while task.wait(1) do
    local currentTime = tick()
    local allPlayers = game.Players:GetPlayers()

    for _, player in ipairs(allPlayers) do
        -- Update systems for each player
        GameSystems.EnergySystem.update(player, currentTime)
    end
    
    -- Update global systems
    GameSystems.FarmingSystem.update(currentTime)
end 