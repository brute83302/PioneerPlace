--[[
    SellingSystem.lua
    Allows players to sell items from inventory for coins.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local BuildingTemplate = require(ReplicatedStorage.Assets.templates.buildings.BuildingTemplate)

local PRICE_TABLE = {
    WOOD_PLANK = 2,
    STONE_AXE = 5,
    PICKAXE = 5,
    CAMPFIRE = 4,
    STONE = 1,
    WOOD = 1,
    FOOD = 1,
    MEAL = 3,
}

local SellingSystem = {}
local GameSystems

-- Remote for result
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local inventoryUpdatedEvent = RemotesFolder:WaitForChild("InventoryUpdated")
local resourceUpdatedEvent = RemotesFolder:WaitForChild("ResourceUpdated")

function SellingSystem.initialize(gs)
    GameSystems = gs

    -- Spawn central market stall once
    if not Workspace:FindFirstChild("CentralMarketStall") then
        local stall = BuildingTemplate.createMarketStall()
        stall.Name = "CentralMarketStall"
        -- place near TownSquare if exists
        local ts = Workspace:FindFirstChild("TownSquare")
        if ts and ts.PrimaryPart then
            stall:SetPrimaryPartCFrame(ts.PrimaryPart.CFrame * CFrame.new(25,0,0))
        else
            stall:SetPrimaryPartCFrame(CFrame.new(10,0,0))
        end
        stall.Parent = Workspace
        print("Central Market Stall spawned.")
    end

    print("SellingSystem initialized.")
end

function SellingSystem.registerStall(model)
    -- placeholder for future stall list handling
    model:SetAttribute("IsMarketStall", true)
end

function SellingSystem.sell(player, itemId, amount)
    amount = math.clamp(amount,1,100)
    local price = PRICE_TABLE[itemId]
    if not price then
        warn("Attempted to sell unknown item", itemId)
        return
    end

    local data = GameSystems.PlayerService.getPlayerData(player)
    if not data then return end

    -- Determine whether the item is stored in Inventory or Resources
    local inInventory = data.Inventory[itemId] and data.Inventory[itemId] > 0
    local inResources = data.Resources[itemId] and data.Resources[itemId] > 0

    if not inInventory and not inResources then
        warn("Player",player.Name,"does not own",itemId)
        return
    end

    if inInventory then
        if data.Inventory[itemId] < amount then amount = data.Inventory[itemId] end
        data.Inventory[itemId] -= amount
        inventoryUpdatedEvent:FireClient(player,itemId,data.Inventory[itemId])
    else
        if data.Resources[itemId] < amount then amount = data.Resources[itemId] end
        data.Resources[itemId] -= amount
        resourceUpdatedEvent:FireClient(player,itemId,data.Resources[itemId])
    end

    -- Credit coins
    local earned = price * amount
    data.Resources.COINS = (data.Resources.COINS or 0) + earned
    resourceUpdatedEvent:FireClient(player,"COINS",data.Resources.COINS)

    print("Player",player.Name,"sold",amount,itemId,"for",earned,"coins")
end

return SellingSystem 