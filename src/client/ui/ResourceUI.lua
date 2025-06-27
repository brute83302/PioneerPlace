--[[
    ResourceUI.lua
    Creates and manages the on-screen display for player resources.
]]

local ResourceUI = {}
ResourceUI.__index = ResourceUI

local frame -- The main UI frame
local resourceLabels = {} -- Table to hold the text labels, e.g., resourceLabels.WOOD
local RunService = game:GetService("RunService")

-- Expose for other UIs (read-only)
ResourceUI._labels = resourceLabels

function ResourceUI.create()
    local self = setmetatable({}, ResourceUI)
    
    -- A ScreenGui is required to render any UI on the screen
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ResourceScreenGui"
    screenGui.ResetOnSpawn = false
    
    -- Stats bar (top center)
    local statsBar = Instance.new("Frame")
    statsBar.Name = "StatsBar"
    statsBar.Size = UDim2.new(0, 450, 0, 30)
    statsBar.Position = UDim2.new(0.5, -225, 0, 80)
    statsBar.BackgroundTransparency = 1
    statsBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    statsBar.BorderSizePixel = 0

    local statsLayout = Instance.new("UIListLayout")
    statsLayout.FillDirection = Enum.FillDirection.Horizontal
    statsLayout.Padding = UDim.new(0,8)
    statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    statsLayout.SortOrder = Enum.SortOrder.Name
    statsLayout.Parent = statsBar

    -- Main container frame for toggle + actions
    frame = Instance.new("Frame")
    frame.Name = "ResourceDisplay"
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 15, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 1 -- Start hidden background
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = frame

    -- Collapsible actions menu frame
    local actionsMenu = Instance.new("Frame")
    actionsMenu.Name = "ActionsMenu"
    actionsMenu.Size = UDim2.new(1, -10, 0, 0) -- height will auto-size
    actionsMenu.BackgroundTransparency = 1
    actionsMenu.Visible = false
    actionsMenu.Parent = frame

    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.Padding = UDim.new(0, 3)
    actionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionsLayout.Parent = actionsMenu

    -- Toggle button to show/hide actions
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleActionsButton"
    toggleButton.Text = "⋯" -- ellipsis icon
    toggleButton.Size = UDim2.new(0, 28, 0, 28)
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleButton.TextColor3 = Color3.new(1,1,1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.LayoutOrder = 100 -- ensure at bottom
    toggleButton.Parent = frame

    toggleButton.MouseButton1Click:Connect(function()
        actionsMenu.Visible = not actionsMenu.Visible
        frame.BackgroundTransparency = actionsMenu.Visible and 0.4 or 1
    end)

    frame.Parent = screenGui -- Parent the frame to the ScreenGui
    statsBar.Parent = screenGui
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") -- Parent the ScreenGui to the PlayerGui

    -- Wood & Stone removed from top bar (now in Inventory)

    local coinLabel = Instance.new("TextLabel")
    coinLabel.Name = "CoinsLabel"
    coinLabel.Text = "Coins: 0"
    coinLabel.Size = UDim2.new(0,0,1,0)
    coinLabel.AutomaticSize = Enum.AutomaticSize.X
    coinLabel.TextColor3 = Color3.fromRGB(212,175,55)
    coinLabel.Font = Enum.Font.SourceSansBold
    coinLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinLabel.BackgroundTransparency = 1
    coinLabel.TextSize = 18
    coinLabel.Parent = statsBar
    resourceLabels.COINS = coinLabel

    local foodLabel = Instance.new("TextLabel")
    foodLabel.Name = "FoodLabel"
    foodLabel.Text = "Food: 0"
    foodLabel.Size = UDim2.new(0,0,1,0)
    foodLabel.AutomaticSize = Enum.AutomaticSize.X
    foodLabel.TextColor3 = Color3.fromRGB(150, 220, 100) -- Light green
    foodLabel.Font = Enum.Font.SourceSansBold
    foodLabel.TextXAlignment = Enum.TextXAlignment.Left
    foodLabel.BackgroundTransparency = 1
    foodLabel.TextSize = 18
    foodLabel.Parent = statsBar
    resourceLabels.FOOD = foodLabel

    local energyLabel = Instance.new("TextLabel")
    energyLabel.Name = "EnergyLabel"
    energyLabel.Text = "Energy: 20"
    energyLabel.Size = UDim2.new(0,0,1,0)
    energyLabel.AutomaticSize = Enum.AutomaticSize.X
    energyLabel.TextColor3 = Color3.fromRGB(255, 223, 0) -- Gold color
    energyLabel.Font = Enum.Font.SourceSansBold
    energyLabel.TextXAlignment = Enum.TextXAlignment.Left
    energyLabel.BackgroundTransparency = 1
    energyLabel.TextSize = 18
    energyLabel.Parent = statsBar
    resourceLabels.ENERGY = energyLabel

    -- Create a button to build a house
    local buildHouseButton = Instance.new("TextButton")
    buildHouseButton.Name = "BuildHouseButton"
    buildHouseButton.Text = "Build House (20W, 10S)"
    buildHouseButton.Size = UDim2.new(1, -10, 0, 25)
    buildHouseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    buildHouseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildHouseButton.Font = Enum.Font.SourceSansBold
    buildHouseButton.LayoutOrder = 4 -- Adjusted layout order
    buildHouseButton.Parent = actionsMenu

    -- Create a button to build a farm plot
    local buildPlotButton = Instance.new("TextButton")
    buildPlotButton.Name = "BuildPlotButton"
    buildPlotButton.Text = "Build Plot (5W)"
    buildPlotButton.Size = UDim2.new(1, -10, 0, 25)
    buildPlotButton.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown
    buildPlotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildPlotButton.Font = Enum.Font.SourceSansBold
    buildPlotButton.LayoutOrder = 5
    buildPlotButton.Parent = actionsMenu

    -- Create a button to build crafting bench
    local buildBenchButton = Instance.new("TextButton")
    buildBenchButton.Name = "BuildBenchButton"
    buildBenchButton.Text = "Build Bench (15W,5S)"
    buildBenchButton.Size = UDim2.new(1, -10, 0, 25)
    buildBenchButton.BackgroundColor3 = Color3.fromRGB(184,134,11) -- dark goldenrod
    buildBenchButton.TextColor3 = Color3.fromRGB(255,255,255)
    buildBenchButton.Font = Enum.Font.SourceSansBold
    buildBenchButton.LayoutOrder = 6
    buildBenchButton.Parent = actionsMenu

    -- Build Bed button
    local buildBedButton = Instance.new("TextButton")
    buildBedButton.Name = "BuildBedButton"
    buildBedButton.Text = "Build Bed (15W,5S)"
    buildBedButton.Size = UDim2.new(1,-10,0,25)
    buildBedButton.BackgroundColor3 = Color3.fromRGB(150,75,0)
    buildBedButton.TextColor3 = Color3.fromRGB(255,255,255)
    buildBedButton.Font = Enum.Font.SourceSansBold
    buildBedButton.LayoutOrder = 7
    buildBedButton.Parent = actionsMenu

    -- Shift eatFoodButton layout order
    local eatFoodOrder = 8

    -- Create a button to eat food for energy
    local eatFoodButton = Instance.new("TextButton")
    eatFoodButton.Name = "EatFoodButton"
    eatFoodButton.Text = "Eat Food (10)"
    eatFoodButton.Size = UDim2.new(1, -10, 0, 25)
    eatFoodButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Forest Green
    eatFoodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    eatFoodButton.Font = Enum.Font.SourceSansBold
    eatFoodButton.LayoutOrder = eatFoodOrder + 1
    eatFoodButton.Parent = actionsMenu

    -- Build Campfire button
    local buildCampfireButton = Instance.new("TextButton")
    buildCampfireButton.Name = "BuildCampfireButton"
    buildCampfireButton.Text = "Build Campfire (5W,5S)"
    buildCampfireButton.Size = UDim2.new(1,-10,0,25)
    buildCampfireButton.BackgroundColor3 = Color3.fromRGB(139,0,0)
    buildCampfireButton.TextColor3 = Color3.fromRGB(255,255,255)
    buildCampfireButton.Font = Enum.Font.SourceSansBold
    buildCampfireButton.LayoutOrder = 9
    buildCampfireButton.Parent = actionsMenu

    -- Build Chicken Coop button
    local buildCoopButton = Instance.new("TextButton")
    buildCoopButton.Name = "BuildCoopButton"
    buildCoopButton.Text = "Build Chicken Coop (20W,10S)"
    buildCoopButton.Size = UDim2.new(1,-10,0,25)
    buildCoopButton.BackgroundColor3 = Color3.fromRGB(160,82,45) -- SaddleBrown
    buildCoopButton.TextColor3 = Color3.fromRGB(255,255,255)
    buildCoopButton.Font = Enum.Font.SourceSansBold
    buildCoopButton.LayoutOrder = 10
    buildCoopButton.Parent = actionsMenu

    -- Create Inventory toggle button
    local invToggleButton = Instance.new("TextButton")
    invToggleButton.Name = "InvToggleButton"
    invToggleButton.Text = "Inventory (E)"
    invToggleButton.Size = UDim2.new(1,-10,0,25)
    invToggleButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
    invToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
    invToggleButton.Font = Enum.Font.SourceSansBold
    invToggleButton.LayoutOrder = 11
    invToggleButton.Parent = actionsMenu

    -- Delete mode toggle button
    local deleteToggleButton = Instance.new("TextButton")
    deleteToggleButton.Name = "DeleteToggleButton"
    deleteToggleButton.Text = "Delete: OFF"
    deleteToggleButton.Size = UDim2.new(1,-10,0,25)
    deleteToggleButton.BackgroundColor3 = Color3.fromRGB(128,0,0)
    deleteToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
    deleteToggleButton.Font = Enum.Font.SourceSansBold
    deleteToggleButton.LayoutOrder = 12
    deleteToggleButton.Parent = actionsMenu

    local DeleteMode = require(script.Parent.Parent.DeleteMode)

    local function refreshButton(state)
        deleteToggleButton.Text = state and "Delete: ON" or "Delete: OFF"
        deleteToggleButton.BackgroundColor3 = state and Color3.fromRGB(200,0,0) or Color3.fromRGB(128,0,0)
    end

    deleteToggleButton.MouseButton1Click:Connect(function()
        DeleteMode.toggle()
        refreshButton(DeleteMode.isActive())
    end)

    -- Keep in sync if toggled elsewhere (e.g., shift hotkey)
    DeleteMode.bind(function(state)
        refreshButton(state)
    end)

    -- Create boost label
    local boostLabel = Instance.new("TextLabel")
    boostLabel.Name = "BoostLabel"
    boostLabel.Text = "Neighbour Boost x2!"
    boostLabel.Size = UDim2.new(0,0,1,0)
    boostLabel.AutomaticSize = Enum.AutomaticSize.X
    boostLabel.TextColor3 = Color3.fromRGB(0,255,255)
    boostLabel.Font = Enum.Font.SourceSansBold
    boostLabel.TextScaled = true
    boostLabel.BackgroundTransparency = 1
    boostLabel.Visible = false
    boostLabel.BackgroundTransparency = 1
    boostLabel.TextSize = 18
    boostLabel.Parent = statsBar
    resourceLabels.BOOST = boostLabel

    -- Sound effect for boost
    local boostSound = Instance.new("Sound")
    -- Use a common public sound asset (coin pickup)
    boostSound.SoundId = "rbxassetid://147722227" -- Power-up sound
    boostSound.Volume = 0.6
    boostSound.Parent = screenGui
    -- Preload the sound so it is ready when boost triggers
    local ContentProvider = game:GetService("ContentProvider")
    pcall(function()
        ContentProvider:PreloadAsync({boostSound})
    end)
    -- Fallback: if the asset fails to load, use default ui click
    boostSound.Loaded:Connect(function()
        if boostSound.IsLoaded ~= true then
            boostSound.SoundId = "rbxasset://sounds/ui_select.wav"
        end
    end)

    self.boostSound = boostSound
    self.boostActive = false

    -- Collections button
    local collectionsButton = Instance.new("TextButton")
    collectionsButton.Name = "CollectionsButton"
    collectionsButton.Text = "Collections (C)"
    collectionsButton.Size = UDim2.new(1,-10,0,25)
    collectionsButton.BackgroundColor3 = Color3.fromRGB(70,70,120)
    collectionsButton.TextColor3 = Color3.fromRGB(255,255,255)
    collectionsButton.Font = Enum.Font.SourceSansBold
    collectionsButton.LayoutOrder = 13
    collectionsButton.Parent = actionsMenu

    -- Go To Market button
    local gotoButton = Instance.new("TextButton")
    gotoButton.Name = "GotoMarketButton"
    gotoButton.Text = "Go To Market"
    gotoButton.Size = UDim2.new(1,-10,0,25)
    gotoButton.BackgroundColor3 = Color3.fromRGB(90,70,40)
    gotoButton.TextColor3 = Color3.fromRGB(255,255,255)
    gotoButton.Font = Enum.Font.SourceSansBold
    gotoButton.LayoutOrder = 14
    gotoButton.Parent = actionsMenu

    -- Remote call
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remoteTP = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestTeleportToMerchant")
    gotoButton.MouseButton1Click:Connect(function()
        remoteTP:FireServer()
    end)

    print("ResourceUI created.")
    return self, buildHouseButton, buildPlotButton, buildBenchButton, buildBedButton, buildCampfireButton, buildCoopButton, eatFoodButton, invToggleButton, collectionsButton, gotoButton
end

function ResourceUI:updateResource(resourceType, amount)
    if resourceLabels[resourceType] then
        resourceLabels[resourceType].Text = resourceType:sub(1,1):upper()..resourceType:sub(2):lower() .. ": " .. tostring(amount)
        print("UI Updated:", resourceType, "to", amount)
    end
end

function ResourceUI:updateEnergy(amount, seconds)
    if resourceLabels.ENERGY then
        resourceLabels.ENERGY.Text = "Energy: " .. tostring(amount)
        if not self.timerLabel then
            self.timerLabel = Instance.new("TextLabel")
            self.timerLabel.Size = UDim2.new(1,-10,0,20)
            self.timerLabel.TextColor3 = Color3.fromRGB(255,223,0)
            self.timerLabel.Font = Enum.Font.SourceSans
            self.timerLabel.TextScaled = true
            self.timerLabel.BackgroundTransparency = 1
            self.timerLabel.Parent = resourceLabels.ENERGY.Parent
            self.timerLabel.LayoutOrder = resourceLabels.ENERGY.LayoutOrder + 1
        end
        if seconds and seconds>0 and amount < 20 then
            self.secondsLeft = seconds
            if not self._timerConn then
                self._timerConn = RunService.Heartbeat:Connect(function(dt)
                    if not self.secondsLeft then return end
                    self.secondsLeft -= dt
                    if self.secondsLeft > 0 then
                        self.timerLabel.Text = string.format("+1 in %ds", math.ceil(self.secondsLeft))
                    else
                        self.timerLabel.Text = "+1 soon" -- placeholder; will update on server tick
                        self._timerConn:Disconnect()
                        self._timerConn = nil
                    end
                end)
            end
        else
            self.timerLabel.Text = ""
            if self._timerConn then
                self._timerConn:Disconnect()
                self._timerConn = nil
            end
        end
        print("UI Updated: ENERGY to", amount)
    end
end

function ResourceUI.createLevelBar(playerData)
    local screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ResourceScreenGui")
    if not screenGui then
        warn("Could not find the main screen gui for the level bar.")
        return
    end

    local levelFrame = Instance.new("Frame")
    levelFrame.Name = "LevelDisplay"
    levelFrame.Size = UDim2.new(0.5, 0, 0, 40)
    levelFrame.Position = UDim2.new(0.5, 0, 0, 10) -- Top center
    levelFrame.AnchorPoint = Vector2.new(0.5, 0)
    levelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    levelFrame.BackgroundTransparency = 0.4
    levelFrame.BorderSizePixel = 0
    levelFrame.Parent = screenGui

    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Text = "Level: " .. tostring(playerData.Level or 1)
    levelLabel.Size = UDim2.new(0, 80, 1, 0)
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.Font = Enum.Font.SourceSansBold
    levelLabel.Parent = levelFrame
    resourceLabels.LEVEL = levelLabel
    
    local xpBarBackground = Instance.new("Frame")
    xpBarBackground.Name = "XPBarBackground"
    xpBarBackground.Size = UDim2.new(1, -95, 0, 16)
    xpBarBackground.Position = UDim2.new(0, 85, 0.5, -8)
    xpBarBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    xpBarBackground.BorderSizePixel = 0
    xpBarBackground.Parent = levelFrame
    
    local xpBarFill = Instance.new("Frame")
    xpBarFill.Name = "XPBarFill"
    local progress = (playerData.XP or 0) / (playerData.XPToNextLevel or 100)
    xpBarFill.Size = UDim2.new(progress, 0, 1, 0)
    xpBarFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255) -- Light Blue
    xpBarFill.BorderSizePixel = 0
    xpBarFill.Parent = xpBarBackground
    resourceLabels.XP_BAR = xpBarFill
