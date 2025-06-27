local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local QuestConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("QuestConfig"))

local QuestUI = {}
QuestUI.__index = QuestUI

-- Utility to quickly compute overall progress (sum across objectives)
local function computeTotals(questId, progressTable)
    local cfg = QuestConfig[questId]
    if not cfg then return 0,0 end
    local done, req = 0, 0
    for obj, amountNeeded in pairs(cfg.Objectives) do
        req = req + amountNeeded
        done = done + (progressTable[obj] or 0)
    end
    if done > req then done = req end
    return done, req
end

function QuestUI.new(initialQuests)
    local self = setmetatable({}, QuestUI)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- ScreenGui root
    local gui = Instance.new("ScreenGui")
    gui.Name = "QuestUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    -- Container anchored to bottom-right
    local container = Instance.new("Frame")
    container.Name = "QuestContainer"
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1, -10, 1, -10)
    container.Size = UDim2.new(0.25, 0, 0.3, 0)
    container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = container

    -- Current quest display at top center
    local currentLabel = Instance.new("TextLabel")
    currentLabel.Name = "CurrentQuestLabel"
    currentLabel.Size = UDim2.new(0, 320, 0, 32)
    currentLabel.Position = UDim2.new(0.5, -160, 0, 10)
    currentLabel.AnchorPoint = Vector2.new(0.5,0)
    currentLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    currentLabel.BackgroundTransparency = 0.35
    currentLabel.TextColor3 = Color3.fromRGB(255,255,255)
    currentLabel.Font = Enum.Font.GothamBold
    currentLabel.TextScaled = true
    currentLabel.Visible = false
    currentLabel.Parent = gui

    self.container = container
    self.entries = {}
    self.currentLabel = currentLabel
    self.selectedQuestId = nil

    -- Populate existing quests
    for questId, data in pairs(initialQuests or {}) do
        self:addQuest(questId, data)
    end

    return self
end

-- Creates a visual entry for a quest
function QuestUI:addQuest(questId, questData)
    if self.entries[questId] then return end -- already present

    local cfg = QuestConfig[questId]
    if not cfg then return end

    local row = Instance.new("Frame")
    row.Name = questId .. "Row"
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = self.container

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = cfg.Name
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Parent = row

    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "Progress"
    progressLabel.Size = UDim2.new(0.4, 0, 1, 0)
    progressLabel.Position = UDim2.new(0.6, 0, 0, 0)
    progressLabel.BackgroundTransparency = 1
    progressLabel.TextScaled = true
    progressLabel.Font = Enum.Font.GothamBold
    progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressLabel.Parent = row

    -- Click to set as current quest
    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.selectedQuestId == questId then
                -- Deselect
                self.selectedQuestId = nil
                self.currentLabel.Visible = false
                row.BackgroundTransparency = 1
            else
                -- Select new quest
                -- clear highlight previous
                if self.selectedQuestId and self.entries[self.selectedQuestId] then
                    self.entries[self.selectedQuestId].row.BackgroundTransparency = 1
                end
                self.selectedQuestId = questId
                row.BackgroundTransparency = 0.2
                local done, req = computeTotals(questId, questData.Progress or {})
                self.currentLabel.Text = cfg.Name .. "  (".. done .. "/" .. req .. ")"
                self.currentLabel.Visible = true
            end
        end
    end)

    self.entries[questId] = {
        row = row,
        progressLabel = progressLabel
    }

    -- Set initial state
    self:updateQuestProgress(questId, questData.Progress or {}, questData.Completed)
end

function QuestUI:updateQuestProgress(questId, progressTable, completed)
    local entry = self.entries[questId]
    if not entry then return end

    if completed then
        entry.progressLabel.Text = "Done!"
        entry.progressLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        return
    end

    local done, req = computeTotals(questId, progressTable)
    entry.progressLabel.Text = string.format("%d/%d", done, req)
end

return QuestUI 