--[[
    CropConfig.lua
    A central configuration file for all crop types in the game.
]]

local CropConfig = {
    -- CropType = { Name = "Display Name", GrowthTime = seconds, WitherTime = seconds, Yield = amount }
    CLOVER = { Name = "Clover", GrowthTime = 30, WitherTime = 15, Yield = 1 },
    TOMATOES = { Name = "Tomatoes", GrowthTime = 90, WitherTime = 45, Yield = 1 },
    PUMPKINS = { Name = "Pumpkins", GrowthTime = 300, WitherTime = 150, Yield = 1 },
    POTATOES = { Name = "Potatoes", GrowthTime = 900, WitherTime = 450, Yield = 2 },
    WHEAT = { Name = "Wheat", GrowthTime = 1200, WitherTime = 600, Yield = 4 },
    COTTON = { Name = "Cotton", GrowthTime = 1800, WitherTime = 900, Yield = 4 },
    FLAX = { Name = "Flax", GrowthTime = 720, WitherTime = 360, Yield = 2 },
    CORN = { Name = "Corn", GrowthTime = 1500, WitherTime = 750, Yield = 3 },
    PEAS = { Name = "Peas", GrowthTime = 1300, WitherTime = 650, Yield = 4 },
    PEANUTS = { Name = "Peanuts", GrowthTime = 1600, WitherTime = 800, Yield = 5 },
    SUNFLOWERS = { Name = "Sunflowers", GrowthTime = 1000, WitherTime = 500, Yield = 3 },
    EGGPLANT = { Name = "Eggplant", GrowthTime = 600, WitherTime = 300, Yield = 3 },
    TOMATO = {
        Name = "Tomato",
        Yield = 3,
        GrowthTime = 60, -- 1 minute
        WitherTime = 120, -- 2 minutes
        SeedName = "Tomato Seeds"
    },
    APPLE_TREE = { Name = "Apple Tree", GrowthTime = 60, WitherTime = 120, Yield = 2, OutputResource = "FOOD" },
}

function CropConfig.createSprout()
    local sprout = Instance.new("Part")
    sprout.Name = "Sprout"
    sprout.Size = Vector3.new(0.5, 1, 0.5)
    sprout.Color = Color3.new(0.4, 0.8, 0.2) -- A nice green color
    sprout.Anchored = true
    sprout.CanCollide = false
    return sprout
end

return CropConfig 