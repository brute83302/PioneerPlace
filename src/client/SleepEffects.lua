--[[
    SleepEffects.lua
    Client-side visuals and sounds when the player naps.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local SleepEffects = {}

local function spawnZ(position)
    -- billboard with Zzz
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.5,0.5,0.5)
    part.CFrame = CFrame.new(position + Vector3.new(0,3,0))
    part.Parent = workspace

    local gui = Instance.new("BillboardGui", part)
    gui.Size = UDim2.new(0,50,0,50)
    gui.AlwaysOnTop = true

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "💤" -- sleep emoji
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.new(1,1,1)

    -- Tween upward & fade
    local tween1 = TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = part.CFrame * CFrame.new(0,2,0)})
    tween1:Play()
    local tween2 = TweenService:Create(label, TweenInfo.new(2), {TextTransparency = 1})
    tween2:Play()

    Debris:AddItem(part, 2.5)
end

function SleepEffects.init()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local sleepEvent = remotes:WaitForChild("SleepEffect")

    sleepEvent.OnClientEvent:Connect(function(position)
        spawnZ(position)
        -- optional sound
        local yawn = Instance.new("Sound")
        yawn.SoundId = "rbxassetid://138079675" -- cartoon yawn
        yawn.Volume = 0.7
        yawn.Parent = SoundService
        yawn:Play()
        Debris:AddItem(yawn,3)

        -- quick toast GUI
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local toast = Instance.new("TextLabel")
        toast.Size = UDim2.new(0,180,0,30)
        toast.Position = UDim2.new(0.5,-90,0.3,0)
        toast.AnchorPoint = Vector2.new(0.5,0.5)
        toast.BackgroundTransparency = 0.3
        toast.BackgroundColor3 = Color3.fromRGB(0,0,0)
        toast.TextColor3 = Color3.new(1,1,1)
        toast.Font = Enum.Font.GothamBold
        toast.Text = "+5 Energy!"
        toast.Parent = playerGui
        TweenService:Create(toast, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        Debris:AddItem(toast, 2)
    end)
end

return SleepEffects 