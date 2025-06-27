--[[
    PlacementController.lua
    Handles client-side building placement "ghost" mode.
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BuildingTemplate = require(ReplicatedStorage.Assets.templates.buildings.BuildingTemplate)
local FarmPlotTemplate = require(ReplicatedStorage.Assets.templates.buildings.FarmPlotTemplate)
local WorldConstants = require(ReplicatedStorage.Shared.WorldConstants)

-- Map building types to their client-side generator functions
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
    FOOD_CELLAR = BuildingTemplate.createFoodCellar,
}

local PlacementController = {}
PlacementController.isPlacing = false

local ghostModel = nil
local buildingType = nil
local placementValid = false
local plotOrigin = nil
local plotHalf = WorldConstants.PLOT_HALF

local mouse = Players.LocalPlayer:GetMouse()
local camera = Workspace.CurrentCamera

local confirmPlacementEvent = ReplicatedStorage.Remotes:WaitForChild("ConfirmBuildRequest")

local renderSteppedConnection = nil
local inputBeganConnection = nil

-- UI close button for mobile / desktop
local closeGui

local function setGhostColor(color)
    if not ghostModel then return end
    for _, part in ipairs(ghostModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = color
        end
    end
end

local function updatePlacement()
    local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)

    -- Build Raycast params to ignore ghost model and player character
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    local ignoreList = {ghostModel}
    local char = Players.LocalPlayer.Character
    if char then table.insert(ignoreList, char) end
    params.FilterDescendantsInstances = ignoreList

    local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)

    if raycastResult and raycastResult.Position then
        local targetPosition = raycastResult.Position
        -- Optional snapping for farm plots (8x8 grid like Lego)
        local finalX, finalZ = targetPosition.X, targetPosition.Z
        if buildingType == "FARM_PLOT" then
            local relX = targetPosition.X - plotOrigin.X
            local relZ = targetPosition.Z - plotOrigin.Z
            finalX = plotOrigin.X + math.floor(relX/8 + 0.5)*8
            finalZ = plotOrigin.Z + math.floor(relZ/8 + 0.5)*8
        end

        local baseHeight = ghostModel.PrimaryPart.Size.Y
        ghostModel:SetPrimaryPartCFrame(CFrame.new(finalX, targetPosition.Y + baseHeight/2, finalZ))

        -- Validation
        local withinBounds = math.abs(finalX - plotOrigin.X) <= plotHalf and math.abs(finalZ - plotOrigin.Z) <= plotHalf
        -- Collision test excluding the ghost model itself
        local overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
        local ignoreOverlap = {ghostModel, workspace.Terrain}
        if char then table.insert(ignoreOverlap, char) end
        overlapParams.FilterDescendantsInstances = ignoreOverlap
        local touching = Workspace:GetPartsInPart(ghostModel.PrimaryPart, overlapParams)
        local isColliding = false
        if touching then
            for _, p in ipairs(touching) do
                if p.CanCollide and p.Parent ~= ghostModel then
                    isColliding = true
                    break
                end
            end
        end
        if withinBounds and not isColliding then
            placementValid = true
            setGhostColor(Color3.new(0, 1, 0))
        else
            placementValid = false
            setGhostColor(Color3.new(1, 0, 0))
        end
    end
end

function PlacementController:exitPlacementMode()
    if not self.isPlacing then return end

    -- Destroy close button
    if closeGui then
        closeGui:Destroy()
        closeGui = nil
    end
    
    self.isPlacing = false
    if ghostModel then
        ghostModel:Destroy()
        ghostModel = nil
    end

    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
    end

    if inputBeganConnection then
        inputBeganConnection:Disconnect()
        inputBeganConnection = nil
    end
    print("Exited placement mode.")
end

function PlacementController:confirmPlacement()
    if not self.isPlacing or not placementValid then return end
    
    confirmPlacementEvent:FireServer(buildingType, ghostModel:GetPrimaryPartCFrame())
    -- keep placement mode active for continuous placement; do NOT exit
end

function PlacementController:enterPlacementMode(bType, pData)
    if self.isPlacing then
        self:exitPlacementMode()
    end
    
    self.isPlacing = true
    buildingType = bType
    plotOrigin = Vector3.new(unpack(pData.PlotOrigin))

    local generator = BUILDING_GENERATORS[buildingType]
    if not generator then
        warn("No generator for building type:", buildingType)
        self:exitPlacementMode()
        return
    end

    ghostModel = generator()
    ghostModel.Parent = Workspace
    
    -- Make it look like a ghost
    for _, part in ipairs(ghostModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
            part.CanCollide = false
        end
    end

    renderSteppedConnection = RunService.RenderStepped:Connect(updatePlacement)
    inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if self.isPlacing then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:confirmPlacement()
            elseif input.KeyCode == Enum.KeyCode.Escape or input.UserInputType == Enum.UserInputType.MouseButton2 then
                self:exitPlacementMode()
            end
        end
    end)

    -- Create simple close button
    if not closeGui then
        closeGui = Instance.new("ScreenGui")
        closeGui.Name = "PlacementCloseGUI"
        closeGui.ResetOnSpawn = false
        closeGui.IgnoreGuiInset = true
        closeGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,40,0,40)
        btn.Position = UDim2.new(1,-50,1,-60)
        btn.AnchorPoint = Vector2.new(1,1)
        btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Text = "X"
        btn.Parent = closeGui
        btn.MouseButton1Click:Connect(function()
            PlacementController:exitPlacementMode()
        end)
    end
end

return PlacementController 