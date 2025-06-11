local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GameUI = {}

function GameUI:CreateMainScreen()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PioneerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown color
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Pioneer's Journey"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    -- Create resource display
    local resourceFrame = Instance.new("Frame")
    resourceFrame.Name = "ResourceFrame"
    resourceFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
    resourceFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    resourceFrame.BackgroundColor3 = Color3.fromRGB(101, 67, 33) -- Darker brown
    resourceFrame.BorderSizePixel = 0
    resourceFrame.Parent = mainFrame

    -- Resource title
    local resourceTitle = Instance.new("TextLabel")
    resourceTitle.Name = "ResourceTitle"
    resourceTitle.Size = UDim2.new(1, 0, 0.1, 0)
    resourceTitle.Position = UDim2.new(0, 0, 0, 0)
    resourceTitle.BackgroundTransparency = 1
    resourceTitle.Text = "Resources"
    resourceTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    resourceTitle.TextScaled = true
    resourceTitle.Font = Enum.Font.GothamSemibold
    resourceTitle.Parent = resourceFrame

    -- Resource list
    local resources = {"Wood", "Stone", "Food", "Water"}
    for i, resource in ipairs(resources) do
        local resourceLabel = Instance.new("TextLabel")
        resourceLabel.Name = resource .. "Label"
        resourceLabel.Size = UDim2.new(1, 0, 0.15, 0)
        resourceLabel.Position = UDim2.new(0, 0, 0.1 + (i * 0.15), 0)
        resourceLabel.BackgroundTransparency = 1
        resourceLabel.Text = resource .. ": 0"
        resourceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        resourceLabel.TextScaled = true
        resourceLabel.Font = Enum.Font.Gotham
        resourceLabel.Parent = resourceFrame
    end

    -- Create action buttons
    local actionFrame = Instance.new("Frame")
    actionFrame.Name = "ActionFrame"
    actionFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    actionFrame.Position = UDim2.new(0.4, 0, 0.2, 0)
    actionFrame.BackgroundColor3 = Color3.fromRGB(101, 67, 33) -- Darker brown
    actionFrame.BorderSizePixel = 0
    actionFrame.Parent = mainFrame

    -- Action title
    local actionTitle = Instance.new("TextLabel")
    actionTitle.Name = "ActionTitle"
    actionTitle.Size = UDim2.new(1, 0, 0.1, 0)
    actionTitle.Position = UDim2.new(0, 0, 0, 0)
    actionTitle.BackgroundTransparency = 1
    actionTitle.Text = "Actions"
    actionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionTitle.TextScaled = true
    actionTitle.Font = Enum.Font.GothamSemibold
    actionTitle.Parent = actionFrame

    -- Action buttons
    local actions = {"Gather Resources", "Build", "Craft", "Trade"}
    for i, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = action:gsub(" ", "") .. "Button"
        button.Size = UDim2.new(0.8, 0, 0.15, 0)
        button.Position = UDim2.new(0.1, 0, 0.1 + (i * 0.15), 0)
        button.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown
        button.BorderSizePixel = 0
        button.Text = action
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        button.Parent = actionFrame

        -- Add hover effect
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(160, 82, 45) -- Lighter brown
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Original brown
        end)
    end

    return screenGui
end

return GameUI 