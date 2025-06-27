local LevelUpEffects = {}

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local PARTICLE = "rbxasset://textures/particles/sparkles_main.dds"

function LevelUpEffects.init()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local event = remotes:WaitForChild("PlayerLeveledUp")

    event.OnClientEvent:Connect(function(newLevel)
        local cam = workspace.CurrentCamera
        if not cam then return end

        -- Flash text
        local gui = Instance.new("ScreenGui")
        gui.Name = "LevelUpGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0,300,0,80)
        label.Position = UDim2.new(0.5,-150,0.4,0)
        label.AnchorPoint = Vector2.new(0.5,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1,0.9,0)
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextStrokeTransparency = 0
        label.Text = "LEVEL "..tostring(newLevel).."!"
        label.Parent = gui

        TweenService:Create(label, TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {TextStrokeTransparency=1}):Play()
        Debris:AddItem(gui,2)

        -- Particle burst at camera
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Size = Vector3.new(1,1,1)
        part.CFrame = cam.CFrame * CFrame.new(0,0,-3)
        part.Parent = workspace

        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = PARTICLE
        emitter.Lifetime = NumberRange.new(1)
        emitter.Rate = 0
        emitter.Speed = NumberRange.new(20,30)
        emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
        emitter.Color = ColorSequence.new(Color3.fromRGB(255,223,0))
        emitter.Parent = part
        emitter:Emit(50)
        Debris:AddItem(part,1.2)

        -- Sound
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://138186576" -- level up chime
        snd.Volume = 0.8
        snd.Parent = SoundService
        snd:Play()
        Debris:AddItem(snd,2)
    end)
end

return LevelUpEffects 