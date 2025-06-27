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

    -- Groundsheet / floor
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(8, 0.5, 10)
    floor.Anchored = true
    floor.Material = Enum.Material.Fabric
    floor.Color = Color3.fromRGB(68, 86, 60)
    model.PrimaryPart = floor
    floor.Parent = model

    -- Optional subtle texture
    local floorTex = Instance.new("Texture")
    floorTex.Texture = "rbxassetid://6991202800" -- generic fabric grid
    floorTex.StudsPerTileU = 4
    floorTex.StudsPerTileV = 4
    floorTex.Face = Enum.NormalId.Top
    floorTex.Parent = floor

    -- Helper to create a wedge side (simple A-frame)
    local function createWedge(angleY)
        local wedge = Instance.new("WedgePart")
        wedge.Name = "Side"
        wedge.Size = Vector3.new(8, 4, 0.5)
        wedge.Material = Enum.Material.Fabric
        wedge.Color = Color3.fromRGB(99, 120, 80)
        wedge.Anchored = true
        wedge.Parent = model

        -- Position: stand 2 studs above floor centre; rotate so slope faces inward
        local offset = CFrame.new(0, 2, 0) * CFrame.Angles(0, angleY, 0)
        wedge.CFrame = floor.CFrame * offset

        -- Weld to floor so it moves as one model
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = floor
        weld.Part1 = wedge
                weld.Parent = floor
    end

    -- Left & Right sides
    createWedge(0)           -- slope faces -Z
    createWedge(math.pi)     -- opposite side

    -- Back cloth (optional: simple Part)
    local back = Instance.new("Part")
    back.Name = "Back"
    back.Size = Vector3.new(8, 4, 0.2)
    back.Material = Enum.Material.Fabric
    back.Color = Color3.fromRGB(99, 120, 80)
    back.Anchored = true
    back.CFrame = floor.CFrame * CFrame.new(0, 2, -4.5)
    back.Parent = model
    local weldBack = Instance.new("WeldConstraint")
    weldBack.Part0 = floor
    weldBack.Part1 = back
    weldBack.Parent = floor

    -- Mark for systems
    model:SetAttribute("ObjectType", "TENT")

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

function BuildingTemplate.createCraftingBench()
    local model = Instance.new("Model")
    model.Name = "CraftingBench"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(4, 1, 4)
    base.Anchored = true
    base.Color = Color3.fromRGB(101, 67, 33) -- Wood brown
    base.Material = Enum.Material.WoodPlanks
    base.Parent = model
    model.PrimaryPart = base

    -- Tabletop
    local top = Instance.new("Part")
    top.Name = "Top"
    top.Size = Vector3.new(4, 0.5, 4)
    top.Position = Vector3.new(0, 1, 0)
    top.Anchored = true
    top.Color = Color3.fromRGB(139, 69, 19)
    top.Material = Enum.Material.WoodPlanks
    top.Parent = model

    -- Weld parts together
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = base
    weld.Part1 = top
    weld.Parent = base

    -- Object type attribute so interaction works
    model:SetAttribute("ObjectType", "CRAFTING_BENCH")

    return model
end

function BuildingTemplate.createMarketStall()
    local model = Instance.new("Model")
    model.Name = "MarketStall"

    local base = Instance.new("Part")
    base.Size = Vector3.new(6,1,4)
    base.Anchored = true
    base.Color = Color3.fromRGB(101,67,33)
    base.Material = Enum.Material.WoodPlanks
    base.Name = "Base"
    base.Parent = model
    model.PrimaryPart = base

    -- simple roof canvas
    local roof = Instance.new("Part")
    roof.Size = Vector3.new(6,0.5,4)
    roof.Position = Vector3.new(0,3,0)
    roof.Anchored = true
    roof.Color = Color3.fromRGB(255,0,0)
    roof.Material = Enum.Material.Fabric
    roof.Parent = model

    local pole1 = Instance.new("Part")
    pole1.Size = Vector3.new(0.3,3,0.3)
    pole1.Position = Vector3.new(-2.5,1.5,-1.5)
    pole1.Anchored = true
    pole1.Color = base.Color
    pole1.Material = base.Material
    pole1.Parent = model

    local pole2 = pole1:Clone()
    pole2.Position = Vector3.new(2.5,1.5,-1.5)
    pole2.Parent = model

    local pole3 = pole1:Clone()
    pole3.Position = Vector3.new(-2.5,1.5,1.5)
    pole3.Parent = model

    local pole4 = pole1:Clone()
    pole4.Position = Vector3.new(2.5,1.5,1.5)
    pole4.Parent = model

    -- Weld components
    for _, part in ipairs(model:GetChildren()) do
        if part ~= base then
            local w = Instance.new("WeldConstraint")
            w.Part0 = base
            w.Part1 = part
            w.Parent = base
        end
    end

    model:SetAttribute("ObjectType", "MARKET_STALL")
    return model
