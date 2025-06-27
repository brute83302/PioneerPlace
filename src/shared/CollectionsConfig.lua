--[[
    CollectionsConfig.lua
    Shared list of collectible items.
    Each entry: Name (display), Rarity string, Chance (server side only reference)
]]

local COLLECTIONS = {
    FOUR_LEAF_CLOVER = {
        Name = "Four-leaf Clover",
        Rarity = "Uncommon",
        Chance = 0.02,
    },
    GOLDEN_APPLE = {
        Name = "Golden Apple",
        Rarity = "Rare",
        Chance = 0.01,
    },
    RUSTED_HORSESHOE = {
        Name = "Rusted Horseshoe",
        Rarity = "Uncommon",
        Chance = 0.015,
    },
}

return COLLECTIONS 