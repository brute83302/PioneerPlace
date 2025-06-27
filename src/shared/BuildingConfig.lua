local BuildingConfig = {
    WOOD_SILO = {
        Category = "STORAGE",
        BaseCost = { WOOD = 30, STONE = 10 },
        CapacityGain = { WOOD = 200 },
    },
    STONE_SHED = {
        Category = "STORAGE",
        BaseCost = { WOOD = 20, STONE = 25 },
        CapacityGain = { STONE = 200 },
    },
    FOOD_CELLAR = {
        Category = "STORAGE",
        BaseCost = { WOOD = 25, STONE = 15 },
        CapacityGain = { FOOD = 200 },
    },
}

function BuildingConfig.get(id)
    return BuildingConfig[id]
end

return BuildingConfig 