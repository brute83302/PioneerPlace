--[[
    BuildingTemplate.lua
    A template for creating building models in the Pioneer Simulation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BuildingTemplate = {}
BuildingTemplate.__index = BuildingTemplate

-- Constants
local BUILDING_CONSTANTS = {
    DEFAULT_SIZE = Vector3.new(10, 10, 10),
    DEFAULT_COLOR = Color3.fromRGB(200, 200, 200),
    DEFAULT_MATERIAL = Enum.Material.Brick,
    DEFAULT_ANCHORED = true,
    DEFAULT_CAN_COLLIDE = true
}

-- Private methods
local function createBasePart()
    local part = Instance.new("Part")
    part.Size = BUILDING_CONSTANTS.DEFAULT_SIZE
    part.Color = BUILDING_CONSTANTS.DEFAULT_COLOR
    part.Material = BUILDING_CONSTANTS.DEFAULT_MATERIAL
    part.Anchored = BUILDING_CONSTANTS.DEFAULT_ANCHORED
    part.CanCollide = BUILDING_CONSTANTS.DEFAULT_CAN_COLLIDE
    return part
end

-- Public methods
function BuildingTemplate.new(name)
    local self = setmetatable({}, BuildingTemplate)
    self.name = name or "Building"
    self.model = Instance.new("Model")
    self.model.Name = self.name
    self.parts = {}
    return self
end

function BuildingTemplate:addPart(part)
    table.insert(self.parts, part)
    part.Parent = self.model
    return self
end

function BuildingTemplate:setPosition(cframe)
    self.model:SetPrimaryPartCFrame(cframe)
    return self
end

function BuildingTemplate:setParent(parent)
    self.model.Parent = parent
    return self
end

function BuildingTemplate:createBaseStructure()
    local base = createBasePart()
    base.Name = "Base"
    self:addPart(base)
    self.model.PrimaryPart = base
    return self
end

function BuildingTemplate.createTent()
    local model = Instance.new("Model")
    model.Name = "Tent"

    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(8, 0.5, 10)
    floor.Anchored = true
    floor.Color = Color3.fromRGB(82, 124, 73) -- Grassy green
    floor.Material = Enum.Material.Fabric
    floor.Parent = model
    model.PrimaryPart = floor

    -- Create the two sloped sides of the tent
    local leftSide = Instance.new("WedgePart")
    leftSide.Name = "LeftSide"
    leftSide.Size = Vector3.new(10, 4, 8)
    leftSide.Anchored = true
    leftSide.CFrame = floor.CFrame * CFrame.new(0, 4, 0)
    leftSide.Color = Color3.fromRGB(0, 132, 209) -- Blue
    leftSide.Material = Enum.Material.Fabric
    leftSide.Parent = model
    
    local rightSide = Instance.new("WedgePart")
    rightSide.Name = "RightSide"
    rightSide.Size = Vector3.new(10, 4, 8)
    rightSide.Anchored = true
    rightSide.CFrame = floor.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(0, math.pi, 0) -- Rotated 180 degrees
    rightSide.Color = Color3.fromRGB(0, 132, 209) -- Blue
    rightSide.Material = Enum.Material.Fabric
    rightSide.Parent = model
    
    -- Weld the sides to the floor
    local weld1 = Instance.new("WeldConstraint")
    weld1.Part0 = floor
    weld1.Part1 = leftSide
    weld1.Parent = floor
    
    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = floor
    weld2.Part1 = rightSide
    weld2.Parent = floor

    return model
end

function BuildingTemplate:createWall(position, size)
    local wall = createBasePart()
    wall.Name = "Wall"
    wall.Size = size
    wall.CFrame = CFrame.new(position)
    self:addPart(wall)
    return self
end

function BuildingTemplate:createRoof(position, size)
    local roof = createBasePart()
    roof.Name = "Roof"
    roof.Size = size
    roof.CFrame = CFrame.new(position)
    self:addPart(roof)
    return self
end

function BuildingTemplate:destroy()
    self.model:Destroy()
end

return BuildingTemplate 