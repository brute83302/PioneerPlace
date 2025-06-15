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
}

return MerchantItemConfig