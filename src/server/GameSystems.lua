--[[
    GameSystems.lua
    A central hub for loading and providing access to all server-side systems.
    This helps prevent circular dependency issues by ensuring everything is loaded once.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ServerModules = ServerScriptService.Server

local systems = ServerModules.systems
local services = ServerModules.services

-- This table will be populated during initialization
local GameSystems = {}

-- The initialize function is called once from init.server.lua
function GameSystems.initialize()
    print("Initializing all game systems in a specific order...")

    -- Initialize systems in a hardcoded, guaranteed order to prevent race conditions.
    -- Each system is required AND THEN initialized immediately.
    
    GameSystems.RemoteManager = require(systems.RemoteManager)
    GameSystems.RemoteManager.initialize(GameSystems)

    -- PlotService must come early so PlayerService can reference it
    GameSystems.PlotService = require(services.PlotService)
    GameSystems.PlotService.initialize(GameSystems)

    GameSystems.PlayerService = require(services.PlayerService)
    GameSystems.PlayerService.initialize(GameSystems)

    GameSystems.WorldService = require(services.WorldService)
    GameSystems.WorldService.initialize(GameSystems)

    GameSystems.ToolSystem = require(systems.ToolSystem)
    GameSystems.ToolSystem.initialize(GameSystems)

    GameSystems.ResourceManager = require(systems.ResourceManager)
    GameSystems.ResourceManager.initialize(GameSystems)

    -- Collection system must come before systems that might award collectibles
    GameSystems.CollectionSystem = require(systems.CollectionSystem)
    GameSystems.CollectionSystem.initialize(GameSystems)

    GameSystems.SellingSystem = require(systems.SellingSystem)
    GameSystems.SellingSystem.initialize(GameSystems)

    GameSystems.CookingSystem = require(systems.CookingSystem)
    GameSystems.CookingSystem.initialize(GameSystems)

    -- Crafting system before progression so XP works fine (order not critical)
    GameSystems.CraftingSystem = require(systems.CraftingSystem)
    GameSystems.CraftingSystem.initialize(GameSystems)

    GameSystems.ProgressionSystem = require(systems.ProgressionSystem)
    GameSystems.ProgressionSystem.initialize(GameSystems)
    
    -- Safely require and initialize QuestSystem
    local success, questSystemOrError = pcall(function()
        return require(systems.QuestSystem)
    end)
    if success then
        GameSystems.QuestSystem = questSystemOrError
        GameSystems.QuestSystem.initialize(GameSystems)
        print("QuestSystem loaded and initialized successfully.")
    else
        warn("!!! FAILED to load QuestSystem. It will be nil. Error:", questSystemOrError)
    end

    -- Bulletin board (depends on QuestSystem)
    GameSystems.BulletinBoardSystem = require(systems.BulletinBoardSystem)
    GameSystems.BulletinBoardSystem.initialize(GameSystems)

    GameSystems.BuildingSystem = require(systems.BuildingSystem)
    GameSystems.BuildingSystem.initialize(GameSystems)

    GameSystems.FarmingSystem = require(systems.FarmingSystem)
    GameSystems.FarmingSystem.initialize(GameSystems)

    GameSystems.AnimalSystem = require(systems.AnimalSystem)
    GameSystems.AnimalSystem.initialize(GameSystems)

    GameSystems.EnergySystem = require(systems.EnergySystem)
    GameSystems.EnergySystem.initialize(GameSystems)

    GameSystems.AdminCommands = require(systems.AdminCommands)
    GameSystems.AdminCommands.initialize(GameSystems)

    GameSystems.RespawnSystem = require(systems.RespawnSystem)
    GameSystems.RespawnSystem.initialize(GameSystems)

    GameSystems.MerchantSystem = require(systems.MerchantSystem)
    GameSystems.MerchantSystem.initialize(GameSystems)
    
    print("All game systems initialized successfully.")
end

return GameSystems 