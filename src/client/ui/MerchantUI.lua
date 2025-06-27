--[[
    MerchantUI.lua
    Displays traveling merchant inventory and allows purchasing.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInvFn = remotes:WaitForChild("GetMerchantInventory")
local requestBuy = remotes:WaitForChild("RequestBuyItem")
local inventoryUpdated = remotes:WaitForChild("InventoryUpdated")
local resourceUpdated = remotes:WaitForChild("ResourceUpdated")

local MerchantUI = {}
MerchantUI.__index = MerchantUI

function MerchantUI.new()
    local self = setmetatable({},MerchantUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "MerchantUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,220)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    frame.BackgroundTransparency = 0.15
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,24)
    title.BackgroundTransparency=1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.Text = "Traveling Merchant"
    title.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.Text = "X"
    close.Parent = frame

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1,-10,1,-40)
    listFrame.Position = UDim2.new(0,5,0,30)
    listFrame.BackgroundTransparency = 1
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.ScrollBarThickness = 6
    listFrame.Parent = frame

    local layout = Instance.new("UIListLayout",listFrame)
    layout.Padding = UDim.new(0,4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
    end)

    local coinLabel = Instance.new("TextLabel")
    coinLabel.Size = UDim2.new(0.5,0,0,20)
    coinLabel.Position = UDim2.new(0,5,0,4)
    coinLabel.BackgroundTransparency = 1
    coinLabel.TextColor3 = Color3.fromRGB(212,175,55)
    coinLabel.Font = Enum.Font.GothamBold
    coinLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinLabel.Parent = frame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0.5,0,0,20)
    timerLabel.Position = UDim2.new(0.5,0,0,4)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Right
    timerLabel.Parent = frame

    -- helper to refresh coin display
    local function updateCoins(amount)
        coinLabel.Text = "Coins: "..amount
    end

    local playerDataCoins = 0

    self.gui, self.listFrame = gui, listFrame
    self.itemRows = {}
    self.buttons = {}

    function self:populate(items)
        for _,child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        self.itemRows = {}
        self.buttons = {}
        for _,offer in ipairs(items) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,28)
            row.BackgroundTransparency = 1
            row.Parent = listFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6,0,1,0)
            label.BackgroundTransparency=1
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Color3.new(1,1,1)
            local displayName = offer.Name or offer.Id
            local currencyLabel = (offer.Currency == "GOLD" and " gold" or " coins")
            local qtyText = offer.Quantity and (" x"..offer.Quantity) or ""
            label.Text = displayName .. " - " .. offer.Price .. currencyLabel .. qtyText
            label.Parent = row

            local buy = Instance.new("TextButton")
            buy.Size = UDim2.new(0.4,0,1,0)
            buy.Position = UDim2.new(0.6,0,0,0)
            buy.Text = "Buy"
            buy.Parent = row
            buy.MouseButton1Click:Connect(function()
                requestBuy:FireServer(offer.Id)
            end)
            self.itemRows[offer.Id]=label
            self.buttons[offer.Id]= {button=buy, price=offer.Price}
        end
        -- initial button state
        self:updateButtons()
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
        listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
    end

    function self:updateButtons()
        for id,data in pairs(self.buttons) do
            local enough = playerDataCoins >= data.price
            data.button.Active = enough
            data.button.AutoButtonColor = enough
            data.button.TextColor3 = enough and Color3.new(1,1,1) or Color3.fromRGB(120,120,120)
        end
    end

    local items,timeLeft = getInvFn:InvokeServer()
    self:populate(items)

    -- initialize coin from server by reading ResourceUI label (simple)
    local resGui = Players.LocalPlayer.PlayerGui:FindFirstChild("ResourceScreenGui")
    if resGui then
        local statsBar = resGui:FindFirstChild("StatsBar")
        if statsBar and statsBar:FindFirstChild("CoinsLabel") then
            local txt = statsBar.CoinsLabel.Text
            playerDataCoins = tonumber(txt:match("%d+")) or 0
            updateCoins(playerDataCoins)
        end
    end

    -- resource updates
    resourceUpdated.OnClientEvent:Connect(function(resourceType, amt)
        if resourceType == "COINS" then
            playerDataCoins = amt
            updateCoins(amt)
            self:updateButtons()
        end
    end)

    -- restock timer countdown
    local remaining = timeLeft or 0
    spawn(function()
        while gui.Parent and remaining > 0 do
            timerLabel.Text = string.format("Restock in %02d:%02d", math.floor(remaining/60), remaining%60)
            wait(1)
            remaining -=1
        end
        timerLabel.Text = "Restocking soon…"
    end)

    close.MouseButton1Click:Connect(function() self:destroy() end)

    local onDestroy
    function self:setOnDestroy(cb)
        onDestroy = cb
    end

    function self:destroy()
        if onDestroy then onDestroy() end
        gui:Destroy()
    end

    return self
end

return MerchantUI 