--[[
    init.client.lua
    Client initialization script. This runs automatically when a player joins.
]]

print("=== Client initialization starting ===")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Require all necessary client-side modules
local InteractionController = require(script.Parent.InteractionController)
local UIManagerV2 = require(script.Parent.UIManagerV2)
-- local AssetTestClient = require(script.Parent.AssetTestClient) -- Test script, commented out

-- Wait for the player and their GUI to be available
print("LocalPlayer found:", player.Name)

if not player then
    player = game.Players.PlayerAdded:Wait()
end

local playerGui = player:WaitForChild("PlayerGui")
print("PlayerGui found")

-- The old initialization calls are removed from here to prevent a race condition.
-- All initialization now happens in the main setup() function below.

-- According to Rojo's 'init' convention, the AssetTestClient module is a child
-- of this running script. We can require it directly.
local success, result = pcall(function()
    print("Loading AssetTestClient module from script...")
    local AssetTestClient = require(script.Parent.AssetTestClient)
    print("Module required successfully. Running test...")
    -- The test function in AssetTest runs automatically when required.
    -- If it were wrapped in a function, we would call it here:
    AssetTestClient.runTest() 
end)

if not success then
    warn("Error running client test:", result)
end

-- Reward explosion visuals
local RewardEffects = require(script.Parent:WaitForChild("RewardEffects"))
RewardEffects.init()

-- Hit effects
local HitEffects = require(script.Parent:WaitForChild("HitEffects"))
HitEffects.init()

-- This function runs every time the player's character spawns
local function onCharacterAdded(character)
    print(player.Name .. "'s character loaded.")
    
    -- Forcefully disable ResetOnSpawn on all GUIs.
    -- This is a critical failsafe to prevent the UI from being recreated 
    -- on spawn, which can disconnect event listeners like our mouse click handler.
    local playerGui = player:WaitForChild("PlayerGui")
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- This print statement will confirm in the console that our fix is running.
            print("Forcing ResetOnSpawn = false for GUI:", gui.Name)
            gui.ResetOnSpawn = false
        end
    end
end

-- Main client setup function
local function setup()
    print("Client Init: Setting up core systems...")

    -- Setup the system that listens for clicks on objects. This only needs to run once.
    InteractionController.setup()

    -- Wait for the server to signal that it's ready before creating the UI
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local serverInitializedEvent = remotesFolder:WaitForChild("ServerInitialized")
    
    print("Client is waiting for server to be initialized...")
    serverInitializedEvent.OnClientEvent:Wait()
    print("...Server has been initialized. Creating UI.")

    -- Initialize and create all the main UI elements
    UIManagerV2.initialize()

    -- World-level client effects (weather, etc.)
    local WorldController = require(script.Parent.WorldController)
    WorldController.init()

    -- Sleep visuals
    local SleepEffects = require(script.Parent.SleepEffects)
    SleepEffects.init()

    -- Collectible toast
    local CollectionToast = require(script.Parent.CollectionToast)
    CollectionToast.init()

    -- Start nameplates
    local BuildingNameplates = require(script.Parent.BuildingNameplates)
    BuildingNameplates.init()

    -- Connect the character loading function.
    -- This ensures our onCharacterAdded function runs every time the player spawns.
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)

    print("Client Init: Setup complete.")
end

-- Run the main setup function to start the game client
setup()

print("=== Client initialization complete ===") 