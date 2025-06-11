--[[
    ResourceUI.lua
    Creates and manages the on-screen display for player resources.
]]

local ResourceUI = {}
ResourceUI.__index = ResourceUI

local frame -- The main UI frame
local resourceLabels = {} -- Table to hold the text labels, e.g., resourceLabels.WOOD

function ResourceUI.create()
    local self = setmetatable({}, ResourceUI)
    
    -- A ScreenGui is required to render any UI on the screen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ResourceScreenGui"
    
    -- Main container frame
    frame = Instance.new("Frame")
    frame.Name = "ResourceDisplay"
    frame.Size = UDim2.new(0, 180, 0, 100) -- Increased height for energy label
    frame.Position = UDim2.new(0, 15, 0, 15) -- Top-left corner
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = frame
    
    frame.Parent = screenGui -- Parent the frame to the ScreenGui
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") -- Parent the ScreenGui to the PlayerGui

    -- Create labels for Wood and Stone
    local woodLabel = Instance.new("TextLabel")
    woodLabel.Name = "WoodLabel"
    woodLabel.Text = "Wood: 0"
    woodLabel.Size = UDim2.new(1, -10, 0, 25)
    woodLabel.Position = UDim2.new(0, 5, 0, 0)
    woodLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    woodLabel.Font = Enum.Font.SourceSansBold
    woodLabel.TextXAlignment = Enum.TextXAlignment.Left
    woodLabel.Parent = frame
    resourceLabels.WOOD = woodLabel

    local stoneLabel = Instance.new("TextLabel")
    stoneLabel.Name = "StoneLabel"
    stoneLabel.Text = "Stone: 0"
    stoneLabel.Size = UDim2.new(1, -10, 0, 25)
    stoneLabel.Position = UDim2.new(0, 5, 0, 0)
    stoneLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    stoneLabel.Font = Enum.Font.SourceSansBold
    stoneLabel.TextXAlignment = Enum.TextXAlignment.Left
    stoneLabel.Parent = frame
    resourceLabels.STONE = stoneLabel

    local foodLabel = Instance.new("TextLabel")
    foodLabel.Name = "FoodLabel"
    foodLabel.Text = "Food: 0"
    foodLabel.Size = UDim2.new(1, -10, 0, 25)
    foodLabel.TextColor3 = Color3.fromRGB(150, 220, 100) -- Light green
    foodLabel.Font = Enum.Font.SourceSansBold
    foodLabel.TextXAlignment = Enum.TextXAlignment.Left
    foodLabel.Parent = frame
    resourceLabels.FOOD = foodLabel

    local energyLabel = Instance.new("TextLabel")
    energyLabel.Name = "EnergyLabel"
    energyLabel.Text = "Energy: 20"
    energyLabel.Size = UDim2.new(1, -10, 0, 25)
    energyLabel.TextColor3 = Color3.fromRGB(255, 223, 0) -- Gold color
    energyLabel.Font = Enum.Font.SourceSansBold
    energyLabel.TextXAlignment = Enum.TextXAlignment.Left
    energyLabel.Parent = frame
    resourceLabels.ENERGY = energyLabel

    -- Create a button to build a house
    local buildHouseButton = Instance.new("TextButton")
    buildHouseButton.Name = "BuildHouseButton"
    buildHouseButton.Text = "Build House (20W, 10S)"
    buildHouseButton.Size = UDim2.new(1, -10, 0, 25)
    buildHouseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    buildHouseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildHouseButton.Font = Enum.Font.SourceSansBold
    buildHouseButton.LayoutOrder = 4 -- Adjusted layout order
    buildHouseButton.Parent = frame

    -- Create a button to build a farm plot
    local buildPlotButton = Instance.new("TextButton")
    buildPlotButton.Name = "BuildPlotButton"
    buildPlotButton.Text = "Build Plot (5W)"
    buildPlotButton.Size = UDim2.new(1, -10, 0, 25)
    buildPlotButton.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown
    buildPlotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildPlotButton.Font = Enum.Font.SourceSansBold
    buildPlotButton.LayoutOrder = 5
    buildPlotButton.Parent = frame

    -- Create a button to eat food for energy
    local eatFoodButton = Instance.new("TextButton")
    eatFoodButton.Name = "EatFoodButton"
    eatFoodButton.Text = "Eat Food (10)"
    eatFoodButton.Size = UDim2.new(1, -10, 0, 25)
    eatFoodButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Forest Green
    eatFoodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    eatFoodButton.Font = Enum.Font.SourceSansBold
    eatFoodButton.LayoutOrder = 6
    eatFoodButton.Parent = frame

    print("ResourceUI created.")
    return self, buildHouseButton, buildPlotButton, eatFoodButton
end

function ResourceUI:updateResource(resourceType, amount)
    if resourceLabels[resourceType] then
        resourceLabels[resourceType].Text = resourceType:sub(1,1):upper()..resourceType:sub(2):lower() .. ": " .. tostring(amount)
        print("UI Updated:", resourceType, "to", amount)
    end
end

function ResourceUI:updateEnergy(amount)
    if resourceLabels.ENERGY then
        resourceLabels.ENERGY.Text = "Energy: " .. tostring(amount)
        print("UI Updated: ENERGY to", amount)
    end
end

function ResourceUI.createLevelBar(playerData)
    local screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ResourceScreenGui")
    if not screenGui then
        warn("Could not find the main screen gui for the level bar.")
        return
    end

    local levelFrame = Instance.new("Frame")
    levelFrame.Name = "LevelDisplay"
    levelFrame.Size = UDim2.new(0.5, 0, 0, 60)
    levelFrame.Position = UDim2.new(0.5, 0, 1, -60) -- Bottom-center of the screen
    levelFrame.AnchorPoint = Vector2.new(0.5, 1)
    levelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    levelFrame.BackgroundTransparency = 0.4
    levelFrame.BorderSizePixel = 0
    levelFrame.Parent = screenGui

    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Text = "Level: " .. tostring(playerData.Level or 1)
    levelLabel.Size = UDim2.new(0, 100, 1, 0)
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.Font = Enum.Font.SourceSansBold
    levelLabel.Parent = levelFrame
    resourceLabels.LEVEL = levelLabel
    
    local xpBarBackground = Instance.new("Frame")
    xpBarBackground.Name = "XPBarBackground"
    xpBarBackground.Size = UDim2.new(1, -110, 0, 20)
    xpBarBackground.Position = UDim2.new(0, 105, 0.5, -10)
    xpBarBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    xpBarBackground.BorderSizePixel = 0
    xpBarBackground.Parent = levelFrame
    
    local xpBarFill = Instance.new("Frame")
    xpBarFill.Name = "XPBarFill"
    local progress = (playerData.XP or 0) / (playerData.XPToNextLevel or 100)
    xpBarFill.Size = UDim2.new(progress, 0, 1, 0)
    xpBarFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255) -- Light Blue
    xpBarFill.BorderSizePixel = 0
    xpBarFill.Parent = xpBarBackground
    resourceLabels.XP_BAR = xpBarFill
end

function ResourceUI:updateXP(xp, xpToNextLevel)
    if resourceLabels.XP_BAR then
        local progress = xp / xpToNextLevel
        resourceLabels.XP_BAR.Size = UDim2.new(progress, 0, 1, 0)
        print("UI Updated: XP Bar to", progress * 100, "%")
    end
end

function ResourceUI:updateLevel(level)
    if resourceLabels.LEVEL then
        resourceLabels.LEVEL.Text = "Level: " .. tostring(level)
        print("UI Updated: Level to", level)
    end
end

return ResourceUI 