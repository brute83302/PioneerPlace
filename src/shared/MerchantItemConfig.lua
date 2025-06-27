--[[
    MerchantItemConfig.lua
    Defines all possible items that the Traveling Merchant can sell.
    Each entry follows the format:
        KEY = {
            Name = "Display Name",
            Category = "DECORATIVE | UTILITY | SEED | ANIMAL | ANIMAL_COSMETIC | CONSUMABLE | MYSTERY | EVENT_CONSUMABLE",
            Rarity = "COMMON | UNCOMMON | RARE | EPIC | LEGENDARY | SEASONAL_*",
            Currency = "COINS | GOLD",
            Price = number, -- cost in the specified currency
            Season = "WINTER | SPRING | SUMMER | AUTUMN | HALLOWEEN | VALENTINE | NEW_YEAR | ST_PADDY" -- optional
        }
    This structure mirrors CropConfig.lua so both client and server can easily access the data with a simple require.
]]

local MerchantItemConfig = {
    -- Decorative Items
    SUNFLOWER_ARCHWAY = { Name = "Sunflower Archway", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 2500 },
    RUSTIC_WINDMILL_MODEL = { Name = "Rustic Windmill Model", Category = "DECORATIVE", Rarity = "EPIC", Currency = "COINS", Price = 3800 },
    CRYSTAL_CHANDELIER = { Name = "Crystal Chandelier", Category = "DECORATIVE", Rarity = "LEGENDARY", Currency = "GOLD", Price = 15 },
    HANGING_LANTERN_STRINGS = { Name = "Hanging Lantern Strings", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 1200 },
    KOI_GARDEN_POND = { Name = "Koi Garden Pond", Category = "DECORATIVE", Rarity = "EPIC", Currency = "GOLD", Price = 10 },
    WAGON_WHEEL_BENCH = { Name = "Wagon-Wheel Bench", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 950 },
    POLISHED_MARBLE_FOUNTAIN = { Name = "Polished Marble Fountain", Category = "DECORATIVE", Rarity = "LEGENDARY", Currency = "GOLD", Price = 18 },
    FESTIVAL_BANNER_PACK = { Name = "Festival Banner Pack", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 1000 },

    -- Functional Upgrades / Utility
    SUPERIOR_IRON_AXE = { Name = "Superior Iron Axe", Category = "UTILITY", Rarity = "RARE", Currency = "COINS", Price = 4000 },
    REINFORCED_BACKPACK = { Name = "Reinforced Backpack", Category = "UTILITY", Rarity = "EPIC", Currency = "GOLD", Price = 12 },
    PRECISION_WATERING_CAN = { Name = "Precision Watering Can", Category = "UTILITY", Rarity = "UNCOMMON", Currency = "COINS", Price = 1800 },
    POCKET_FURNACE = { Name = "Pocket Furnace", Category = "UTILITY", Rarity = "EPIC", Currency = "GOLD", Price = 14 },
    DELUXE_CHICKEN_FEEDER = { Name = "Deluxe Chicken Feeder", Category = "UTILITY", Rarity = "RARE", Currency = "COINS", Price = 2700 },
    MINI_COLD_FRAME_GREENHOUSE = { Name = "Mini Cold-Frame Greenhouse", Category = "UTILITY", Rarity = "EPIC", Currency = "GOLD", Price = 11 },
    SOLAR_LANTERN_POST = { Name = "Solar Lantern Post", Category = "UTILITY", Rarity = "RARE", Currency = "COINS", Price = 2200 },

    -- Exotic Seeds & Saplings
    DRAGONFRUIT_SAPLING = { Name = "Dragonfruit Sapling", Category = "SEED", Rarity = "EPIC", Currency = "COINS", Price = 3200 },
    GLOWSHROOM_SPORE_KIT = { Name = "Glowshroom Spore Kit", Category = "SEED", Rarity = "RARE", Currency = "GOLD", Price = 8 },
    CANDY_CORN_SEEDS = { Name = "Candy Corn Seeds", Category = "SEED", Rarity = "SEASONAL_EPIC", Currency = "COINS", Price = 2900, Season = "HALLOWEEN" },
    SAKURA_BONSAI_SAPLING = { Name = "Sakura Bonsai Sapling", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 2600 },
    BLUE_BAMBOO_RHIZOME = { Name = "Blue Bamboo Rhizome", Category = "SEED", Rarity = "EPIC", Currency = "GOLD", Price = 9 },
    FIRE_PEPPER_SEEDS = { Name = "Fire Pepper Seeds", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 1400 },

    -- Animals & Cosmetics
    MINI_GOAT_KID = { Name = "Mini-Goat Kid", Category = "ANIMAL", Rarity = "EPIC", Currency = "GOLD", Price = 13 },
    EMERALD_SADDLE_PAD = { Name = "Emerald Saddle Pad", Category = "ANIMAL_COSMETIC", Rarity = "RARE", Currency = "COINS", Price = 2050 },
    STAR_SPECKLED_CHICKEN_SKIN = { Name = "Star-Speckled Chicken Skin", Category = "ANIMAL_COSMETIC", Rarity = "EPIC", Currency = "GOLD", Price = 6 },
    TRUFFLE_SNIFFING_PIGLET = { Name = "Truffle-Sniffing Piglet", Category = "ANIMAL", Rarity = "LEGENDARY", Currency = "GOLD", Price = 20 },

    -- Mystery & Collection
    ANTIQUE_TREASURE_MAP = { Name = "Antique Treasure Map", Category = "MYSTERY", Rarity = "RARE", Currency = "COINS", Price = 3500 },
    LOCKED_PIONEER_CHEST = { Name = "Locked Pioneer Chest", Category = "MYSTERY", Rarity = "EPIC", Currency = "GOLD", Price = 7 },
    METEOR_SHARD = { Name = "Meteor Shard", Category = "MYSTERY", Rarity = "LEGENDARY", Currency = "GOLD", Price = 25 },
    MUSIC_BOX_FRONTIER_WALTZ = { Name = "Music Box – Frontier Waltz", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 2300 },
    FIREWORK_BUNDLE = { Name = "Firework Bundle", Category = "EVENT_CONSUMABLE", Rarity = "SEASONAL_UNCOMMON", Currency = "COINS", Price = 1150, Season = "NEW_YEAR" },

    -- Utility & Consumables
    ENERGY_TONIC_PACK = { Name = "5-Pack Energy Tonic", Category = "CONSUMABLE", Rarity = "COMMON", Currency = "COINS", Price = 900 },
    BUILDERS_BLUEPRINT_TOKEN = { Name = "Builder's Blueprint Token", Category = "UTILITY", Rarity = "RARE", Currency = "GOLD", Price = 5 },
    RESOURCE_CRATE_HARDWOOD = { Name = "Resource Crate: Hardwood", Category = "UTILITY", Rarity = "UNCOMMON", Currency = "COINS", Price = 1800 },
    DYE_KIT_PASTEL = { Name = "Dye Kit – Pastel Collection", Category = "UTILITY", Rarity = "RARE", Currency = "COINS", Price = 2300 },
    WEATHER_CHARM_CLEAR_SKIES = { Name = "Weather Charm – Clear Skies", Category = "UTILITY", Rarity = "EPIC", Currency = "GOLD", Price = 8 },

    -- Seasonal Event Items
    SNOWY_EVERGREEN_TREE = { Name = "Snowy Evergreen Tree", Category = "DECORATIVE", Rarity = "SEASONAL_RARE", Currency = "COINS", Price = 2400, Season = "WINTER" },
    HEART_SHAPED_ROSE_TRELLIS = { Name = "Heart-Shaped Rose Trellis", Category = "DECORATIVE", Rarity = "SEASONAL_EPIC", Currency = "GOLD", Price = 10, Season = "VALENTINE" },
    SPOOKY_SCARECROW_SKIN = { Name = "Spooky Scarecrow Skin", Category = "DECORATIVE", Rarity = "SEASONAL_UNCOMMON", Currency = "COINS", Price = 1250, Season = "AUTUMN" },
    LUCKY_CLOVER_PATCH = { Name = "Lucky Clover Patch", Category = "DECORATIVE", Rarity = "SEASONAL_RARE", Currency = "COINS", Price = 1950, Season = "ST_PADDY" },
    CHERRY_BLOSSOM_LANTERNS = { Name = "Cherry-Blossom Lanterns", Category = "DECORATIVE", Rarity = "SEASONAL_EPIC", Currency = "GOLD", Price = 9, Season = "SPRING" },

    -- New Seed Catalogue (common to mythical)
    -- COMMON Seeds
    PRAIRIE_WHEAT_SEEDS = { Name = "Prairie Wheat Seeds", Category = "SEED", Rarity = "COMMON", Currency = "COINS", Price = 0 },
    CRISP_CARROT_SEEDS = { Name = "Crisp Carrot Seeds", Category = "SEED", Rarity = "COMMON", Currency = "COINS", Price = 0 },
    HOMESTEAD_LETTUCE_SEEDS = { Name = "Homestead Lettuce Seeds", Category = "SEED", Rarity = "COMMON", Currency = "COINS", Price = 0 },
    MEADOW_PEA_SEEDS = { Name = "Meadow Pea Seeds", Category = "SEED", Rarity = "COMMON", Currency = "COINS", Price = 0 },
    SUNRISE_TOMATO_SEEDS = { Name = "Sunrise Tomato Seeds", Category = "SEED", Rarity = "COMMON", Currency = "COINS", Price = 0 },

    -- UNCOMMON Seeds
    HONEY_GOLD_CORN_KERNELS = { Name = "Honey-Gold Corn Kernels", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 0 },
    RED_MAPLE_PUMPKIN_SEEDS = { Name = "Red-Maple Pumpkin Seeds", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 0 },
    SWEET_BERRY_BUSH_STARTS = { Name = "Sweet Berry Bush Starts", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 0 },
    CLOUD_CABBAGE_SPROUTS = { Name = "Cloud-Cabbage Sprouts", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 0 },
    RUSTIC_YAM_SLIPS = { Name = "Rustic Yam Slips", Category = "SEED", Rarity = "UNCOMMON", Currency = "COINS", Price = 0 },

    -- RARE Seeds
    LAVENDER_SUGAR_BEET_SEEDS = { Name = "Lavender Sugar Beet Seeds", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 0 },
    SAPPHIRE_HOPS_CONES = { Name = "Sapphire Hops Cones", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 0 },
    EMBER_CHILI_PEPPER_SEEDS = { Name = "Ember Chili Pepper Seeds", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 0 },
    SILVERMOON_ONION_BULBS = { Name = "Silvermoon Onion Bulbs", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 0 },
    GLACIER_CUCUMBER_SEEDS = { Name = "Glacier Cucumber Seeds", Category = "SEED", Rarity = "RARE", Currency = "COINS", Price = 0 },

    -- LEGENDARY Seeds
    ROYAL_ROSE_ARTICHOKE_SEEDS = { Name = "Royal Rose Artichoke Seeds", Category = "SEED", Rarity = "LEGENDARY", Currency = "COINS", Price = 0 },
    DRAGONFIRE_RADISH_SEEDS = { Name = "Dragonfire Radish Seeds", Category = "SEED", Rarity = "LEGENDARY", Currency = "COINS", Price = 0 },
    MIDNIGHT_INDIGO_EGGPLANT_SEEDS = { Name = "Midnight Indigo Eggplant Seeds", Category = "SEED", Rarity = "LEGENDARY", Currency = "COINS", Price = 0 },
    GOLDEN_SUNBURST_MELON_SEEDS = { Name = "Golden Sunburst Melon Seeds", Category = "SEED", Rarity = "LEGENDARY", Currency = "COINS", Price = 0 },
    STARDROP_POPPY_GRAIN = { Name = "Stardrop Poppy Grain", Category = "SEED", Rarity = "LEGENDARY", Currency = "COINS", Price = 0 },

    -- MYTHICAL Seeds
    PHOENIX_FEATHER_PEPPER_SEEDS = { Name = "Phoenix Feather Pepper Seeds", Category = "SEED", Rarity = "MYTHICAL", Currency = "COINS", Price = 0 },
    AURORA_LOTUS_PADLINGS = { Name = "Aurora Lotus Padlings", Category = "SEED", Rarity = "MYTHICAL", Currency = "COINS", Price = 0 },
    CRYSTAL_DEWBERRY_SEEDS = { Name = "Crystal Dewberry Seeds", Category = "SEED", Rarity = "MYTHICAL", Currency = "COINS", Price = 0 },
    WHISPERING_WILLOW_SAPLINGS = { Name = "Whispering Willow Saplings", Category = "SEED", Rarity = "MYTHICAL", Currency = "COINS", Price = 0 },
    CELESTIAL_COMET_CORN_KERNELS = { Name = "Celestial Comet Corn Kernels", Category = "SEED", Rarity = "MYTHICAL", Currency = "COINS", Price = 0 },

    -- New Traveling Merchant exclusives
    REFURBISHED_GRIST_MILL = { Name = "Refurbished Grist Mill", Category = "DECORATIVE", Rarity = "LEGENDARY", Currency = "GOLD", Price = 18 },
    ROSEWOOD_PICNIC_SET = { Name = "Rosewood Picnic Set", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 2200 },
    CLOCKWORK_TOOLBOX = { Name = "Clockwork Toolbox", Category = "UTILITY", Rarity = "EPIC", Currency = "COINS", Price = 4200 },
    MINI_BONSAI_DISPLAY = { Name = "Mini Bonsai Display", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 1200 },
    WANDERING_MINSTREL_MUSIC_BOX = { Name = "Wandering Minstrel Music Box", Category = "MYSTERY", Rarity = "LEGENDARY", Currency = "COINS", Price = 4000 },

    -- Traveling Merchant: Homestead Decorations
    WOODEN_FLOWER_BOX = { Name = "Wooden Flower Box", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 350 },
    STONE_BIRD_BATH = { Name = "Stone Bird-Bath", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 800 },
    IRON_GARDEN_LANTERN = { Name = "Iron Garden Lantern", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 650 },
    SMALL_HEDGE_BUSH = { Name = "Small Hedge Bush", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 400 },
    RUSTIC_WHEELBARROW_PLANTER = { Name = "Rustic Wheelbarrow Planter", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 900 },
    OAK_PICNIC_TABLE = { Name = "Oak Picnic Table", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 1000 },
    MAPLE_SAPLING_POT = { Name = "Maple Sapling Pot", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1200 },
    CLOTHESLINE_DECOR = { Name = "Clothesline Décor", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 300 },
    RIVER_STONE_PATH_SET = { Name = "River-Stone Path Set", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 850 },
    PAINTED_BEEHIVE_DECOR = { Name = "Painted Beehive Décor", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 750 },
    MOONLIT_WATER_FEATURE = { Name = "Moonlit Water Feature", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1500 },
    STARLIGHT_FAIRY_LIGHTS = { Name = "Starlight Fairy Lights", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1400 },
    CARVED_PUMPKIN_STACK = { Name = "Carved Pumpkin Stack", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 550 },
    RED_CHECKERED_HAMMOCK = { Name = "Red-Checkered Hammock", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1300 },
    GARDEN_GNOME_CLASSIC = { Name = "Garden Gnome – Classic", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 450 },
    BRASS_WEATHER_VANE = { Name = "Brass Weather Vane", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1600 },
    LOG_WOODEN_BENCH = { Name = "Log Wooden Bench", Category = "DECORATIVE", Rarity = "COMMON", Currency = "COINS", Price = 500 },
    SUNFLOWER_SPINNING_PINWHEEL = { Name = "Sunflower Spinning Pinwheel", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 800 },
    OXEN_CART_PLANTER = { Name = "Oxen-Cart Planter", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1700 },
    MINI_SCARECROW_DECOR = { Name = "Mini Scarecrow Décor", Category = "DECORATIVE", Rarity = "RARE", Currency = "COINS", Price = 1350 },
    BAMBOO_FENCE_SEGMENT = { Name = "Bamboo Fence Segment", Category = "DECORATIVE", Rarity = "UNCOMMON", Currency = "COINS", Price = 700 },
    STONE_WISHING_WELL = { Name = "Stone Wishing Well", Category = "DECORATIVE", Rarity = "EPIC", Currency = "COINS", Price = 2600 },
    COBBLESTONE_GARDEN_STATUE = { Name = "Cobblestone Garden Statue", Category = "DECORATIVE", Rarity = "EPIC", Currency = "COINS", Price = 2400 },
    VINE_ARCHWAY = { Name = "Vine-Covered Archway", Category = "DECORATIVE", Rarity = "EPIC", Currency = "COINS", Price = 2500 },
    GLASS_GREENHOUSE_TERRARIUM = { Name = "Glass Greenhouse Terrarium", Category = "DECORATIVE", Rarity = "LEGENDARY", Currency = "COINS", Price = 4500 },
}

return MerchantItemConfig