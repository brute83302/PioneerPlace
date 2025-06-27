--[[
    InventoryUI.lua
    Simple scrolling list that shows player inventory counts.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryUI = {}
InventoryUI.__index = InventoryUI
local currentInstance

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local requestEquipTool = remotesFolder:WaitForChild("RequestEquipTool")
local toolEquippedEvent = remotesFolder:WaitForChild("ToolEquipped")

function InventoryUI.new()
    local self = setmetatable({}, InventoryUI)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "InventoryUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false -- hidden by default; toggle with key
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "InventoryFrame"
    frame.AnchorPoint = Vector2.new(1,0)
    frame.Position = UDim2.new(1,-10,0,50)
    frame.Size = UDim2.new(0,220,0,260)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = gui

    -- Scrolling container for item rows
    local list = Instance.new("ScrollingFrame")
    list.Name = "ItemList"
    list.Size = UDim2.new(1,-6,1,-6)
    list.Position = UDim2.new(0,3,0,3)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.ScrollBarThickness = 6
    list.BackgroundTransparency = 1
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0,4)
    layout.Parent = list

    -- Automatic canvas size update
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+4)
    end)

    self.gui = gui
    self.frame = frame
    self.list = list
    self.labels = {}

    -- Toggle keybind (E)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.E then
            gui.Enabled = not gui.Enabled
        end
    end)

    currentInstance = self
    return self
end

function InventoryUI:updateItem(itemId, count)
    local label = self.labels[itemId]
    if not label then
        label = Instance.new("TextLabel")
        label.Name = itemId .. "Label"
        label.Size = UDim2.new(1,0,0,24)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextColor3 = Color3.new(1,1,1)
        label.TextScaled = true
        label.Parent = self.list or self.frame
        self.labels[itemId] = label
    end
    label.Text = itemId .. ": " .. tostring(count)

    local function isTool(id)
        return id == "STONE_AXE" or id == "PICKAXE"
    end

    -- If this is a tool, add equip button
    if isTool(itemId) then
        if not label:FindFirstChild("EquipButton") then
            local btn = Instance.new("TextButton")
            btn.Name = "EquipButton"
            btn.Size = UDim2.new(0,60,1,0)
            btn.Position = UDim2.new(1,-65,0,0)
            btn.Text = "Equip"
            btn.Font = Enum.Font.GothamBold
            btn.TextScaled = true
            btn.Parent = label
            btn.MouseButton1Click:Connect(function()
                requestEquipTool:FireServer(itemId)
            end)
        end
    end

    if itemId == "MEAL" then
        if not label:FindFirstChild("EatButton") then
            local eatBtn = Instance.new("TextButton")
            eatBtn.Name = "EatButton"
            eatBtn.Size = UDim2.new(0,60,1,0)
            eatBtn.Position = UDim2.new(1,-65,0,0)
            eatBtn.Text = "Eat"
            eatBtn.Font = Enum.Font.GothamBold
            eatBtn.TextScaled = true
            eatBtn.Parent = label
            eatBtn.MouseButton1Click:Connect(function()
                remotesFolder.RequestEatMeal:FireServer()
            end)
        end
        -- Update button active states based on count
        local eatBtn = label:FindFirstChild("EatButton")
        if eatBtn then
            eatBtn.Active = count >=1
            eatBtn.AutoButtonColor = count>=1
        end
    end
end

-- display equipped highlight
toolEquippedEvent.OnClientEvent:Connect(function(toolId)
    if not currentInstance then return end
    for id, lbl in pairs(currentInstance.labels or {}) do
        if lbl:FindFirstChild("EquipButton") then
            lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
            lbl.EquipButton.Text = "Equip"
        end
    end
    if toolId ~= "NONE" then
        local eqLabel = currentInstance.labels[toolId]
        if eqLabel then
            eqLabel.BackgroundColor3 = Color3.fromRGB(0,100,0)
            eqLabel.EquipButton.Text = "Unequip"
        end
    end
end)

return InventoryUI 