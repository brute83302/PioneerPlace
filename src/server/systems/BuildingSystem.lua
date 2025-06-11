--[[
    BuildingSystem.lua
    Handles the creation and placement of player-built structures.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lazily loaded to avoid circular dependencies
local GameSystems
local BuildingTemplate = require(ReplicatedStorage.Assets.templates.buildings.BuildingTemplate)
local FarmPlotTemplate = require(ReplicatedStorage.Assets.templates.buildings.FarmPlotTemplate)

local BuildingSystem = {}

-- Define the cost of each building type
local BUILDING_COSTS = {
    TestHouse = { WOOD = 20, STONE = 10 },
    FARM_PLOT = { WOOD = 5 } -- 5 wood to build a farm plot
}

-- Map building types to their creation functions
local BUILDING_GENERATORS = {
    TestHouse = BuildingTemplate.createTent,
    FARM_PLOT = FarmPlotTemplate.create
}

function BuildingSystem.initialize(gameSystems)
    GameSystems = gameSystems
end

-- This function is called by the RemoteManager when a client requests to build
function BuildingSystem.onBuildRequest(player, buildingType)
    local cost = BUILDING_COSTS[buildingType]
    if not cost then
        warn("Player", player.Name, "tried to build an unknown building type:", buildingType)
        return
    end

    local generator = BUILDING_GENERATORS[buildingType]
    if not generator then
        warn("No generator function found for building type:", buildingType)
        return
    end

    -- Attempt to subtract the resources from the player's inventory
    local success = GameSystems.ResourceManager.removeResources(player, cost)

    if success then
        print("Player has enough resources. Creating building:", buildingType)
        local character = player.Character
        if not character or not character.PrimaryPart then return end
        
        -- Create the building model using the correct generator function
        local newBuilding = generator()
        
        -- Place it in the world in front of the player
        local spawnCFrame = character.PrimaryPart.CFrame * CFrame.new(0, 0, -15)
        newBuilding:SetPrimaryPartCFrame(spawnCFrame)
        newBuilding.Parent = Workspace

        print("Successfully created", buildingType, "for", player.Name)

        -- Grant XP
        local xpAmount = (buildingType == "TestHouse") and 50 or 10 -- 50 for house, 10 for plot
        GameSystems.ProgressionSystem.addXP(player, xpAmount)

        -- Record the new building in the player's data for persistence
        local data = GameSystems.PlayerService.getPlayerData(player)
        if data and data.Buildings then
            local buildingData = {
                Type = buildingType,
                CFrameComponents = { spawnCFrame:GetComponents() }
            }
            table.insert(data.Buildings, buildingData)
            print("Recorded new", buildingType, "in player data. Total buildings:", #data.Buildings)
        else
            warn("Could not record building. Player data or Buildings table not found.")
        end
    else
        print("Player does not have enough resources to build", buildingType)
    end
end

-- This function is called by the WorldService when a player joins to load their saved buildings
function BuildingSystem.loadBuilding(buildingData)
    local generator = BUILDING_GENERATORS[buildingData.Type]
    if not generator then
        warn("Cannot load unknown building type:", buildingData.Type)
        return
    end
    
    local building = generator()
    
    local cf = CFrame.new(unpack(buildingData.CFrameComponents))
    building:SetPrimaryPartCFrame(cf)
    building.Parent = Workspace
    print("Loaded a", buildingData.Type, "from player data.")
end

return BuildingSystem 