end

function BuildingTemplate.createCampfire()
    local model = Instance.new("Model")
    model.Name = "Campfire"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(2,0.5,2)
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(99, 66, 33)
    base.Parent = model
    model.PrimaryPart = base

    local flame = Instance.new("ParticleEmitter")
    flame.Texture = "http://www.roblox.com/asset/?id=243660364"
    flame.Lifetime = NumberRange.new(1)
    flame.Rate = 15
    flame.Speed = NumberRange.new(0)
    flame.Parent = base

    model:SetAttribute("ObjectType","CAMPFIRE")
    return model
end

function BuildingTemplate.createBed()
    local model = Instance.new("Model")
    model.Name = "Bed"

    -- Base frame (for collision and primary part)
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(4, 1, 2)
    base.Anchored = true
    base.Material = Enum.Material.WoodPlanks
    base.Color = Color3.fromRGB(101, 67, 33)
    base.Parent = model
    model.PrimaryPart = base

    local InsertService = game:GetService("InsertService")
    local assetModel
    pcall(function()
        assetModel = InsertService:LoadAsset(15495153644)
    end)

    local bedMesh
    if assetModel then
        -- Find first MeshPart inside
        bedMesh = assetModel:FindFirstChildWhichIsA("MeshPart", true)
        if bedMesh then
            bedMesh.Name = "BedMesh"
            bedMesh.Anchored = true
            bedMesh.Parent = model

            -- Ensure texture is applied; if missing, attempt to copy from another part in asset
            if bedMesh:IsA("MeshPart") and (bedMesh.TextureID == "" or bedMesh.TextureID == nil) then
                for _,desc in ipairs(assetModel:GetDescendants()) do
                    if desc:IsA("MeshPart") and desc.TextureID ~= "" then
                        bedMesh.TextureID = desc.TextureID
                        break
                    end
                end
            end
            bedMesh.Material = Enum.Material.SmoothPlastic
        else
            -- Maybe the asset is a full Model. Use first child as bed model
            local first = assetModel:GetChildren()[1]
            if first and first:IsA("Model") then
                bedMesh = first
                bedMesh.Name = "BedModel"
                bedMesh.Parent = model

                -- Anchor and weld each BasePart inside
                for _,bp in ipairs(bedMesh:GetDescendants()) do
                    if bp:IsA("BasePart") then
                        bp.Anchored = true
                        local w = Instance.new("WeldConstraint")
                        w.Part0 = base
                        w.Part1 = bp
                        w.Parent = base
                    end
                end
            end
        end
    else
        -- LoadAsset failed, fallback block
        bedMesh = Instance.new("Part")
        bedMesh.Size = Vector3.new(4,1.5,2)
        bedMesh.Color = Color3.fromRGB(230,230,230)
        bedMesh.Material = Enum.Material.Fabric
        bedMesh.Anchored = true
        bedMesh.Name = "BedFallback"
        bedMesh.Parent = model
    end

    -- Weld mesh to base
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = base
    weld.Part1 = bedMesh
    weld.Parent = base

    if bedMesh then
        if bedMesh:IsA("BasePart") then
            bedMesh.CFrame = base.CFrame * CFrame.new(0,0.75,0)
        elseif bedMesh:IsA("Model") and bedMesh.PrimaryPart then
            bedMesh:SetPrimaryPartCFrame(base.CFrame * CFrame.new(0,0.75,0))
        end
    end

    model:SetAttribute("ObjectType", "BED")
    return model
end

function BuildingTemplate.createChickenCoop()
    local model = Instance.new("Model")
    model.Name = "ChickenCoop"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(5,1,4)
    base.Anchored = true
    base.Material = Enum.Material.WoodPlanks
    base.Color = Color3.fromRGB(139,94,60)
    base.Parent = model
    model.PrimaryPart = base

    -- simple roof
    local roof = Instance.new("Part")
    roof.Size = Vector3.new(5,0.5,4)
    roof.Position = Vector3.new(0,3,0)
    roof.Anchored = true
    roof.Color = Color3.fromRGB(120,70,40)
    roof.Material = Enum.Material.WoodPlanks
    roof.Parent = model

    -- Weld components
    for _, part in ipairs(model:GetChildren()) do
        if part ~= base then
            local w = Instance.new("WeldConstraint")
            w.Part0 = base
            w.Part1 = part
            w.Parent = base
        end
    end

    model:SetAttribute("ObjectType","CHICKEN_COOP")
    -- Coop state attributes
    model:SetAttribute("Eggs",0)
    model:SetAttribute("LastFed",0)

    return model
end

return BuildingTemplate 