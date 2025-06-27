--[[
    MarketUI.lua
    Allows selling items for coins at market stall.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local requestSellEvent = remotesFolder:WaitForChild("RequestSellItem")

local MarketUI = {}
MarketUI.__index = MarketUI

function MarketUI.new(playerInventory)
    local self = setmetatable({}, MarketUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "MarketUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,250)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.3
    frame.Parent = gui

    -- Scrollable list container
    local list = Instance.new("ScrollingFrame")
    list.Name = "ItemList"
    list.Size = UDim2.new(1,-10,1,-40)
    list.Position = UDim2.new(0,5,0,30)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Parent = list
    layout.Padding = UDim.new(0,4)

    -- Auto-expand canvas when items added/size changes
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 4)
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,24)
    title.Text = "Market Stall"
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- close
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.Text = "X"
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        self:destroy()
    end)

    self.labels = {}
    self.frame = frame
    self.gui = gui
    self.list = list
    self.sellButtons = {}

    for itemId,count in pairs(playerInventory) do
        self:addItemRow(itemId,count)
    end

    return self
end

function MarketUI:addItemRow(itemId,count)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,30)
    row.BackgroundTransparency = 1
    row.Parent = self.list

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.Text = itemId..": "..count
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.Parent = row

    local sell1 = Instance.new("TextButton")
    sell1.Size = UDim2.new(0.2,0,1,0)
    sell1.Position = UDim2.new(0.6,0,0,0)
    sell1.Text = "Sell 1"
    sell1.Parent = row

    local sell10 = Instance.new("TextButton")
    sell10.Size = UDim2.new(0.2,0,1,0)
    sell10.Position = UDim2.new(0.8,0,0,0)
    sell10.Text = "Sell 10"
    sell10.Parent = row

    sell1.MouseButton1Click:Connect(function()
        requestSellEvent:FireServer(itemId,1)
    end)

    sell10.MouseButton1Click:Connect(function()
        requestSellEvent:FireServer(itemId,10)
    end)

    self.labels[itemId] = label
    self.sellButtons[itemId] = {b1=sell1,b10=sell10}
end

function MarketUI:updateItem(itemId,count)
    local lbl = self.labels[itemId]
    if lbl then
        lbl.Text = itemId..": "..count
    end
    local btns = self.sellButtons[itemId]
    if btns then
        btns.b1.Active = count >=1
        btns.b1.AutoButtonColor = count>=1
        btns.b10.Active = count >=10
        btns.b10.AutoButtonColor = count>=10
    end
end

-- Optional onDestroy callback so UIManager can clear its reference
local onDestroy
function MarketUI:setOnDestroy(cb)
    onDestroy = cb
end

function MarketUI:destroy()
    if onDestroy then onDestroy() end
    if self.gui then
        self.gui:Destroy()
    end
end

return MarketUI 