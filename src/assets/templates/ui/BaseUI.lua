--[[
    BaseUI.lua
    A template for creating UI components in the Pioneer Simulation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BaseUI = {}
BaseUI.__index = BaseUI

-- Constants
local UI_CONSTANTS = {
    DEFAULT_POSITION = UDim2.new(0.5, 0, 0.5, 0),
    DEFAULT_ANCHOR = Vector2.new(0.5, 0.5),
    DEFAULT_SIZE = UDim2.new(0, 200, 0, 200),
    DEFAULT_BACKGROUND_COLOR = Color3.fromRGB(255, 255, 255),
    DEFAULT_BORDER_COLOR = Color3.fromRGB(0, 0, 0),
    DEFAULT_BORDER_SIZE = 1,
    DEFAULT_CORNER_RADIUS = 8
}

-- Private methods
local function createScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Name = "BaseUIScreenGui"
    return screenGui
end

local function createFrame()
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = UI_CONSTANTS.DEFAULT_BACKGROUND_COLOR
    frame.BorderSizePixel = UI_CONSTANTS.DEFAULT_BORDER_SIZE
    frame.BorderColor3 = UI_CONSTANTS.DEFAULT_BORDER_COLOR
    frame.Position = UI_CONSTANTS.DEFAULT_POSITION
    frame.AnchorPoint = UI_CONSTANTS.DEFAULT_ANCHOR
    frame.Size = UI_CONSTANTS.DEFAULT_SIZE
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UI_CONSTANTS.DEFAULT_CORNER_RADIUS)
    corner.Parent = frame
    
    return frame
end

-- Public methods
function BaseUI.new(name)
    local self = setmetatable({}, BaseUI)
    self.name = name or "BaseUI"
    self.screenGui = createScreenGui()
    self.frame = createFrame()
    self.frame.Name = self.name
    self.frame.Parent = self.screenGui
    return self
end

function BaseUI:setParent(parent)
    self.screenGui.Parent = parent
    return self
end

function BaseUI:setPosition(position)
    self.frame.Position = position
    return self
end

function BaseUI:setSize(size)
    self.frame.Size = size
    return self
end

function BaseUI:setBackgroundColor(color)
    self.frame.BackgroundColor3 = color
    return self
end

function BaseUI:setVisible(visible)
    self.screenGui.Enabled = visible
    return self
end

function BaseUI:destroy()
    self.screenGui:Destroy()
end

return BaseUI 