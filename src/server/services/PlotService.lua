--[[
    PlotService.lua
    Allocates and manages player plots (homesteads) in the world.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourceTemplate = require(ReplicatedStorage.Assets.templates.ResourceTemplate)
local WorldConstants = require(ReplicatedStorage.Shared.WorldConstants)

local PlotService = {}
local GameSystems

-- Configuration
local PLOT_SIZE = WorldConstants.PLOT_SIZE -- studs (square)
local PLOT_HEIGHT = 1
local PLOT_ORIGINS = {
    Vector3.new(-200, 0, 0),
    Vector3.new( 200, 0, 0)
}

local occupied = {}
local playerPlot = {} -- player -> index

local function createPlotVisual(index, origin)
    if Workspace:FindFirstChild("PlayerPlot_"..index) then return end
    local base = Instance.new("Part")
    base.Name = "PlayerPlot_"..index
    base.Size = Vector3.new(PLOT_SIZE, PLOT_HEIGHT, PLOT_SIZE)
    base.Anchored = true
    base.Position = origin + Vector3.new(0, PLOT_HEIGHT/2, 0)
    base.Color = Color3.fromRGB(31, 150, 40)
    base.Material = Enum.Material.Grass
    base.Parent = Workspace
end

local function randomPointInPlot(origin)
    local half = (PLOT_SIZE/2) - 5
    local x = math.random(-half, half)
    local z = math.random(-half, half)
    return origin + Vector3.new(x, 1, z)
end

local function spawnInitialResources(origin)
    for i=1,8 do
        local tree = ResourceTemplate.create("WOOD")
        if tree and tree.PrimaryPart then
            tree:SetPrimaryPartCFrame(CFrame.new(randomPointInPlot(origin)))
            tree.Parent = Workspace
        end
    end
    for i=1,6 do
        local rock = ResourceTemplate.create("STONE")
        if rock and rock.PrimaryPart then
            rock:SetPrimaryPartCFrame(CFrame.new(randomPointInPlot(origin)))
            rock.Parent = Workspace
        end
    end

    -- weeds for clover seeds
    for i=1,8 do
        local weed = ResourceTemplate.create("WEED")
        if weed and weed.PrimaryPart then
            weed:SetPrimaryPartCFrame(CFrame.new(randomPointInPlot(origin)))
            weed.Parent = Workspace
        end
    end
end

function PlotService.assignPlot(player)
    if playerPlot[player] then return PLOT_ORIGINS[playerPlot[player]] end
    -- find first free plot
    for i,origin in ipairs(PLOT_ORIGINS) do
        if not occupied[i] then
            occupied[i] = true
            playerPlot[player] = i
            createPlotVisual(i, origin)
            spawnInitialResources(origin)
            -- spawn location
            local spawn = Instance.new("SpawnLocation")
            spawn.Name = "PlotSpawn_"..player.UserId
            spawn.Size = Vector3.new(6,1,6)
            spawn.Position = origin + Vector3.new(0,3,0)
            spawn.Anchored = true
            spawn.Neutral = true
            spawn.Parent = Workspace
            player.RespawnLocation = spawn

            -- If character already spawned, move it
            if player.Character and player.Character.PrimaryPart then
                player.Character:SetPrimaryPartCFrame(CFrame.new(spawn.Position + Vector3.new(0,3,0)))
            end
            return origin
        end
    end
    warn("No available plots! Player will have no plot.")
    return nil
end

function PlotService.getPlotOrigin(player)
    local idx = playerPlot[player]
    if idx then return PLOT_ORIGINS[idx] end
    return nil
end

function PlotService.releasePlot(player)
    local idx = playerPlot[player]
    if idx then
        occupied[idx] = nil
        playerPlot[player] = nil
    end
end

function PlotService.initialize(gs)
    GameSystems = gs
    Players.PlayerRemoving:Connect(function(p)
        PlotService.releasePlot(p)
    end)
    Players.PlayerAdded:Connect(function(p)
        -- delay a moment so character exists
        wait(1)
        local origin = PlotService.assignPlot(p)
        if origin and p.Character and p.Character.PrimaryPart then
            p.Character:SetPrimaryPartCFrame(CFrame.new(origin + Vector3.new(0,5,0)))
        end
    end)
    print("PlotService initialized.")
end

return PlotService 