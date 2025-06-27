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
local WorldConstants = require(ReplicatedStorage.Shared.WorldConstants)

local BuildingSystem = {}

-- Define the cost of each building type
local BUILDING_COSTS = {
    TestHouse = { WOOD = 20, STONE = 10 },
    FARM_PLOT = { WOOD = 5 }, -- 5 wood to build a farm plot
    CRAFTING_BENCH = { WOOD = 15, STONE = 5 },
    MARKET_STALL = { WOOD = 20, STONE = 10 },
    CAMPFIRE_BUILD = { WOOD = 5, STONE = 5 },
    BED = { WOOD = 15, STONE = 5 },
    CHICKEN_COOP = { WOOD = 20, STONE = 10 },
    WOOD_SILO = { WOOD = 30, STONE = 10 },
    STONE_SHED = { WOOD = 20, STONE = 25 },
    FOOD_CELLAR = { WOOD = 25, STONE = 15 },
}

-- Map building types to their creation functions
local BUILDING_GENERATORS = {
    TestHouse = BuildingTemplate.createTent,
    FARM_PLOT = FarmPlotTemplate.create,
    CRAFTING_BENCH = BuildingTemplate.createCraftingBench,
    MARKET_STALL = BuildingTemplate.createMarketStall,
    CAMPFIRE_BUILD = BuildingTemplate.createCampfire,
    BED = BuildingTemplate.createBed,
    CHICKEN_COOP = BuildingTemplate.createChickenCoop,
    WOOD_SILO = BuildingTemplate.createWoodSilo,
    STONE_SHED = BuildingTemplate.createStoneShed,
    FOOD_CELLAR = BuildingTemplate.createFoodCellar
}

local PLOT_HALF = WorldConstants.PLOT_HALF

local function withinPlot(pos, origin)
    if not origin then return true end
    return math.abs(pos.X - origin.X) <= PLOT_HALF and math.abs(pos.Z - origin.Z) <= PLOT_HALF
end

local confirmBuildEvent

