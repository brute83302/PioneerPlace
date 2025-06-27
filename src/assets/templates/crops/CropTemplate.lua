--[[
    CropTemplate.lua
    Defines the visual appearance of crops at different growth stages.
]]

local CropTemplate = {}

function CropTemplate.createSprout()
    local sprout = Instance.new("Part")
    sprout.Name = "CropSprout"
    sprout.Size = Vector3.new(0.5, 1, 0.5)
    sprout.Color = Color3.fromRGB(144, 238, 144) -- LightGreen
    sprout.Material = Enum.Material.Grass
    sprout.Anchored = true
    return sprout
end

function CropTemplate.createGrownCrop(cropType)
    local model = Instance.new("Model")
    model.Name = "GrownCrop"
    
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(2, 2, 2)
    base.Anchored = true
    base.Parent = model

    if cropType == "WHEAT" then
        base.Color = Color3.fromRGB(245, 222, 179) -- Wheat
    elseif cropType == "CLOVER" then
        base.Color = Color3.fromRGB(0, 128, 0) -- Green
    else
        base.Color = Color3.fromRGB(255, 165, 0) -- Orange
    end

    model.PrimaryPart = base
    return model
end

function CropTemplate.createWitheredCrop(cropType)
    local model = Instance.new("Model")
    model.Name = "WitheredCrop"
    model:SetAttribute("ObjectType", "WITHERED_CROP")

    local base = Instance.new("Part")
    base.Name = "MainPart"
    base.Size = Vector3.new(2, 3, 2)
    base.Color = Color3.fromRGB(139, 69, 19) -- SaddleBrown
    base.Material = Enum.Material.Wood
    base.Anchored = true
    base.Parent = model

    model.PrimaryPart = base
    return model
end

return CropTemplate 