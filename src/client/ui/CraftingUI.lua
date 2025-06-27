--[[
    CraftingUI.lua
    Simple crafting menu that lists recipes and allows crafting.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CraftingUI = {}
CraftingUI.__index = CraftingUI

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local requestCraftItemEvent = remotesFolder:WaitForChild("RequestCraftItem")
local craftingResultEvent = remotesFolder:WaitForChild("CraftingResult")

-- We'll duplicate IDs manually; fallback: hard coded same as server
local RECIPES = {
    WOOD_PLANK = {
        Name = "Wooden Plank",
        Cost = { WOOD = 5 }
    },
    STONE_AXE = {
        Name = "Stone Axe",
        Cost = { WOOD = 10, STONE = 5 }
    },
    CAMPFIRE = {
        Name = "Campfire",
        Cost = { WOOD = 5, STONE = 5 }
    },
    PICKAXE = {
        Name = "Stone Pickaxe",
        Cost = { WOOD = 5, STONE = 10 }
    }
}

-- Utility to inject space separated cost text
local function costText(cost)
    local parts = {}
    for res, amt in pairs(cost) do
        table.insert(parts, amt .. res)
    end
    return table.concat(parts, " ")
end

local itemCounts = {}

function CraftingUI.new(model)
    local self = setmetatable({}, CraftingUI)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "CraftingMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    -- Background frame center
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Parent = frame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Crafting Bench"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    title.Parent = frame

    -- Close button
    local close = Instance.new("TextButton")
    close.Name = "CloseButton"
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.BackgroundColor3 = Color3.fromRGB(200,50,50)
    close.Text = "X"
    close.TextScaled = true
    close.Parent = frame

    close.MouseButton1Click:Connect(function()
        self:destroy()
    end)

    for recipeId, data in pairs(RECIPES) do
        local button = Instance.new("TextButton")
        button.Name = recipeId .. "Button"
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Text = data.Name .. " (" .. costText(data.Cost) .. ") x" .. (itemCounts[recipeId] or 0)
        button.Font = Enum.Font.Gotham
        button.TextScaled = true
        button.BackgroundColor3 = Color3.fromRGB(50,50,50)
        button.TextColor3 = Color3.new(1,1,1)
        button.Parent = frame

        button.MouseButton1Click:Connect(function()
            requestCraftItemEvent:FireServer(recipeId)
        end)
    end

    craftingResultEvent.OnClientEvent:Connect(function(success, info)
        if not gui or gui.Parent == nil then return end
        if success then
            itemCounts[info] = (itemCounts[info] or 0) + 1
            local btn = frame:FindFirstChild(info .. "Button")
            if btn then
                local data = RECIPES[info]
                btn.Text = data.Name .. " (" .. costText(data.Cost) .. ") x" .. itemCounts[info]
            end
            title.Text = "Crafted " .. info .. "!"
        else
            title.Text = "Failed: " .. info
        end
    end)

    -- expose destroy sets activeCraftingMenu nil if callback set
    function self:setOnDestroy(fn)
        self._onDestroy = fn
    end

    function self:destroy()
        gui:Destroy()
        if self._onDestroy then
            self._onDestroy()
        end
    end

    return self
end

function CraftingUI._costText(cost)
    local str = ""
    for res, amt in pairs(cost) do
        str = str .. amt .. " " .. res .. " "
    end
    return str
end

return CraftingUI 