--[[
    RespawnSystem.lua
    Manages the respawning of resources in the world.
]]

local RespawnSystem = {}
local respawnQueue = {} -- Stores { resourceType, position, respawnTime }
local ResourceManager

local RESPAWN_DELAY = 60 -- Time in seconds before a resource respawns

function RespawnSystem.initialize(gameSystems)
    ResourceManager = gameSystems.ResourceManager
    print("RespawnSystem initialized.")
end

-- Called when a resource is destroyed and needs to be respawned later
function RespawnSystem.addToQueue(resourceModel)
    local resourceType = resourceModel:GetAttribute("ResourceType")
    local position = resourceModel:GetPrimaryPartCFrame().Position

    if not resourceType then
        warn("Attempted to queue resource for respawn, but it has no ResourceType attribute:", resourceModel.Name)
        return
    end

    local respawnEntry = {
        resourceType = resourceType,
        position = position,
        respawnTime = tick() + RESPAWN_DELAY
    }

    table.insert(respawnQueue, respawnEntry)
    print("Added", resourceType, "to respawn queue. Will respawn in", RESPAWN_DELAY, "seconds.")

    -- Destroy the original model from the world
    resourceModel:Destroy()
end

-- Called by the main server loop every second
function RespawnSystem.update()
    local currentTime = tick()
    local itemsToRespawn = {}

    -- Find all items ready to respawn
    for i, entry in ipairs(respawnQueue) do
        if currentTime >= entry.respawnTime then
            table.insert(itemsToRespawn, i)
        end
    end

    -- Respawn the items and remove them from the queue
    -- Iterate backwards to avoid issues with table indices changing
    for i = #itemsToRespawn, 1, -1 do
        local queueIndex = itemsToRespawn[i]
        local entry = table.remove(respawnQueue, queueIndex)
        
        -- Create the new resource node in the world
        ResourceManager.createResourceNode(entry.resourceType, entry.position)
    end
end

return RespawnSystem 