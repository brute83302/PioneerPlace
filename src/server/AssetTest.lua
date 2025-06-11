--[[
    AssetTest.lua
    A test script to create starting resources for the player.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ResourceTemplate = require(ReplicatedStorage.Assets.templates.resources.ResourceTemplate)

-- Create a single harvestable resource
local function createHarvestableResource(name, resourceType, position)
    local model
    if resourceType == "STONE" then
        model = ResourceTemplate.createRock()
    else
        model = ResourceTemplate.createTree()
    end
    
    model.Name = name
    model:SetPrimaryPartCFrame(CFrame.new(position))
    model:SetAttribute("ResourceType", resourceType)
    model:SetAttribute("ObjectType", "RESOURCE_NODE") -- The crucial attribute!
    model.Parent = Workspace
end

-- Create some test resources
local function createTestResources()
    print("Creating harvestable test resources...")
    -- Create a few rocks and trees in predictable locations for testing
    createHarvestableResource("HarvestableRock1", "STONE", Vector3.new(10, 0, 10))
    createHarvestableResource("HarvestableRock2", "STONE", Vector3.new(-10, 0, 10))
    createHarvestableResource("HarvestableRock3", "STONE", Vector3.new(15, 0, 5))
    createHarvestableResource("HarvestableTree1", "WOOD", Vector3.new(10, 0, -10))
    createHarvestableResource("HarvestableTree2", "WOOD", Vector3.new(-10, 0, -10))
    createHarvestableResource("HarvestableTree3", "WOOD", Vector3.new(-15, 0, -5))

    print("Created 6 harvestable test resources.")
end

-- Main test function
local function runTest()
    print("Starting Server Asset Test...")
    createTestResources()
    print("Server Asset Test Complete!")
end

-- Export the runTest function so the init script can call it.
return {
    runTest = runTest
} 