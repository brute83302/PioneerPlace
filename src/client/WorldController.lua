--[[
    WorldController.lua
    Listens to world-level events like weather and displays local effects.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local WorldController = {}

local currentWeather = "CLEAR"
local rainPart = nil
local rainSound = nil

local function enableRain()
    if rainPart then return end
    -- Create invisible part with particle emitter following camera
    rainPart = Instance.new("Part")
    rainPart.Anchored = true
    rainPart.CanCollide = false
    rainPart.Transparency = 1
    rainPart.Size = Vector3.new(1,1,1)
    rainPart.Name = "_ClientRain"
    rainPart.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://4817809183" -- simple rain drop texture
    emitter.Lifetime = NumberRange.new(0.6)
    emitter.Rate = 400
    emitter.Speed = NumberRange.new(30,40)
    emitter.Size = NumberSequence.new(0.2)
    emitter.Transparency = NumberSequence.new(0.2)
    emitter.Acceleration = Vector3.new(0,-200,0)
    emitter.Parent = rainPart

    -- Ambient rain sound
    rainSound = Instance.new("Sound")
    rainSound.SoundId = "rbxassetid://9064263922" -- updated rain ambience
    rainSound.Looped = true
    rainSound.Volume = 0.4
    rainSound.Parent = SoundService
    rainSound:Play()

    -- Update position each frame to camera
    RunService:BindToRenderStep("UpdateRain", Enum.RenderPriority.First.Value, function()
        local cam = workspace.CurrentCamera
        if cam and rainPart then
            rainPart.CFrame = cam.CFrame * CFrame.new(0, 20, 0) -- 20 studs above camera
            emitter.EmissionDirection = Enum.NormalId.Bottom
            emitter.Speed = NumberRange.new(30,40)
        end
    end)
end

local function disableRain()
    if rainPart then
        rainPart:Destroy()
        rainPart = nil
    end
    if rainSound then
        rainSound:Stop()
        rainSound:Destroy()
        rainSound = nil
    end
    RunService:UnbindFromRenderStep("UpdateRain")
end

function WorldController.init()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local weatherEvent = remotes:WaitForChild("WeatherChanged")

    weatherEvent.OnClientEvent:Connect(function(weatherType)
        print("[World] Weather changed to", weatherType)
        if weatherType == currentWeather then return end
        currentWeather = weatherType

        if weatherType == "RAIN" then
            enableRain()
        else
            disableRain()
        end

        -- Optionally show a toast message on screen
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local toast = Instance.new("TextLabel")
        toast.Size = UDim2.new(0, 220, 0, 30)
        toast.Position = UDim2.new(0.5, -110, 0, 50)
        toast.BackgroundTransparency = 0.3
        toast.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        toast.TextColor3 = Color3.new(1, 1, 1)
        toast.Font = Enum.Font.GothamBold
        toast.Text = "Weather: " .. weatherType
        toast.Parent = playerGui
        game:GetService("TweenService"):Create(toast, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        task.delay(3, function()
            toast:Destroy()
        end)
    end)
end

return WorldController 