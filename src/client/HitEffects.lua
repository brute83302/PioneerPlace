local HitEffects = {}

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"

local COLOR_MAP = {
    WOOD  = Color3.fromRGB(163,116,73),
    STONE = Color3.fromRGB(180,180,180),
    FOOD  = Color3.fromRGB(150,220,100),
}

function HitEffects.init()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local event = remotes:WaitForChild("HitSpark")

    event.OnClientEvent:Connect(function(pos, resourceType)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Size = Vector3.new(1,1,1)
        part.CFrame = CFrame.new(pos)
        part.Parent = workspace

        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = TEXTURE
        emitter.Rate = 0
        emitter.Lifetime = NumberRange.new(0.3)
        emitter.Speed = NumberRange.new(6,10)
        emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,0)})
        emitter.Color = ColorSequence.new(COLOR_MAP[resourceType] or Color3.new(1,1,1))
        emitter.SpreadAngle = Vector2.new(360,360)
        emitter.Parent = part

        emitter:Emit(15)
        Debris:AddItem(part,0.4)
    end)
end

return HitEffects 