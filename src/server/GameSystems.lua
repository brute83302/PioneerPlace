--[[
    GameSystems.lua
    A central module to load and provide access to all other game systems.
    This prevents circular dependency issues.
]]

local ServerScriptService = game:GetService("ServerScriptService")

local GameSystems = {}

-- Load all systems once
GameSystems.PlayerService = require(ServerScriptService.Server.services.PlayerService)
GameSystems.WorldService = require(ServerScriptService.Server.services.WorldService)
GameSystems.EnergySystem = require(ServerScriptService.Server.systems.EnergySystem)
GameSystems.ResourceManager = require(ServerScriptService.Server.systems.ResourceManager)
GameSystems.BuildingSystem = require(ServerScriptService.Server.systems.BuildingSystem)
GameSystems.ProgressionSystem = require(ServerScriptService.Server.systems.ProgressionSystem)
GameSystems.AdminCommands = require(ServerScriptService.Server.systems.AdminCommands)
GameSystems.FarmingSystem = require(ServerScriptService.Server.systems.FarmingSystem)

return GameSystems 