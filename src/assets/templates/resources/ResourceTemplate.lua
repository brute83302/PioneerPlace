--[[
    ResourceTemplate.lua
    A template for creating resource models in the Pioneer Simulation
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ResourceTemplate = {}
ResourceTemplate.__index = ResourceTemplate

-- Constants
local RESOURCE_CONSTANTS = {
    DEFAULT_SIZE = Vector3.new(2, 2, 2),
    DEFAULT_COLOR = Color3.fromRGB(150, 150, 150),
    DEFAULT_MATERIAL = Enum.Material.Slate,
    DEFAULT_ANCHORED = true,
    DEFAULT_CAN_COLLIDE = true,
    DEFAULT_TRANSPARENCY = 0,
    DEFAULT_SHAPE = Enum.PartType.Block
}

-- Resource types
local RESOURCE_TYPES = {
    WOOD = {
        color = Color3.fromRGB(139, 69, 19),
        material = Enum.Material.Wood
    },
    STONE = {
        color = Color3.fromRGB(128, 128, 128),
        material = Enum.Material.Slate
    },
    ORE = {
        color = Color3.fromRGB(184, 134, 11),
        material = Enum.Material.Metal
    }
}

-- Private methods
local function createResourcePart(resourceType)
    local part = Instance.new("Part")
    part.Size = RESOURCE_CONSTANTS.DEFAULT_SIZE
    part.Color = RESOURCE_TYPES[resourceType].color
    part.Material = RESOURCE_TYPES[resourceType].material
    part.Anchored = RESOURCE_CONSTANTS.DEFAULT_ANCHORED
    part.CanCollide = RESOURCE_CONSTANTS.DEFAULT_CAN_COLLIDE
    part.Transparency = RESOURCE_CONSTANTS.DEFAULT_TRANSPARENCY
    part.Shape = RESOURCE_CONSTANTS.DEFAULT_SHAPE
    return part
end

-- Public methods
function ResourceTemplate.new(name, resourceType)
    local self = setmetatable({}, ResourceTemplate)
    self.name = name or "Resource"
    self.resourceType = resourceType or "STONE"
    self.model = Instance.new("Model")
    self.model.Name = self.name
    self.parts = {}

    -- Set an attribute on the model so we can easily identify its type
    self.model:SetAttribute("ResourceType", self.resourceType)

    return self
end

function ResourceTemplate:addPart(part)
    table.insert(self.parts, part)
    part.Parent = self.model
    return self
end

function ResourceTemplate:setPosition(position)
    self.model:SetPrimaryPartCFrame(CFrame.new(position))
    return self
end

function ResourceTemplate:setParent(parent)
    self.model.Parent = parent
    return self
end

function ResourceTemplate:createResourceNode()
    if self.resourceType == "WOOD" then
        -- Create a more tree-like model for wood
        local trunk = Instance.new("Part")
        trunk.Name = "ResourceNode" -- The primary part must be named this for clicks to register
        trunk.Shape = Enum.PartType.Cylinder
        trunk.Size = Vector3.new(2, 6, 2)
        trunk.Color = Color3.fromRGB(139, 69, 19) -- Brown
        trunk.Material = Enum.Material.Wood
        self:addPart(trunk)
        self.model.PrimaryPart = trunk

        local leaves = Instance.new("Part")
        leaves.Name = "Leaves"
        leaves.Shape = Enum.PartType.Ball
        leaves.Size = Vector3.new(6, 6, 6)
        leaves.Color = Color3.fromRGB(34, 139, 34) -- Forest Green
        leaves.Material = Enum.Material.Grass
        leaves.Position = trunk.Position + Vector3.new(0, 4, 0)
        self:addPart(leaves)

        -- Weld the leaves to the trunk so they stay together
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = trunk
        weld.Part1 = leaves
        weld.Parent = trunk

    else
        -- Default resource creation (for stone, ore, etc.)
        local node = createResourcePart(self.resourceType)
        node.Name = "ResourceNode"
        self:addPart(node)
        self.model.PrimaryPart = node
    end
    return self
end

function ResourceTemplate:setResourceType(resourceType)
    self.resourceType = resourceType
    for _, part in ipairs(self.parts) do
        part.Color = RESOURCE_TYPES[resourceType].color
        part.Material = RESOURCE_TYPES[resourceType].material
    end
    return self
end

function ResourceTemplate:setTransparency(transparency)
    for _, part in ipairs(self.parts) do
        part.Transparency = transparency
    end
    return self
end

function ResourceTemplate:destroy()
    self.model:Destroy()
end

function ResourceTemplate.createRock()
    local model = Instance.new("Model")
    model.Name = "Rock"
    
    local rockPart = Instance.new("Part")
    rockPart.Name = "ResourceNode"
    rockPart.Size = Vector3.new(4, 4, 4)
    rockPart.Color = Color3.fromRGB(128, 128, 128)
    rockPart.Material = Enum.Material.Slate
    rockPart.Anchored = true
    rockPart.Parent = model
    
    model.PrimaryPart = rockPart
    return model
end

function ResourceTemplate.createTree()
    local model = Instance.new("Model")
    model.Name = "Tree"
    
    local trunk = Instance.new("Part")
    trunk.Name = "ResourceNode" -- The primary part must be named this for clicks to register
    trunk.Shape = Enum.PartType.Cylinder
    trunk.Size = Vector3.new(2, 6, 2)
    trunk.Color = Color3.fromRGB(139, 69, 19) -- Brown
    trunk.Material = Enum.Material.Wood
    trunk.Anchored = true
    trunk.Parent = model
    model.PrimaryPart = trunk

    local leaves = Instance.new("Part")
    leaves.Name = "Leaves"
    leaves.Shape = Enum.PartType.Ball
    leaves.Size = Vector3.new(6, 6, 6)
    leaves.Color = Color3.fromRGB(34, 139, 34) -- Forest Green
    leaves.Material = Enum.Material.Grass
    leaves.Anchored = true
    leaves.CanCollide = false
    leaves.Position = trunk.Position + Vector3.new(0, 4, 0)
    leaves.Parent = model

    -- Weld the leaves to the trunk so they stay together
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = trunk
    weld.Part1 = leaves
    weld.Parent = trunk
    
    return model
end

return ResourceTemplate 