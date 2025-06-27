local RewardEffects = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local ICONS = {
    COINS = "rbxassetid://92535294", -- coin icon placeholder
    FOOD = "rbxassetid://71489709",  -- apple icon placeholder
    WOOD = "rbxassetid://129544260", -- log icon placeholder
    STONE = "rbxassetid://62332145", -- rock icon placeholder
}

local COLOR_MAP = {
    COINS = Color3.fromRGB(255,221,35),
    FOOD  = Color3.fromRGB(150,220,100),
    WOOD  = Color3.fromRGB(163,116,73),
    STONE = Color3.fromRGB(200,200,200),
}

local SPARK_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"

local function createIconBillboard(resourceType)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(0.5,0.5,0.5)
    part.Transparency = 1

    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0,32,0,32)
    gui.AlwaysOnTop = true
    gui.Parent = part

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1,0,1,0)
    img.BackgroundTransparency = 1
    img.Image = ICONS[resourceType] or ICONS.COINS
    img.Parent = gui

    return part
end

-- Sound setup
local coinSound = Instance.new("Sound")
coinSound.SoundId = "rbxassetid://170765130" -- coin ding
coinSound.Volume = 0.6
coinSound.Name = "RewardDing"
coinSound.Parent = SoundService

-- Simple spark particle for flare
local function createSpark(pos, resourceType)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 1
    p.Size = Vector3.new(1,1,1)
    p.CFrame = CFrame.new(pos)
    p.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = SPARK_TEXTURE
    emitter.Lifetime = NumberRange.new(0.4)
    emitter.Rate = 0 -- We'll emit manually
    emitter.Speed = NumberRange.new(4,8)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.6), NumberSequenceKeypoint.new(1,0)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    emitter.SpreadAngle = Vector2.new(360,360)
    local col = COLOR_MAP[resourceType] or Color3.new(1,1,1)
    emitter.Color = ColorSequence.new(col)
    emitter.Parent = p

    -- Emit a burst of 20 particles then clean up.
    emitter:Emit(20)
    Debris:AddItem(p,0.6)
end

function RewardEffects.init()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local rewardEvent = remotes:WaitForChild("RewardExplosion")

    rewardEvent.OnClientEvent:Connect(function(pos, resourceType, count)
        count = math.clamp(count or 1, 1, 6) -- limit to 6 icons
        for i=1,count do
            local icon = createIconBillboard(resourceType)
            icon.CFrame = CFrame.new(pos) * CFrame.new(math.random(-2,2), 2, math.random(-2,2))
            icon.Parent = workspace

            local targetOffset = Vector3.new(math.random(-6,6)/3, math.random(3,6)/2, math.random(-6,6)/3)
            local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            local tween = TweenService:Create(icon, tweenInfo, {CFrame = icon.CFrame + targetOffset})
            tween:Play()

            -- Rotate billboard randomly
            icon.Orientation = Vector3.new(0, math.random(0,360), 0)

            -- Size pop
            local gui = icon:FindFirstChildOfClass("BillboardGui")
            if gui then
                local startSize = gui.Size
                local shrink = UDim2.new(startSize.X.Scale*0.3, startSize.X.Offset*0.3, startSize.Y.Scale*0.3, startSize.Y.Offset*0.3)
                gui.Size = shrink
                TweenService:Create(gui, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = startSize}):Play()
            end

            -- Fade out after movement
            tween.Completed:Connect(function()
                local fade = TweenService:Create(icon, TweenInfo.new(0.4), {Transparency = 1})
                fade:Play()
                Debris:AddItem(icon, 0.5)
            end)
        end
        -- Play sound and sparks once per explosion
        local s = coinSound:Clone()
        s.Parent = SoundService
        s:Play()
        Debris:AddItem(s,2)
        createSpark(pos, resourceType)
    end)
end

return RewardEffects 