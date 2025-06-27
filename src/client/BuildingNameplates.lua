local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local BuildingNameplates = {}

local function addBillboard(model)
    if model:FindFirstChild("NameplateGui") then return end
    local ownerName = model:GetAttribute("OwnerName")
    if not ownerName or ownerName == Players.LocalPlayer.Name then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "NameplateGui"
    gui.Size = UDim2.new(0,100,0,25)
    gui.StudsOffset = Vector3.new(0,3,0)
    gui.AlwaysOnTop = true
    gui.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Text = ownerName .. "'s"
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

function BuildingNameplates.init()
    -- Attach to existing
    for _,m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("OwnerName") then
            addBillboard(m)
        end
    end
    -- Listen for future
    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            wait(0.1)
            if child:GetAttribute("OwnerName") then
                addBillboard(child)
            end
        end
    end)
end

return BuildingNameplates 