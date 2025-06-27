--[[
    QuestConfig.lua
    Defines all available quests, their objectives, and their rewards.
]]

local QuestConfig = {
    -- Levels 1-5 (The Settler)
    GATHER_WOOD = {
        Name = "A Good Start",
        Description = "Gather your first pieces of wood to start building.",
        Objectives = {
            GATHER_WOOD = 10 -- Gather 10 wood
        },
        Rewards = {
            XP = 20
        }
    },
    PLANT_FIRST_CROP = {
        Name = "Green Thumb",
        Description = "Plant your first crop to provide food.",
        Objectives = {
            PLANT_CROP = 1 -- Plant 1 crop of any kind
        },
        Rewards = {
            XP = 15,
            COINS = 5
        }
    },
    BUILD_TENT = {
        Name = "Shelter from the Elements",
        Description = "Build a simple tent to have a place to rest.",
        Objectives = {
            BUILD_TENT = 1 -- Build 1 tent
        },
        Rewards = {
            XP = 50,
            COINS = 10
        }
    },
    CRAFT_PLANK = {
        Name = "Tools of the Trade",
        Description = "Craft your first Wooden Plank at a crafting bench.",
        Objectives = {
            CRAFT_PLANK = 1
        },
        Rewards = {
            XP = 25,
            COINS = 5
        }
    },
    COOK_MEAL = {
        Name = "A Warm Meal",
        Description = "Cook a simple meal at your campfire.",
        Objectives = {
            COOK_MEAL = 1
        },
        Rewards = {
            XP = 25,
            COINS = 5
        }
    },
    HARVEST_CROPS = {
        Name = "Reaping Rewards",
        Description = "Harvest 3 fully–grown crops.",
        Objectives = {
            HARVEST_CROP = 3
        },
        Rewards = {
            XP = 30,
            COINS = 10
        }
    },
    SLEEP_IN_BED = {
        Name = "Rest Well",
        Description = "Sleep in your bed to restore energy.",
        Objectives = {
            SLEEP_IN_BED = 1
        },
        Rewards = {
            XP = 20,
            COINS = 5
        }
    },
    -- More quests for levels 6-10 (The Homesteader) can be added here

    -- Daily bulletin quests (repeatable via bulletin board)
    DAILY_WOOD_DELIVERY = {
        Name = "Town Supply: Wood",
        Description = "Gather and deliver 50 Wood to help the town.",
        Objectives = {
            GATHER_WOOD = 50
        },
        Rewards = {
            XP = 40,
            COINS = 30
        }
    },
    DAILY_STONE_DELIVERY = {
        Name = "Town Supply: Stone",
        Description = "Gather and deliver 30 Stone blocks.",
        Objectives = {
            GATHER_STONE = 30
        },
        Rewards = {
            XP = 40,
            COINS = 30
        }
    },
    DAILY_HOME_COOKING = {
        Name = "Feed the Folks",
        Description = "Cook 5 Meals for the townsfolk.",
        Objectives = {
            COOK_MEAL = 5
        },
        Rewards = {
            XP = 50,
            COINS = 40
        }
    }
}

return QuestConfig 