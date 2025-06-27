--[[
    UIManagerV2.lua
    Initializes and manages all client-side UI components.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourceUI = require(script.Parent.ui.ResourceUI)
local PlantingUI = require(script.Parent.ui.PlantingUI)
local QuestUI = require(script.Parent.ui.QuestUI)
local CraftingUI = require(script.Parent.ui.CraftingUI)
local InventoryUI = require(script.Parent.ui.InventoryUI)
local MarketUI = require(script.Parent.ui.MarketUI)
local CookingUI = require(script.Parent.ui.CookingUI)
local MerchantUI = require(script.Parent.ui.MerchantUI)
local ChickenUI = require(script.Parent.ui.ChickenUI)
local BulletinBoardUI = require(script.Parent.ui.BulletinBoardUI)
local PlacementController = require(script.Parent.controllers.PlacementController)

local UIManagerV2 = {}
local activePlantingMenu = nil
local activeCraftingMenu = nil
local activeMarketMenu = nil
local activeCookingMenu = nil
local activeMerchantMenu = nil
local activeChickenMenu = nil
local activeBulletinUI = nil

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
    local resourceDisplay, buildHouseButton, buildPlotButton, buildBenchButton, buildBedButton, buildCampfireButton, buildCoopButton, buildWoodSiloButton, buildStoneShedButton, buildFoodCellarButton, eatFoodButton, invToggleButton, deleteToggleButton, collectionsButton, gotoMarketButton = ResourceUI.create()
    ResourceUI.createLevelBar(playerData)

    -- Create Quest UI
    local questUI = QuestUI.new(playerData.Quests)

    -- Create Inventory UI
    local inventoryUI = InventoryUI.new()
    UIManagerV2.inventoryUI = inventoryUI

    -- Populate existing inventory from playerData
    for itemId, count in pairs(playerData.Inventory or {}) do
        inventoryUI:updateItem(itemId, count)
    end

    -- Populate resource rows for Wood & Stone so they appear in inventory list
    local initialResources = { WOOD = playerData.Resources.WOOD or 0, STONE = playerData.Resources.STONE or 0 }
    for res, amt in pairs(initialResources) do
        inventoryUI:updateItem(res, amt)
    end

    local function toggleInventory()
        inventoryUI.gui.Enabled = not inventoryUI.gui.Enabled
    end

    invToggleButton.MouseButton1Click:Connect(toggleInventory)

    -- Collections UI
    local CollectionsUI = require(script.Parent.ui.CollectionsUI)
    local collectionsUI = CollectionsUI.new(playerData.Collections)

    local function toggleCollections()
        collectionsUI:setVisible(not collectionsUI.gui.Enabled)
    end

    collectionsButton.MouseButton1Click:Connect(toggleCollections)

    -- Hotkey toggles
    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.C then
            toggleCollections()
        elseif input.KeyCode == Enum.KeyCode.E then
            toggleInventory()
        end
    end)

    -- Listen for updates from the server
    local resourceUpdatedEvent = remotesFolder:WaitForChild("ResourceUpdated")
    resourceUpdatedEvent.OnClientEvent:Connect(function(resourceType, newAmount)
        resourceDisplay:updateResource(resourceType, newAmount)
        if activeMarketMenu then
            activeMarketMenu:updateItem(resourceType, newAmount)
        end
        -- Keep inventory rows for WOOD & STONE in sync
        if resourceType == "WOOD" or resourceType == "STONE" then
            inventoryUI:updateItem(resourceType, newAmount)
        end
    end)

    local energyUpdatedEvent = remotesFolder:WaitForChild("EnergyUpdated")
    energyUpdatedEvent.OnClientEvent:Connect(function(newAmount, seconds)
        resourceDisplay:updateEnergy(newAmount, seconds)
    end)

    local xpUpdatedEvent = remotesFolder:WaitForChild("XPUpdated")
    xpUpdatedEvent.OnClientEvent:Connect(function(xp, xpToNextLevel)
        resourceDisplay:updateXP(xp, xpToNextLevel)
    end)

    local restedBonusEvent = remotesFolder:FindFirstChild("RestedBonusGranted")
    if restedBonusEvent then
        restedBonusEvent.OnClientEvent:Connect(function(amount)
            if amount and amount > 0 and resourceDisplay.showRestedBonus then
                resourceDisplay:showRestedBonus(amount)
            end
        end)
    end

    local playerLeveledUpEvent = remotesFolder:WaitForChild("PlayerLeveledUp")
    playerLeveledUpEvent.OnClientEvent:Connect(function(newLevel)
        resourceDisplay:updateLevel(newLevel)
    end)

    -- Quest events
    local questAssignedEvent = remotesFolder:WaitForChild("QuestAssigned")
    questAssignedEvent.OnClientEvent:Connect(function(questId, questData)
        questUI:addQuest(questId, questData)
    end)

    local questProgressEvent = remotesFolder:WaitForChild("QuestProgressUpdated")
    questProgressEvent.OnClientEvent:Connect(function(questId, progressTable, completed)
        questUI:updateQuestProgress(questId, progressTable, completed)
    end)

    local questCompletedEvent = remotesFolder:WaitForChild("QuestCompleted")
    questCompletedEvent.OnClientEvent:Connect(function(questId)
        questUI:updateQuestProgress(questId, {}, true)
    end)

    -- Inventory updates
    local inventoryUpdatedEvent = remotesFolder:WaitForChild("InventoryUpdated")
    inventoryUpdatedEvent.OnClientEvent:Connect(function(itemId, count)
        inventoryUI:updateItem(itemId, count)
        if activeMarketMenu then
            activeMarketMenu:updateItem(itemId, count)
        end
    end)

    local neighborBoostEvent = remotesFolder:WaitForChild("NeighborBoostChanged")
    neighborBoostEvent.OnClientEvent:Connect(function(active)
        resourceDisplay:updateNeighborBoost(active)
    end)

    buildHouseButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("TestHouse", playerData)
    end)

    buildPlotButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("FARM_PLOT", playerData)
    end)

    buildBenchButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("CRAFTING_BENCH", playerData)
    end)

    buildBedButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("BED", playerData)
    end)

    buildCampfireButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("CAMPFIRE_BUILD", playerData)
    end)

    buildCoopButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("CHICKEN_COOP", playerData)
    end)

    buildWoodSiloButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("WOOD_SILO", playerData)
    end)

    buildStoneShedButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("STONE_SHED", playerData)
    end)

    buildFoodCellarButton.MouseButton1Click:Connect(function()
        PlacementController:enterPlacementMode("FOOD_CELLAR", playerData)
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

function UIManagerV2.showCraftingMenu(bench)
    if activeCraftingMenu then
        activeCraftingMenu:destroy()
    end

    print("Showing crafting menu for bench:", bench.Name)
    activeCraftingMenu = CraftingUI.new(bench)
    activeCraftingMenu:setOnDestroy(function()
        activeCraftingMenu = nil
    end)
end

function UIManagerV2.showMarketMenu(stall)
    -- Toggle behaviour: if open, close it
    if activeMarketMenu then
        activeMarketMenu:destroy()
        activeMarketMenu = nil
        return
    end

    local snapshot = {}
    -- Inventory counts
    for id, lbl in pairs(UIManagerV2.inventoryUI.labels or {}) do
        local text = lbl.Text
        local count = tonumber(text:match("%d+$")) or 0
        snapshot[id] = count
    end
    -- Resource counts (WOOD, STONE, FOOD)
    local resCounts = ResourceUI.getResourceCounts and ResourceUI.getResourceCounts() or {}
    for res, amt in pairs(resCounts) do
        if res ~= "COINS" and res ~= "ENERGY" then
            snapshot[res] = amt
        end
    end

    activeMarketMenu = MarketUI.new(snapshot)
    activeMarketMenu:setOnDestroy(function()
        activeMarketMenu = nil
    end)
end

function UIManagerV2.showCookingMenu(campfire)
    if activeCookingMenu then
        activeCookingMenu:destroy()
    end
    activeCookingMenu = CookingUI.new()
    activeCookingMenu:setOnDestroy(function()
        activeCookingMenu = nil
    end)
end

function UIManagerV2.showMerchantMenu()
    if activeMerchantMenu then activeMerchantMenu:destroy() end
    activeMerchantMenu = MerchantUI.new()
    activeMerchantMenu:setOnDestroy(function() activeMerchantMenu=nil end)
end

function UIManagerV2.showChickenMenu(coop)
    if activeChickenMenu then activeChickenMenu:destroy() end
    activeChickenMenu = ChickenUI.new(coop)
end

function UIManagerV2.showBulletinBoard()
    if activeBulletinUI then
        activeBulletinUI:destroy()
        activeBulletinUI = nil
        return
    end
    activeBulletinUI = BulletinBoardUI.new()
    activeBulletinUI:setOnDestroy(function()
        activeBulletinUI = nil
    end)
end

return UIManagerV2 