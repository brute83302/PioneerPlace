--[[
    CropModels.lua
    This module programmatically creates and provides templates for crop models.
]]

local CropModels = {}

-- Create a template for a fully grown, harvestable crop
function CropModels.createGrownCrop()
    local model = Instance.new("Model")
    model.Name = "GrownCrop"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(1.5, 3, 1.5)
    base.Color = Color3.fromRGB(34, 139, 34) -- ForestGreen
    base.Anchored = true
    base.CanCollide = false
    base.Parent = model
    
    model.PrimaryPart = base
    
    return model
end

-- Create a template for a withered crop
function CropModels.createWitheredCrop()
    local model = Instance.new("Model")
    model.Name = "WitheredCrop"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(1.2, 2.5, 1.2)
    base.Color = Color3.fromRGB(139, 69, 19) -- SaddleBrown
    base.Anchored = true
    base.CanCollide = false
    base.Parent = model
    
    model.PrimaryPart = base
    
    return model
end

return CropModels 