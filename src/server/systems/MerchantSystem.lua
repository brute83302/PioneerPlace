--[[
    MerchantSystem.lua
    Maintains traveling merchant inventory and handles purchases.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MerchantSystem = {}
local GameSystems

local MerchantItemConfig = require(ReplicatedStorage.Shared.MerchantItemConfig)

-- Rarity order and associated data for seeds
local RARITY_INFO = {
    COMMON    = {order=1, qty=20, price=50},
    UNCOMMON  = {order=2, qty=10, price=100},
    RARE      = {order=3, qty=5,  price=200},
    EPIC      = {order=4, qty=2,  price=400},
    LEGENDARY = {order=5, qty=1,  price=800},
    MYTHICAL  = {order=6, qty=1,  price=1000},
}

-- Build decoration pool from MerchantItemConfig (Category == "DECORATIVE" and currency coins)
local ITEM_POOL = {}
for id, cfg in pairs(MerchantItemConfig) do
    if cfg.Category == "DECORATIVE" and cfg.Currency == "COINS" then
        local rarity = cfg.Rarity:match("([A-Z]+)") or "COMMON"
        table.insert(ITEM_POOL, {
            Id = id,
            Name = cfg.Name,
            Rarity = rarity,
            Price = cfg.Price,
        })
    end
end

-- Ensure pool not empty
if #ITEM_POOL == 0 then
    warn("Decoration ITEM_POOL empty – check MerchantItemConfig.lua")
end

local CURRENT_STOCK = {}
local RESTOCK_INTERVAL = 60*5 -- 5-minute refresh
local lastRestock = 0

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local getMerchantInventoryFn = RemotesFolder:FindFirstChild("GetMerchantInventory") or Instance.new("RemoteFunction",RemotesFolder)
getMerchantInventoryFn.Name = "GetMerchantInventory"

local requestBuyEvent = RemotesFolder:FindFirstChild("RequestBuyItem") or Instance.new("RemoteEvent",RemotesFolder)
requestBuyEvent.Name = "RequestBuyItem"

local inventoryUpdatedEvent = RemotesFolder:WaitForChild("InventoryUpdated")
local resourceUpdatedEvent = RemotesFolder:WaitForChild("ResourceUpdated")
local teleportEvent = RemotesFolder:WaitForChild("RequestTeleportToMerchant")

-- helper to restock merchant
local function restock()
    CURRENT_STOCK = {}
    for _, entry in ipairs(ITEM_POOL) do
        local info = RARITY_INFO[entry.Rarity] or RARITY_INFO.COMMON
        table.insert(CURRENT_STOCK, {
            Id = entry.Id,
            Name = entry.Name,
            Currency = "COINS",
            Price = entry.Price,
            Quantity = info.qty,
            Rarity = entry.Rarity,
            Order = info.order
        })
    end
    -- sort by rarity order ascending (common first)
    table.sort(CURRENT_STOCK, function(a,b) return a.Order < b.Order end)

    lastRestock = os.time()
    print("Decoration shop restocked ("..#CURRENT_STOCK.." items)")
end

local function maybeRestock()
    if os.time() - lastRestock >= RESTOCK_INTERVAL or #CURRENT_STOCK==0 then
        restock()
    end
end

function MerchantSystem.initialize(gs)
    GameSystems = gs
    restock()

    -- Spawn traveling merchant stall (decor / future use)
    if not Workspace:FindFirstChild("TravelingMerchant") then
        local model = Instance.new("Model")
        model.Name = "TravelingMerchant"

        local base = Instance.new("Part")
        base.Name = "Base"
        base.Size = Vector3.new(4,3,2)
        base.Anchored = true
        base.Position = Vector3.new(0,2,0)
        base.Color = Color3.fromRGB(255,215,0)
        base.Parent = model
        model.PrimaryPart = base

        -- Attribute on both for robustness
        model:SetAttribute("ObjectType","TRAVELING_MERCHANT")
        base:SetAttribute("ObjectType","TRAVELING_MERCHANT")

        -- adjust if TownSquare exists
        local ts = Workspace:FindFirstChild("TownSquare")
        if ts and ts.PrimaryPart then
            base.CFrame = ts.PrimaryPart.CFrame * CFrame.new(0,1,0)
        end

        model.Parent = Workspace
    end

    -- Spawn dedicated seed booth
    if not Workspace:FindFirstChild("SeedBooth") then
        local model = Instance.new("Model")
        model.Name = "SeedBooth"

        local base = Instance.new("Part")
        base.Name = "Base"
        base.Size = Vector3.new(4,3,2)
        base.Anchored = true
        base.Color = Color3.fromRGB(124, 184, 76) -- green tint for seeds
        base.Position = Vector3.new(6,2,0)
        base.Parent = model
        model.PrimaryPart = base

        model:SetAttribute("ObjectType","SEED_STALL")
        base:SetAttribute("ObjectType","SEED_STALL")

        -- Position relative to TownSquare if exists
        local ts = Workspace:FindFirstChild("TownSquare")
        if ts and ts.PrimaryPart then
            base.CFrame = ts.PrimaryPart.CFrame * CFrame.new(6,1,0)
        end

        model.Parent = Workspace
    end

    -- Hook teleport requests
    teleportEvent.OnServerEvent:Connect(function(player)
        MerchantSystem.teleportPlayer(player)
    end)

    print("MerchantSystem initialized.")

    -- Remote handlers
    getMerchantInventoryFn.OnServerInvoke = function(player)
        maybeRestock()
        local secondsLeft = RESTOCK_INTERVAL - (os.time()-lastRestock)
        return CURRENT_STOCK, secondsLeft
    end

    requestBuyEvent.OnServerEvent:Connect(function(player,itemId)
        MerchantSystem.buyItem(player,itemId)
    end)
end

function MerchantSystem.buyItem(player,itemId)
    maybeRestock()
    local offer
    for _,it in ipairs(CURRENT_STOCK) do
        if it.Id == itemId then offer = it break end
    end
    if not offer then
        warn("Item not available", itemId); return
    end
    if offer.Quantity <=0 then
        warn("Item sold out", itemId); return
    end

    local data = GameSystems.PlayerService.getPlayerData(player)
    if (data.Resources.COINS or 0) < offer.Price then
        warn("Not enough coins"); return
    end

    -- process purchase
    offer.Quantity -= 1
    data.Resources.COINS -= offer.Price
    resourceUpdatedEvent:FireClient(player,"COINS",data.Resources.COINS)

    data.Inventory[itemId] = (data.Inventory[itemId] or 0)+1
    inventoryUpdatedEvent:FireClient(player,itemId,data.Inventory[itemId])
    print("Player",player.Name,"bought",itemId,"for",offer.Price,"Qty left",offer.Quantity)
end

-- Teleport player to stall (4 studs in front)
function MerchantSystem.teleportPlayer(player)
    local char = player.Character
    if not char or not char.PrimaryPart then return end
    local stall = Workspace:FindFirstChild("TravelingMerchant")
    if stall and stall.PrimaryPart then
        local destination = stall.PrimaryPart.CFrame * CFrame.new(0,0,-4)
        char:SetPrimaryPartCFrame(destination)
    end
end

return MerchantSystem 