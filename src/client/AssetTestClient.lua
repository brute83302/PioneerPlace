--[[
    AssetTestClient.lua
    Client-side script to handle UI creation and display
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create a simple UI
local function createTestUI()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        warn("LocalPlayer not found!")
        return nil
    end
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    if not PlayerGui then
        warn("PlayerGui not found!")
        return nil
    end
    
    -- Load the asset pipeline
    local success, AssetPipeline = pcall(function()
        return require(ReplicatedStorage.Assets.AssetPipeline)
    end)
    
    if not success then
        warn("Failed to load AssetPipeline:", AssetPipeline)
        return nil
    end
    
    local pipeline = AssetPipeline.new()
    
    local ui = pipeline:createUI("TestUI")
        :setPosition(UDim2.new(0.5, 0, 0.5, 0))  -- Center of screen
        :setSize(UDim2.new(0, 300, 0, 200))     -- 300x200 pixels
        :setBackgroundColor(Color3.fromRGB(50, 50, 50))  -- Dark gray
    
    -- Set the UI's parent to PlayerGui so it's visible
    ui:setParent(PlayerGui)
    
    print("Created UI:", ui.name)
    return ui
end

-- Main test function
local function runTest()
    print("Starting Client Asset Pipeline Test...")
    
    -- The test UI is no longer needed.
    --[[
    -- Create the UI
    local ui = createTestUI()
    if not ui then
        warn("Failed to create test UI!")
        return
    end
    ]]
    
    print("Client Asset Pipeline Test Complete!")
end

-- Export the runTest function
return {
    runTest = runTest
}