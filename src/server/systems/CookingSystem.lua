--[[
    CookingSystem.lua
    Handles turning raw food into cooked meals which restore more energy.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CookingSystem = {}
local GameSystems

local RECIPES = {
    SIMPLE_MEAL = {
        Name = "Simple Meal",
        Cost = { FOOD = 5, WOOD = 1 }, -- wood as fuel
        Output = { MEAL = 1 },
        EnergyRestore = 10,
        CookTime = 0, -- instant for now
    },
    HEARTY_STEW = {
        Name = "Hearty Stew",
        Cost = { FOOD = 10, WOOD = 2 },
        Output = { MEAL = 2 },
        EnergyRestore = 20,
        CookTime = 0,
    },
}

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local cookingResultEvent = RemotesFolder:FindFirstChild("CookingResult") or Instance.new("RemoteEvent", RemotesFolder)
CookingSystem.eventName = "CookingResult"
cookingResultEvent.Name = "CookingResult"

-- Table to remember the last time each player cooked, enforcing a short cooldown
local lastCookTimes = {}
local COOK_COOLDOWN = 10 -- seconds between uses per player

function CookingSystem.initialize(gs)
    GameSystems = gs
    print("CookingSystem initialized.")
end

function CookingSystem.cook(player, recipeId)
    local recipe = RECIPES[recipeId]
    if not recipe then
        cookingResultEvent:FireClient(player,false,"Unknown recipe")
        return
    end

    -- cooldown check
    local last = lastCookTimes[player] or 0
    if tick() - last < COOK_COOLDOWN then
        local remaining = math.ceil(COOK_COOLDOWN - (tick() - last))
        cookingResultEvent:FireClient(player,false,"Campfire cooling down ("..remaining.."s)")
        return
    end

    -- check resources
    local success = GameSystems.ResourceManager.removeResources(player, recipe.Cost)
    if not success then
        cookingResultEvent:FireClient(player,false,"Not enough resources")
        return
    end

    -- add to inventory
    local data = GameSystems.PlayerService.getPlayerData(player)
    for item, amt in pairs(recipe.Output) do
        data.Inventory[item] = (data.Inventory[item] or 0)+amt
        RemotesFolder.InventoryUpdated:FireClient(player,item,data.Inventory[item])
    end

    lastCookTimes[player] = tick()

    -- Quest progress for cooking
    GameSystems.QuestSystem.updateQuestProgress(player, "COOK_MEAL", "COOK_MEAL", 1)
    GameSystems.QuestSystem.updateQuestProgress(player, "DAILY_HOME_COOKING", "COOK_MEAL", 1)

    cookingResultEvent:FireClient(player,true,recipeId)
end

-- consumption handled in EnergySystem
function CookingSystem.consumeMeal(player)
    local data = GameSystems.PlayerService.getPlayerData(player)
    if (data.Inventory.MEAL or 0) <=0 then return false end
    data.Inventory.MEAL -=1
    RemotesFolder.InventoryUpdated:FireClient(player,"MEAL",data.Inventory.MEAL)

    -- Determine how much energy to restore based on meal type. Default 10
    local energyToRestore = 10
    -- If the player just consumed one of multiple MEAL items, we cannot know which recipe produced it.
    -- Assume average value, or try to detect if Hearty stew produced +2 meals (rare). For simplicity use 10 each.
    GameSystems.EnergySystem.addEnergy(player,energyToRestore)
    return true
end

function CookingSystem.getRecipes()
    return RECIPES
end

return CookingSystem 