function BuildingSystem.initialize(gameSystems)
    GameSystems = gameSystems
    -- Hook ConfirmBuildRequest remote event once
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    confirmBuildEvent = remotes:WaitForChild("ConfirmBuildRequest")
    confirmBuildEvent.OnServerEvent:Connect(function(player, bType, cf)
        BuildingSystem.onBuildConfirm(player, bType, cf)
    end)
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

    local character = player.Character
    if not character or not character.PrimaryPart then return end

    local proposedCFrame = character.PrimaryPart.CFrame * CFrame.new(0, 0, -15)
    local origin = GameSystems.PlotService and GameSystems.PlotService.getPlotOrigin(player)
    if origin and not withinPlot(proposedCFrame.Position, origin) then
        warn("Player", player.Name, "tried to build outside their plot.")
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

        -- Tag the building so ownership checks are easy later (for deletion, editing, etc.)
        newBuilding:SetAttribute("OwnerId", player.UserId)
        newBuilding:SetAttribute("OwnerName", player.Name)

        -- If the new building is a farm plot, register it with the FarmingSystem
        if buildingType == "FARM_PLOT" then
            GameSystems.FarmingSystem.registerPlot(newBuilding)
        end

        -- Future: maybe register craft bench list
        if buildingType == "CRAFTING_BENCH" then
            -- No special registration yet
        elseif buildingType == "MARKET_STALL" then
            GameSystems.SellingSystem.registerStall(newBuilding)
        elseif buildingType == "CAMPFIRE_BUILD" then
            -- No special registration yet
        elseif buildingType == "CHICKEN_COOP" then
            GameSystems.AnimalSystem.registerCoop(newBuilding)
            GameSystems.ResourceManager.increaseCapacity(player, "FOOD", 200)
        elseif buildingType == "WOOD_SILO" then
            GameSystems.ResourceManager.increaseCapacity(player, "WOOD", 200)
        elseif buildingType == "STONE_SHED" then
            GameSystems.ResourceManager.increaseCapacity(player, "STONE", 200)
        elseif buildingType == "FOOD_CELLAR" then
            GameSystems.ResourceManager.increaseCapacity(player, "FOOD", 200)
        end

        print("Successfully created", buildingType, "for", player.Name)

        -- Grant XP
        local xpAmount = (buildingType == "TestHouse") and 50 or 10 -- 50 for house, 10 for plot
        GameSystems.ProgressionSystem.addXP(player, xpAmount)

        -- Update building quests
        if buildingType == "TestHouse" then -- Assuming "TestHouse" is the tent for the quest
            GameSystems.QuestSystem.updateQuestProgress(player, "BUILD_TENT", "BUILD_TENT", 1)
        end

        -- Record the new building in the player's data for persistence
        local data = GameSystems.PlayerService.getPlayerData(player)
        if data and data.Buildings then
            local buildingData = {
                Type = buildingType,
                ObjectType = newBuilding:GetAttribute("ObjectType") or buildingType,
                CFrameComponents = { spawnCFrame:GetComponents() },
                OwnerId = player.UserId,
                OwnerName = player.Name
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
function BuildingSystem.loadBuilding(player, buildingData)
    local generator = BUILDING_GENERATORS[buildingData.Type]
    if not generator then
        warn("Cannot load unknown building type:", buildingData.Type)
        return
    end
    
    local building = generator()
    
    local cf = CFrame.new(unpack(buildingData.CFrameComponents))
    building:SetPrimaryPartCFrame(cf)
    building:SetAttribute("OwnerId", buildingData.OwnerId or (player and player.UserId))
    if buildingData.OwnerName then
        building:SetAttribute("OwnerName", buildingData.OwnerName)
    end
    building.Parent = Workspace
    print("Loaded a", buildingData.Type, "from player data.")

    -- If the loaded building is a farm plot, register it
    if buildingData.Type == "FARM_PLOT" then
        GameSystems.FarmingSystem.registerPlot(building)
    elseif buildingData.Type == "CHICKEN_COOP" then
        GameSystems.AnimalSystem.registerCoop(building)
    elseif buildingData.Type == "WOOD_SILO" then
        GameSystems.ResourceManager.increaseCapacity(player, "WOOD", 200)
    elseif buildingData.Type == "STONE_SHED" then
        GameSystems.ResourceManager.increaseCapacity(player, "STONE", 200)
    elseif buildingData.Type == "FOOD_CELLAR" then
        GameSystems.ResourceManager.increaseCapacity(player, "FOOD", 200)
    end
end

function BuildingSystem.deleteStructure(player, model)
    if not model or not model:IsA("Model") then return end

    -- Ownership check; allow if OwnerId matches or if nil (legacy builds) but player is close (<50 studs)
    local ownerIdAttr = model:GetAttribute("OwnerId")
    if ownerIdAttr and ownerIdAttr ~= player.UserId then
        warn("Player", player.Name, "attempted to delete building not owned by them.")
        return
    end

    local data = GameSystems.PlayerService.getPlayerData(player)
    if data and data.Buildings then
        -- Attempt to find matching building data to remove for persistence
        local pos = model.PrimaryPart and model.PrimaryPart.Position
        for i,b in ipairs(data.Buildings) do
            local storedCf = CFrame.new(unpack(b.CFrameComponents))
            if pos and (storedCf.Position - pos).Magnitude < 4 then
                table.remove(data.Buildings,i)
                break
            end
        end
    end

    -- Special deregistration
    local objType = model:GetAttribute("ObjectType")
    if objType == "FARM_PLOT" then
        -- FarmingSystem's update loop will clean up nil parents, nothing needed
    elseif objType == "MARKET_STALL" then
        -- SellingSystem may keep a reference; simple unregister later if you add list
    elseif objType == "WOOD_SILO" then
        GameSystems.ResourceManager.increaseCapacity(player, "WOOD", -200)
    elseif objType == "STONE_SHED" then
        GameSystems.ResourceManager.increaseCapacity(player, "STONE", -200)
    elseif objType == "FOOD_CELLAR" then
        GameSystems.ResourceManager.increaseCapacity(player, "FOOD", -200)
    end

    -- Optionally save immediately to avoid rollbacks on crash
    if GameSystems and GameSystems.PlayerService then
        GameSystems.PlayerService.savePlayerData(player)
    end

    model:Destroy()
    print("Player", player.Name, "deleted a structure.")
end

function BuildingSystem.onBuildConfirm(player, buildingType, placementCFrame)
    if not buildingType or not placementCFrame then return end
    local cost = BUILDING_COSTS[buildingType]
    local generator = BUILDING_GENERATORS[buildingType]
    if not cost or not generator then return end

    -- Validate plot bounds (owner)
    local origin = GameSystems.PlotService and GameSystems.PlotService.getPlotOrigin(player)
    if origin and not withinPlot(placementCFrame.Position, origin) then
        warn("[BuildConfirm]", player.Name, "attempted to build outside their plot.")
        return
    end

    -- Simple collision check: ensure nothing already occupies that space (check bounding box)
    local halfSize = 4
    if buildingType == "FARM_PLOT" then
        halfSize = 3.9 -- allow plots to sit edge-to-edge without detecting collision
    end
    local region = Region3.new(placementCFrame.Position - Vector3.new(halfSize,4,halfSize), placementCFrame.Position + Vector3.new(halfSize,4,halfSize))
    local overlapping = workspace:FindPartsInRegion3WithIgnoreList(region, {}, 5)
    for _, part in ipairs(overlapping) do
        if part.Parent and part.Parent:GetAttribute("ObjectType") then
            warn("[BuildConfirm] Collision detected, cannot place building.")
            return
        end
    end

    -- Pay resources
    if not GameSystems.ResourceManager.removeResources(player, cost) then
        return
    end

    local newBuilding = generator()
    newBuilding:SetPrimaryPartCFrame(placementCFrame)
    newBuilding.Parent = workspace
    newBuilding:SetAttribute("OwnerId", player.UserId)
    newBuilding:SetAttribute("OwnerName", player.Name)

    -- Special registrations
    if buildingType == "FARM_PLOT" then
        GameSystems.FarmingSystem.registerPlot(newBuilding)
    elseif buildingType == "CHICKEN_COOP" then
        GameSystems.AnimalSystem.registerCoop(newBuilding)
        GameSystems.ResourceManager.increaseCapacity(player, "FOOD", 200)
    elseif buildingType == "WOOD_SILO" then
        GameSystems.ResourceManager.increaseCapacity(player, "WOOD", 200)
    elseif buildingType == "STONE_SHED" then
        GameSystems.ResourceManager.increaseCapacity(player, "STONE", 200)
    elseif buildingType == "FOOD_CELLAR" then
        GameSystems.ResourceManager.increaseCapacity(player, "FOOD", 200)
    end

    GameSystems.ProgressionSystem.addXP(player, (buildingType == "TestHouse") and 50 or 10)

    -- Save to player data (with dedupe key)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if data then
        local components = {placementCFrame:GetComponents()}
        local key = string.format("%d,%d,%d_%s", math.floor(components[1]*10+0.5), math.floor(components[2]*10+0.5), math.floor(components[3]*10+0.5), newBuilding:GetAttribute("ObjectType") or buildingType)
        data._BuildingKeys = data._BuildingKeys or {}
        if not data._BuildingKeys[key] then
            data._BuildingKeys[key] = true
            table.insert(data.Buildings, {Type=buildingType, ObjectType=newBuilding:GetAttribute("ObjectType") or buildingType, CFrameComponents=components, OwnerId=player.UserId, OwnerName=player.Name})
        end
    end
end

return BuildingSystem 