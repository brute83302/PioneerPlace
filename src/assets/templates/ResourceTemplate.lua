--[[
    ResourceTemplate.lua
    Defines the visual appearance of resource nodes like trees and rocks.
]]

local ResourceTemplate = {}

-- A private function to create the base model for any resource
local function createBaseModel(resourceType)
    local resourceNode = Instance.new("Model")
    resourceNode.Name = resourceType .. "Node"
    resourceNode:SetAttribute("ObjectType", "RESOURCE_NODE")
    resourceNode:SetAttribute("ResourceType", resourceType)
    
    return resourceNode
end

function ResourceTemplate.create(resourceType)
    if resourceType == "WOOD" then
        local tree = createBaseModel("WOOD")
        
        local trunk = Instance.new("Part")
        trunk.Name = "MainPart" -- Important for positioning and interaction
        trunk.Size = Vector3.new(4, 15, 4)
        trunk.Color = Color3.fromRGB(87, 62, 40) -- Brown
        trunk.Material = Enum.Material.Wood
        trunk.Anchored = true
        trunk.Parent = tree
        
        local leaves = Instance.new("Part")
        leaves.Name = "Leaves"
        leaves.Size = Vector3.new(10, 10, 10)
        leaves.Color = Color3.fromRGB(34, 139, 34) -- ForestGreen
        leaves.Material = Enum.Material.Grass
        leaves.Position = trunk.Position + Vector3.new(0, trunk.Size.Y/2 + leaves.Size.Y/2, 0)
        leaves.Anchored = false -- Will be welded to the trunk so it follows when moved
        leaves.CanCollide = false
        leaves.Parent = tree

        -- Weld the leaves to the trunk so they stay attached when the tree is repositioned
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = trunk
        weld.Part1 = leaves
        weld.Parent = trunk

        tree.PrimaryPart = trunk
        return tree

    elseif resourceType == "STONE" then
        local rock = createBaseModel("STONE")
        
        local stonePart = Instance.new("Part")
        stonePart.Name = "MainPart" -- Important for positioning and interaction
        stonePart.Size = Vector3.new(6, 6, 6)
        stonePart.Color = Color3.fromRGB(128, 128, 128) -- Gray
        stonePart.Material = Enum.Material.Rock
        stonePart.Anchored = true
        stonePart.Parent = rock
        
        rock.PrimaryPart = stonePart
        return rock
    elseif resourceType == "WEED" then
        local weed = createBaseModel("WEED")
        local weedPart = Instance.new("Part")
        weedPart.Name = "MainPart"
        weedPart.Size = Vector3.new(1,1,1)
        weedPart.Color = Color3.fromRGB(85,142,52)
        weedPart.Material = Enum.Material.Grass
        weedPart.Anchored = true
        -- realistic weed texture
        local weedTex = Instance.new("Texture")
        weedTex.Texture = "rbxassetid://12489642357"
        weedTex.Face = Enum.NormalId.Top
        weedTex.StudsPerTileU = 1
        weedTex.StudsPerTileV = 1
        weedTex.Parent = weedPart

        local weedTexSide = weedTex:Clone()
        weedTexSide.Face = Enum.NormalId.Front
        weedTexSide.Parent = weedPart
        weedPart.Parent = weed

        weed.PrimaryPart = weedPart
        return weed
    else
        warn("Attempted to create an unknown resource type:", resourceType)
        return nil
    end
end

return ResourceTemplate 