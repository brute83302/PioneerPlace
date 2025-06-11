--[[
    WorldService.lua
    Manages the overall state of the game world.
]]

local ServerScriptService = game:GetService("ServerScriptService")

-- Lazily loaded to avoid circular dependencies
local GameSystems

local WorldService = {}

function WorldService.initialize(gameSystems)
    GameSystems = gameSystems
end

function WorldService.loadPlayerBuildings(player, buildings)
    if not buildings or #buildings == 0 then
        print("No buildings to load for player:", player.Name)
        return
    end

    print("Loading", #buildings, "buildings for player:", player.Name)
    for _, buildingData in ipairs(buildings) do
        GameSystems.BuildingSystem.loadBuilding(buildingData)
    end
end

return WorldService 