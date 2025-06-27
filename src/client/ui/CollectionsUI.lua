--[[
    CollectionsUI.lua
    Shows a grid of collectible items and whether the player has found them.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionsConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CollectionsConfig"))

local CollectionsUI = {}
CollectionsUI.__index = CollectionsUI

function CollectionsUI.new(playerCollections)
    local self = setmetatable({}, CollectionsUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "CollectionsUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 260)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Collections"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0,5,0,35)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = frame

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0,120,0,40)
    grid.CellPadding = UDim2.new(0,4,0,4)
    grid.Parent = scroll

    self.gui = gui

    -- populate
    for id, cfg in pairs(CollectionsConfig) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(0,120,0,40)
        row.BackgroundTransparency = 0.3
        row.BackgroundColor3 = Color3.fromRGB(60,60,60)
        row.Parent = scroll

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1,0,1,0)
        name.BackgroundTransparency = 1
        name.Text = cfg.Name
        name.TextScaled = true
        name.Font = Enum.Font.Gotham
        name.TextColor3 = playerCollections and playerCollections[id] and Color3.fromRGB(0,255,0) or Color3.fromRGB(200,200,200)
        name.Parent = row
    end

    -- update canvas
    scroll.CanvasSize = UDim2.new(0,0,0,grid.AbsoluteContentSize.Y)

    function self:setVisible(vis)
        gui.Enabled = vis
    end

    function self:destroy()
        gui:Destroy()
    end

    return self
end

return CollectionsUI 