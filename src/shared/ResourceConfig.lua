local ResourceConfig = {
    -- Basic resources
    WOOD = {
        Category = "BASIC",
        Rarity = "COMMON",
        BaseYield = 10,
        BaseXP = 5,
        RespawnTime = 90, -- seconds
        BaseHP = 3,
        EnergyPerHit = 1,
    },
    STONE = {
        Category = "BASIC",
        Rarity = "COMMON",
        BaseYield = 5,
        BaseXP = 5,
        RespawnTime = 120,
        BaseHP = 4,
        EnergyPerHit = 1,
    },
    FOOD = {
        Category = "CONSUMABLE",
        Rarity = "COMMON",
        BaseYield = 1,
        BaseXP = 2,
        RespawnTime = nil, -- crops handle their own loop
    },

    -- Seeds & Crops
    CLOVER = {
        Category = "CROP",
        Rarity = "COMMON",
        BaseYield = 1,
        BaseXP = 3,
        RespawnTime = nil,
    },
    APPLE = {
        Category = "CROP",
        Rarity = "COMMON",
        BaseYield = 1,
        BaseXP = 3,
        RespawnTime = nil,
    },

    -- Advanced / premium resources
    GOLD_NUGGETS = {
        Category = "PREMIUM",
        Rarity = "RARE",
        BaseYield = 1,
        BaseXP = 0,
        RespawnTime = nil,
    },
    METAL_ORE = {
        Category = "ADVANCED",
        Rarity = "UNCOMMON",
        BaseYield = 3,
        BaseXP = 8,
        RespawnTime = 300, -- 5 minutes for ore
    },
}

-- Helper accessors ----------------------------------------------------------
function ResourceConfig.get(id)
    return ResourceConfig[id]
end

function ResourceConfig.getBaseXP(id)
    local cfg = ResourceConfig[id]
    return cfg and cfg.BaseXP or 3 -- default fallback
end

function ResourceConfig.getRespawnTime(id)
    local cfg = ResourceConfig[id]
    return cfg and cfg.RespawnTime or 60 -- default 1 min
end

function ResourceConfig.getBaseYield(id)
    local cfg = ResourceConfig[id]
    return cfg and cfg.BaseYield or 1
end

function ResourceConfig.getBaseHP(id)
    local cfg = ResourceConfig[id]
    return cfg and cfg.BaseHP or 1
end

function ResourceConfig.getEnergyCost(id)
    local cfg = ResourceConfig[id]
    return cfg and cfg.EnergyPerHit or 1
end

return ResourceConfig 