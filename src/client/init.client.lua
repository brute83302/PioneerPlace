--[[
    init.client.lua
    Client initialization script. This runs automatically when a player joins.
]]

print("=== Client initialization starting ===")

local UIManager = require(script.UIManagerV2) -- Use the new manager
local InteractionHandler = require(script.controllers.InteractionHandler) -- Use the new handler

-- Wait for the player and their GUI to be available
local player = game.Players.LocalPlayer
print("LocalPlayer found:", player.Name)

if not player then
    player = game.Players.PlayerAdded:Wait()
end

local playerGui = player:WaitForChild("PlayerGui")
print("PlayerGui found")

-- Initialize all client-side systems
UIManager.initialize()
InteractionHandler.initialize() -- Initialize the new handler

-- According to Rojo's 'init' convention, the AssetTestClient module is a child
-- of this running script. We can require it directly.
local success, result = pcall(function()
    print("Loading AssetTestClient module from script...")
    local AssetTestClient = require(script.AssetTestClient)
    print("Module required successfully. Running test...")
    -- The test function in AssetTest runs automatically when required.
    -- If it were wrapped in a function, we would call it here:
    AssetTestClient.runTest() 
end)

if not success then
    warn("Error running client test:", result)
end

print("=== Client initialization complete ===") 