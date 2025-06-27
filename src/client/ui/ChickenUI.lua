--[[
    ChickenUI.lua
    Simple UI to feed chickens and collect eggs.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local feedEvent = remotes:WaitForChild("RequestFeedChicken")
local collectEvent = remotes:WaitForChild("RequestCollectEggs")

local ChickenUI = {}
ChickenUI.__index = ChickenUI

function ChickenUI.new(coopModel)
    local self = setmetatable({},ChickenUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ChickenUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,220,0,140)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BackgroundTransparency = 0.2
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,24)
    title.BackgroundTransparency = 1
    title.Text = "Chicken Coop"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame

    local feedBtn = Instance.new("TextButton")
    feedBtn.Size = UDim2.new(1,-20,0,32)
    feedBtn.Position = UDim2.new(0,10,0,40)
    feedBtn.Text = "Feed Chickens (2 Food)"
    feedBtn.Parent = frame

    feedBtn.MouseButton1Click:Connect(function()
        feedEvent:FireServer(coopModel)
    end)

    local collectBtn = Instance.new("TextButton")
    collectBtn.Size = UDim2.new(1,-20,0,32)
    collectBtn.Position = UDim2.new(0,10,0,80)
    collectBtn.Text = "Collect Eggs"
    collectBtn.Parent = frame

    collectBtn.MouseButton1Click:Connect(function()
        collectEvent:FireServer(coopModel)
    end)

    -- Status text
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1,0,0,20)
    statusLbl.Position = UDim2.new(0,0,0,120)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextColor3 = Color3.new(1,1,1)
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextScaled = true
    statusLbl.Parent = frame

    -- Countdown logic
    local GROW_TIME = 300 -- seconds; keep in sync with server constant

    local RunService = game:GetService("RunService")
    local conn

    local function updateStatus()
        local eggs = coopModel:GetAttribute("Eggs") or 0
        if eggs > 0 then
            statusLbl.Text = "Eggs ready!"
            collectBtn.Active = true
            collectBtn.AutoButtonColor = true
        else
            local lastFed = coopModel:GetAttribute("LastFed") or 0
            if lastFed == 0 then
                statusLbl.Text = "Feed chickens first"
            else
                local remaining = math.max(0, math.ceil(GROW_TIME - (tick() - lastFed)))
                statusLbl.Text = "Eggs in " .. remaining .. "s"
            end
            collectBtn.Active = false
            collectBtn.AutoButtonColor = false
        end
    end

    updateStatus()
    conn = RunService.Heartbeat:Connect(function()
        updateStatus()
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.Text = "X"
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        self:destroy()
    end)

    function self:destroy()
        gui:Destroy()
        if conn then conn:Disconnect() end
    end

    return self
end

return ChickenUI 