end

function ResourceUI:updateXP(xp, xpToNextLevel)
    if resourceLabels.XP_BAR then
        local progress = xp / xpToNextLevel
        resourceLabels.XP_BAR.Size = UDim2.new(progress, 0, 1, 0)
        print("UI Updated: XP Bar to", progress * 100, "%")
    end
end

function ResourceUI:updateLevel(level)
    if resourceLabels.LEVEL then
        resourceLabels.LEVEL.Text = "Level: " .. tostring(level)
        print("UI Updated: Level to", level)
    end
end

function ResourceUI:updateNeighborBoost(isActive)
    if resourceLabels.BOOST then
        resourceLabels.BOOST.Visible = isActive
        if isActive and not self.boostActive then
            -- Play sound once when activated
            if self.boostSound.IsLoaded then
                self.boostSound:Play()
            else
                self.boostSound.Loaded:Wait()
                self.boostSound:Play()
            end
        end
        self.boostActive = isActive
    end
end

-- Display a transient popup when rested energy bonus is received
function ResourceUI:showRestedBonus(amount)
    local screenGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ResourceScreenGui")
    if not screenGui then return end

    local popup = Instance.new("TextLabel")
    popup.Text = "+" .. tostring(amount) .. " Energy (Rested)"
    popup.Size = UDim2.new(0, 200, 0, 40)
    popup.Position = UDim2.new(0.5, -100, 0.6, 0)
    popup.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    popup.BackgroundTransparency = 0.2
    popup.TextColor3 = Color3.new(1,1,1)
    popup.Font = Enum.Font.SourceSansBold
    popup.TextScaled = true
    popup.Parent = screenGui

    -- Tween fade and move up
    local TweenService = game:GetService("TweenService")
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(popup, info, {Position = popup.Position - UDim2.new(0,0,0.05,0)}):Play()
    task.delay(2, function()
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local fade = TweenService:Create(popup, fadeInfo, {BackgroundTransparency = 1, TextTransparency = 1})
        fade:Play()
        fade.Completed:Wait()
        popup:Destroy()
    end)
end

function ResourceUI.getResourceCounts()
    local counts = {}
    for res, lbl in pairs(resourceLabels) do
        if lbl:IsA("TextLabel") then
            local num = tonumber(lbl.Text:match("%d+%S*$")) or 0
            counts[res] = num
        end
    end
    return counts
end

return ResourceUI 