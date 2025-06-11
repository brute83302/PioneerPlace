--[[
    CropTemplate.lua
    Defines the visual appearance of a growing crop.
]]

local CropTemplate = {}

function CropTemplate.createSprout()
    local sprout = Instance.new("Part")
    sprout.Name = "CropSprout"
    sprout.Size = Vector3.new(1, 1, 1)
    sprout.Color = Color3.fromRGB(100, 200, 100) -- Light green
    sprout.Material = Enum.Material.Grass
    sprout.Anchored = true
    sprout.CanCollide = false
    
    return sprout
end

function CropTemplate.createGrownCrop()
    local grownCrop = Instance.new("Part")
    grownCrop.Name = "GrownCrop"
    grownCrop.Size = Vector3.new(2, 4, 2) -- Taller and slightly wider
    grownCrop.Color = Color3.fromRGB(200, 255, 100) -- Lighter, more yellow-green
    grownCrop.Material = Enum.Material.Grass
    grownCrop.Anchored = true
    grownCrop.CanCollide = false
    
    return grownCrop
end

return CropTemplate 