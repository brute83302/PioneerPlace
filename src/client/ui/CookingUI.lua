--[[
    CookingUI.lua
    UI for campfire cooking.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local requestCookEvent = remotesFolder:WaitForChild("RequestCookItem")
local cookingResultEvent = remotesFolder:WaitForChild("CookingResult")

local CookingUI = {}
CookingUI.__index = CookingUI

function CookingUI.new()
    local self = setmetatable({},CookingUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "CookingUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,250,0,150)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.2
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,24)
    title.BackgroundTransparency=1
    title.Text = "Campfire Cooking"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local cookBtn = Instance.new("TextButton")
    cookBtn.Size = UDim2.new(1,-20,0,40)
    cookBtn.Position = UDim2.new(0,10,0,40)
    cookBtn.Text = "Cook Meal (5 Food, 1 Wood)"
    cookBtn.Parent = frame

    cookBtn.MouseButton1Click:Connect(function()
        requestCookEvent:FireServer("SIMPLE_MEAL")
    end)

    cookingResultEvent.OnClientEvent:Connect(function(success,msg)
        if success then
            title.Text = "Cooked a meal!"
            cookBtn.Text = "Cook Meal (5 Food, 1 Wood)"
        else
            title.Text = msg
        end
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.Text = "X"
    close.ZIndex = 2
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        self:destroy()
    end)

    function self:setOnDestroy(fn)
        self._onDestroy = fn
    end

    function self:destroy()
        gui:Destroy()
        if self._onDestroy then self._onDestroy() end
    end

    return self
end

return CookingUI 