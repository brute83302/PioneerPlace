--[[
    BulletinBoardUI.lua
    Displays tasks from the bulletin board.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getTasksFn = remotes:WaitForChild("GetBulletinTasks")
local acceptTaskEvent = remotes:WaitForChild("AcceptBulletinTask")

local BulletinBoardUI = {}
BulletinBoardUI.__index = BulletinBoardUI

function BulletinBoardUI.new()
    local self = setmetatable({}, BulletinBoardUI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "BulletinBoardUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 300)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.BackgroundColor3 = Color3.fromRGB(45,35,25)
    frame.BackgroundTransparency = 0.05
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundTransparency = 1
    title.Text = "Community Bulletin"
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = frame

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1,-10,1,-40)
    list.Position = UDim2.new(0,5,0,35)
    list.BackgroundTransparency = 1
    list.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,4)
    layout.Parent = list

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,24,0,24)
    close.Position = UDim2.new(1,-28,0,4)
    close.Text = "X"
    close.Parent = frame

    local function refresh()
        for _,c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local tasks = getTasksFn:InvokeServer()
        for _,task in ipairs(tasks) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,60)
            row.BackgroundTransparency = 0.25
            row.BackgroundColor3 = Color3.fromRGB(80,60,40)
            row.Parent = list

            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(0.6,0,0.5,0)
            name.Position = UDim2.new(0,5,0,0)
            name.BackgroundTransparency = 1
            name.Text = task.Name
            name.TextScaled = true
            name.Font = Enum.Font.GothamBold
            name.TextColor3 = Color3.new(1,1,1)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0.6,0,0.5,0)
            desc.Position = UDim2.new(0,5,0.5,0)
            desc.BackgroundTransparency = 1
            desc.TextWrapped = true
            desc.Text = task.Description
            desc.TextScaled = true
            desc.Font = Enum.Font.Gotham
            desc.TextColor3 = Color3.new(0.9,0.9,0.9)
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = row

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.35,0,0.6,0)
            btn.Position = UDim2.new(0.65,0,0.2,0)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.Parent = row

            if task.Completed then
                btn.Text = "Done!"
                btn.BackgroundColor3 = Color3.fromRGB(0,130,0)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Active = false
                btn.AutoButtonColor = false
            elseif task.Accepted then
                btn.Text = "In Progress"
                btn.BackgroundColor3 = Color3.fromRGB(200,200,0)
                btn.TextColor3 = Color3.new(0,0,0)
                btn.Active = false
                btn.AutoButtonColor = false
            else
                btn.Text = "Accept"
                btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.MouseButton1Click:Connect(function()
                    acceptTaskEvent:FireServer(task.Id)
                    btn.Text = "Accepted!"
                    btn.Active = false
                    btn.AutoButtonColor = false
                end)
            end
        end
    end

    refresh()

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        if self.onDestroy then self.onDestroy() end
    end)

    function self:setOnDestroy(cb)
        self.onDestroy = cb
    end

    return self
end

return BulletinBoardUI 