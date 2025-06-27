--[[
    CollectionSystem.lua
    Grants rare collectible items to players during common actions (e.g., gathering resources).
    Tracks per-player collection progress and notifies the client when a new collectible is found.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionSystem = {}
local GameSystems -- set in initialize

-- Shared list of collectibles (Name, Rarity, Chance)
local COLLECTIBLES = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CollectionsConfig"))

-- Initialise the system and keep reference to GameSystems
function CollectionSystem.initialize(gameSystems)
    GameSystems = gameSystems

    local count = 0
    for _ in pairs(COLLECTIBLES) do
        count += 1
    end
    print("CollectionSystem initialised. Collectibles:", count)
end

-- Attempt to grant a collectible to the player based on configured chances.
-- Call this from other systems after a relevant action (e.g., harvesting).
function CollectionSystem.tryGrantCollectible(player)
    if not GameSystems then return end
    local playerData = GameSystems.PlayerService.getPlayerData(player)
    if not playerData then return end

    -- Guard if Collections table is missing for some reason
    playerData.Collections = playerData.Collections or {}

    -- Roll once per call – iterate until we either succeed or exhaust the list
    for id, cfg in pairs(COLLECTIBLES) do
        if not playerData.Collections[id] then -- only attempt undiscovered items
            if math.random() <= (cfg.Chance or 0) then
                -- Award collectible
                playerData.Collections[id] = true

                -- Notify client
                local event = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CollectionFound")
                event:FireClient(player, id, cfg.Name)

                print(string.format("[Collections] %s discovered %s", player.Name, cfg.Name))
                return -- only one collectible per trigger
            end
        end
    end
end

return CollectionSystem 