local NodeHPGui = {}

local active = {}
local Debris = game:GetService("Debris")

local function createBillboard(model, maxHP)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,60,0,14)
    bb.AlwaysOnTop = true
    bb.Name = "HPBillboard"

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bg.BorderSizePixel = 0
    bg.Parent = bb

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1,0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(0,200,0)
    bar.BorderSizePixel = 0
    bar.Parent = bg

    local txt = Instance.new("TextLabel")
    txt.Name = "Text"
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.Parent = bb

    bb.Parent = model.PrimaryPart
    active[model] = {gui=bb,max=maxHP}
end

local function update(model, hp, maxHP)
    if hp<=0 then
        if active[model] and active[model].gui then
            active[model].gui:Destroy()
        end
        active[model]=nil
        return
    end
    if not active[model] or not active[model].gui then
        createBillboard(model,maxHP)
    end
    local guiData = active[model]
    local bb=guiData.gui
    local bar=bb.Bar
    bar.Size = UDim2.new(hp/maxHP,0,1,0)
    bb.Text.Text = hp.."/"..maxHP
end

function NodeHPGui.init()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local event = remotes:WaitForChild("NodeHPUpdate")
    event.OnClientEvent:Connect(function(model,hp,maxHP)
        if model and model:IsDescendantOf(workspace) and model.PrimaryPart then
            update(model,hp,maxHP)
        end
    end)
end

return NodeHPGui 