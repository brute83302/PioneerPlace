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
    --[[
        Generates a more realistic camping tent model consisting of:
        1. A dirt ground patch
        2. Four wooden support poles
        3. A ridge pole connecting the two front-to-back poles
        4. Two canvas cloth wedges making up the left and right sides
        5. An entrance flap (slightly open) at the front
    ]]--

    -- Create container model first so we can parent parts incrementally
    local model = Instance.new("Model")
    model.Name = "Tent"

    --------------------------------------------------
    -- 1. Ground / Floor
    --------------------------------------------------
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(8, 0.4, 10)
    floor.Anchored = true
    floor.Material = Enum.Material.Ground
    floor.Color = Color3.fromRGB(101, 67, 33) -- earthy brown
    floor.TopSurface = Enum.SurfaceType.Smooth
    floor.BottomSurface = Enum.SurfaceType.Smooth
    floor.Parent = model
    model.PrimaryPart = floor

    --------------------------------------------------
    -- 2. Wooden Support Poles (4 corners)
    --------------------------------------------------
    local function createPole(position)
        local pole = Instance.new("Part")
        pole.Name = "SupportPole"
        pole.Shape = Enum.PartType.Cylinder
        pole.Size = Vector3.new(0.3, 5, 0.3) -- Y is height once rotated upright
        pole.Anchored = true
        pole.Material = Enum.Material.WoodPlanks
        pole.Color = Color3.fromRGB(124, 92, 70)
        pole.CFrame = floor.CFrame * CFrame.new(position)
        pole.Parent = model
        return pole
    end

    local halfX, halfZ = floor.Size.X/2 - 0.4, floor.Size.Z/2 - 0.4
    createPole(Vector3.new(-halfX, 2.5, -halfZ)) -- back left
    createPole(Vector3.new( halfX, 2.5, -halfZ)) -- back right
    createPole(Vector3.new(-halfX, 2.5,  halfZ)) -- front left
    createPole(Vector3.new( halfX, 2.5,  halfZ)) -- front right

    --------------------------------------------------
    -- 3. Ridge Pole (runs length-wise along top)
    --------------------------------------------------
    local ridge = Instance.new("Part")
    ridge.Name = "RidgePole"
    ridge.Shape = Enum.PartType.Cylinder
    ridge.Size = Vector3.new(floor.Size.Z + 1, 0.25, 0.25)
    ridge.Orientation = Vector3.new(0, 0, 90)
    ridge.Anchored = true
    ridge.Material = Enum.Material.WoodPlanks
    ridge.Color = Color3.fromRGB(124, 92, 70)
    ridge.CFrame = floor.CFrame * CFrame.new(0, 4.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
    ridge.Parent = model

    --------------------------------------------------
    -- 4. Canvas Cloth Sides (two wedges)
    --------------------------------------------------
    local function createCloth(isLeft)
        local cloth = Instance.new("WedgePart")
        cloth.Name = isLeft and "LeftCloth" or "RightCloth"
        cloth.Size = Vector3.new(floor.Size.Z + 0.2, 5, floor.Size.X) -- width, height, thickness (uses Z, Y, X differently)
        cloth.Anchored = true
        cloth.Material = Enum.Material.Fabric
        cloth.Color = Color3.fromRGB(210, 185, 140) -- canvas beige
        -- Position: move up half height (2.5) plus floor Y, tilt each side
        local offsetX = (isLeft and -halfX or halfX)
        local rotationY = isLeft and 0 or math.pi
        cloth.CFrame = floor.CFrame * CFrame.new(offsetX, 2.5, 0) * CFrame.Angles(0, rotationY, 0)
        cloth.Parent = model
        return cloth
    end

    local leftCloth = createCloth(true)
    local rightCloth = createCloth(false)

    -- Weld cloth to ridge & poles for physics stability (optional but good practice)
    for _, part in ipairs({leftCloth, rightCloth}) do
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = part
        weld.Part1 = ridge
        weld.Parent = part
    end

    --------------------------------------------------
    -- 5. Entrance Flap (split into two slightly open triangles)
    --------------------------------------------------
    local function createFlap(isLeft)
        local flap = Instance.new("WedgePart")
        flap.Name = isLeft and "EntranceFlapL" or "EntranceFlapR"
        flap.Size = Vector3.new(5, 4, 0.2)
        flap.Anchored = true
        flap.Material = Enum.Material.Fabric
        flap.Color = Color3.fromRGB(210, 185, 140)
        local facingOffset = Vector3.new(0, 0, halfZ + 0.1)
        local sideOffset = Vector3.new((isLeft and -2.5 or 2.5), 0, 0)
        local openAngle = math.rad(isLeft and -15 or 15)
        flap.CFrame = floor.CFrame * CFrame.new(sideOffset + facingOffset) * CFrame.Angles(0, openAngle, 0)
        flap.Parent = model
        -- weld to floor so they stay with tent
        local w = Instance.new("WeldConstraint")
        w.Part0 = flap
        w.Part1 = floor
        w.Parent = flap
        return flap
    end

    createFlap(true)
    createFlap(false)

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