--[[
    CollectionToast.lua
    Simple UI feedback when a player discovers a new collectible.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local CollectionToast = {}

function CollectionToast.init()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local event = remotes:WaitForChild("CollectionFound")

    event.OnClientEvent:Connect(function(id, displayName)
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 240, 0, 40)
        label.Position = UDim2.new(0.5, -120, 0.25, 0)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.BackgroundTransparency = 0.3
        label.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Text = "New Collectible Found: " .. (displayName or id)
        label.Parent = playerGui

        -- Fade out after 3 seconds
        local tween = TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1, BackgroundTransparency = 1})
        delay(3, function()
            tween:Play()
            Debris:AddItem(label, 0.6)
        end)
    end)
end

return CollectionToast 