--[[
    PlantingUI.lua
    Creates a menu that allows players to select which crop to plant.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CropConfig = require(ReplicatedStorage.Shared.CropConfig)

local PlantingUI = {}
PlantingUI.__index = PlantingUI

function PlantingUI.new(targetPlot)
    print("[PlantingUI] .new() called for plot:", targetPlot)
    local self = setmetatable({}, PlantingUI)
    self.targetPlot = targetPlot

    -- Create the top-level ScreenGui container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlantingUIScreen"
    self.screenGui = screenGui

    -- Create the main frame and parent it to the ScreenGui
    local frame = Instance.new("Frame")
    frame.Name = "PlantingMenu"
    print("[PlantingUI] Frame instance created.")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150) -- Centered
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    frame.Visible = true -- Explicitly set the frame to be visible
    frame.Parent = screenGui
    self.frame = frame
    print("[PlantingUI] Frame properties set. self.frame is:", self.frame.Name)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Select a Crop to Plant"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Parent = title
    closeButton.MouseButton1Click:Connect(function()
        self:destroy()
    end)
    
    -- Create a scrolling frame for the crop list
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "CropList"
    scrollFrame.Size = UDim2.new(1, -10, 1, -50)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    scrollFrame.BackgroundTransparency = 0.5
    scrollFrame.Parent = frame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Parent = scrollFrame

    -- Populate the list with crops
    local requestPlantCropEvent = ReplicatedStorage.Remotes.RequestPlantCrop
    for cropType, config in pairs(CropConfig) do
        local button = Instance.new("TextButton")
        button.Name = config.Name
        button.Text = config.Name .. " (" .. (config.GrowthTime/60) .. "m)"
        button.Size = UDim2.new(1, 0, 0, 40)
        button.Font = Enum.Font.SourceSansBold
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Parent = scrollFrame
        
        button.MouseButton1Click:Connect(function()
            print("Requesting to plant", cropType)
            requestPlantCropEvent:FireServer(self.targetPlot, cropType)
            self:destroy()
        end)
    end
    
    return self
end

function PlantingUI:setParent(parent)
    print("[PlantingUI] :setParent() called. Target parent:", parent and parent.Name or "nil")
    if self.screenGui then
        print("[PlantingUI] ScreenGui exists. Attempting to parent.")
        self.screenGui.Parent = parent
        print("[PlantingUI] ScreenGui parent is now:", self.screenGui.Parent and self.screenGui.Parent.Name or "nil")
    else
        warn("[PlantingUI] :setParent() called, but self.screenGui does not exist.")
    end
end

function PlantingUI:destroy()
    print("[PlantingUI] :destroy() called.")
    if self.screenGui then
        self.screenGui:Destroy()
        self.screenGui = nil
        self.frame = nil
        print("[PlantingUI] ScreenGui destroyed.")
    else
        warn("[PlantingUI] :destroy() called, but screenGui was already nil.")
    end
end

return PlantingUI 