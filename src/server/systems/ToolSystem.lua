--[[
    ToolSystem.lua
    Handles equipping tools and exposes helper for resource bonuses.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolSystem = {}
local GameSystems

-- simple config mapping tools to resource bonus multipliers
local TOOL_BONUS = {
    STONE_AXE = { WOOD = 2 }, -- double wood yield
    PICKAXE = { STONE = 2 }
}

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local ToolEquippedEvent = RemotesFolder:WaitForChild("ToolEquipped")

function ToolSystem.initialize(gs)
    GameSystems = gs
    print("ToolSystem initialized.")
end

function ToolSystem.equipTool(player, toolId)
    local data = GameSystems.PlayerService.getPlayerData(player)

    -- ensure player owns item in inventory
    if (data.Inventory[toolId] or 0) <= 0 then
        warn("Player tried to equip unowned tool", toolId)
        return
    end

    if data.EquippedTool == toolId then
        -- unequip
        data.EquippedTool = nil
        print("Unequipped", toolId, "for", player.Name)
        ToolEquippedEvent:FireClient(player, "NONE")
        return
    end

    data.EquippedTool = toolId
    print("Equipped", toolId, "for", player.Name)
    ToolEquippedEvent:FireClient(player, toolId)
end

function ToolSystem.getBonus(player, resourceType)
    local data = GameSystems.PlayerService.getPlayerData(player)
    local toolId = data.EquippedTool
    if not toolId then return 1 end
    local bonusTable = TOOL_BONUS[toolId]
    if bonusTable and bonusTable[resourceType] then
        return bonusTable[resourceType]
    end
    return 1
end

return ToolSystem 