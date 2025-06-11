--[[
    UIManagerV2.lua
    Initializes and manages all client-side UI components.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourceUI = require(script.Parent.ui.ResourceUI)
local PlantingUI = require(script.Parent.ui.PlantingUI)

local UIManagerV2 = {}
local activePlantingMenu = nil

function UIManagerV2.initialize()
    print("UIManagerV2 Initializing...")

    -- We need to get the initial player data to draw the UI correctly
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local getPlayerDataEvent = remotesFolder:WaitForChild("GetPlayerData", 10)
    
    if not getPlayerDataEvent then
        warn("Could not find GetPlayerData remote function. UI will not be initialized.")
        return
    end
    local playerData = getPlayerDataEvent:InvokeServer()
    print("Received initial player data from server.")

    -- Create the UI components
    local resourceDisplay, buildHouseButton, buildPlotButton, eatFoodButton = ResourceUI.create()
    ResourceUI.createLevelBar(playerData)

    -- Listen for updates from the server
    local resourceUpdatedEvent = remotesFolder:WaitForChild("ResourceUpdated")
    resourceUpdatedEvent.OnClientEvent:Connect(function(resourceType, newAmount)
        resourceDisplay:updateResource(resourceType, newAmount)
    end)

    local energyUpdatedEvent = remotesFolder:WaitForChild("EnergyUpdated")
    energyUpdatedEvent.OnClientEvent:Connect(function(newAmount)
        resourceDisplay:updateEnergy(newAmount)
    end)

    local xpUpdatedEvent = remotesFolder:WaitForChild("XPUpdated")
    xpUpdatedEvent.OnClientEvent:Connect(function(xp, xpToNextLevel)
        resourceDisplay:updateXP(xp, xpToNextLevel)
    end)

    local playerLeveledUpEvent = remotesFolder:WaitForChild("PlayerLeveledUp")
    playerLeveledUpEvent.OnClientEvent:Connect(function(newLevel)
        resourceDisplay:updateLevel(newLevel)
    end)

    buildHouseButton.MouseButton1Click:Connect(function()
        local requestBuildEvent = remotesFolder:WaitForChild("RequestBuildAction")
        requestBuildEvent:FireServer("TestHouse")
    end)

    buildPlotButton.MouseButton1Click:Connect(function()
        local requestBuildEvent = remotesFolder:WaitForChild("RequestBuildAction")
        requestBuildEvent:FireServer("FARM_PLOT")
    end)

    eatFoodButton.MouseButton1Click:Connect(function()
        local requestEatFoodEvent = remotesFolder:WaitForChild("RequestEatFood")
        requestEatFoodEvent:FireServer()
    end)

    print("UIManagerV2 setup complete.")
end

function UIManagerV2.showPlantingMenu(plot)
    if activePlantingMenu then
        activePlantingMenu:destroy()
    end

    print("Showing planting menu for plot:", plot.Name)
    activePlantingMenu = PlantingUI.new(plot)
    activePlantingMenu:setParent(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
end

return UIManagerV2 