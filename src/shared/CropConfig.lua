--[[
    CropConfig.lua
    A central configuration file for all crop types in the game.
]]

local CropConfig = {
    -- CropType = { Name = "Display Name", GrowthTime = seconds, Yield = amount }
    CLOVER = { Name = "Clover", GrowthTime = 300, Yield = 1 },
    TOMATOES = { Name = "Tomatoes", GrowthTime = 900, Yield = 1 },
    PUMPKINS = { Name = "Pumpkins", GrowthTime = 3600, Yield = 1 },
    POTATOES = { Name = "Potatoes", GrowthTime = 14400, Yield = 2 },
    WHEAT = { Name = "Wheat", GrowthTime = 86400, Yield = 4 },
    COTTON = { Name = "Cotton", GrowthTime = 259200, Yield = 4 },
    FLAX = { Name = "Flax", GrowthTime = 28800, Yield = 2 },
    CORN = { Name = "Corn", GrowthTime = 43200, Yield = 3 },
    PEAS = { Name = "Peas", GrowthTime = 172800, Yield = 4 },
    PEANUTS = { Name = "Peanuts", GrowthTime = 345600, Yield = 5 },
    SUNFLOWERS = { Name = "Sunflowers", GrowthTime = 64800, Yield = 3 },
    EGGPLANT = { Name = "Eggplant", GrowthTime = 7200, Yield = 3 },
}

return CropConfig 