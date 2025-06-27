--[[
    CraftingSystem.lua
    Handles crafting recipes and inventory items for players.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CraftingSystem = {}
local GameSystems

-- Basic recipe definitions. Key = recipeId / itemId for now.
-- Each recipe has: Name, Cost(resources table), OutputAmount (default 1), XPAward
local RECIPES = {
    WOOD_PLANK = {
        Name = "Wooden Plank",
        Cost = { WOOD = 5 },
        OutputAmount = 1,
        XPAward = 5
    },
    STONE_AXE = {
        Name = "Stone Axe",
        Cost = { WOOD = 10, STONE = 5 },
        OutputAmount = 1,
        XPAward = 15
    },
    CAMPFIRE = {
        Name = "Campfire",
        Cost = { WOOD = 5, STONE = 5 },
        OutputAmount = 1,
        XPAward = 10
    },
    PICKAXE = {
        Name = "Stone Pickaxe",
        Cost = { WOOD = 5, STONE = 10 },
        OutputAmount = 1,
        XPAward = 15
    }
}

-- Cached remote event to report result
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local CraftingResultEvent = RemotesFolder:WaitForChild("CraftingResult")

function CraftingSystem.initialize(gameSystems)
    GameSystems = gameSystems
    print("CraftingSystem initialized.")
end

-- Returns true/false + message
function CraftingSystem.craft(player, recipeId)
    local recipe = RECIPES[recipeId]
    if not recipe then
        warn("Invalid recipeId sent from client:", recipeId)
        CraftingResultEvent:FireClient(player, false, "Unknown recipe")
        return false
    end

    local success = GameSystems.ResourceManager.removeResources(player, recipe.Cost)
    if not success then
        CraftingResultEvent:FireClient(player, false, "Not enough resources")
        return false
    end

    -- Add item(s) to inventory
    local data = GameSystems.PlayerService.getPlayerData(player)
    data.Inventory[recipeId] = (data.Inventory[recipeId] or 0) + (recipe.OutputAmount or 1)

    -- Notify client of inventory change
    local newCount = data.Inventory[recipeId]
    local inventoryUpdatedEvent = RemotesFolder.InventoryUpdated
    inventoryUpdatedEvent:FireClient(player, recipeId, newCount)

    -- Award XP
    if recipe.XPAward and recipe.XPAward > 0 then
        GameSystems.ProgressionSystem.addXP(player, recipe.XPAward)
    end

    -- Quest progress: crafting tasks
    if recipeId == "WOOD_PLANK" then
        GameSystems.QuestSystem.updateQuestProgress(player, "CRAFT_PLANK", "CRAFT_PLANK", 1)
    end

    print("Crafted", recipeId, "for", player.Name)

    -- TODO: hook into quests when crafting quests exist

    CraftingResultEvent:FireClient(player, true, recipeId)
    return true
end

function CraftingSystem.getRecipes()
    return RECIPES
end

return CraftingSystem 