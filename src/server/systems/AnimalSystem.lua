--[[
    AnimalSystem.lua
    Simple livestock management: Chicken Coop produces eggs (counts as FOOD) after being fed.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimalSystem = {}
local GameSystems

-- Constants
local FEED_COST = { FOOD = 2 }  -- Feed cost per coop
local EGG_YIELD = 3              -- Amount of FOOD resource granted when eggs collected
local GROW_TIME = 300            -- Seconds from feeding to eggs ready

-- Track all coops in world
local activeCoops = {}

function AnimalSystem.initialize(gs)
    GameSystems = gs
    -- Scan existing coops
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m:GetAttribute("ObjectType") == "CHICKEN_COOP" then
            table.insert(activeCoops,m)
        end
    end
    print("AnimalSystem initialized. Coops:", #activeCoops)
end

function AnimalSystem.registerCoop(model)
    if model and model:IsA("Model") and model:GetAttribute("ObjectType") == "CHICKEN_COOP" then
        table.insert(activeCoops, model)
    end
end

function AnimalSystem.feed(player, coop)
    if not coop or coop:GetAttribute("ObjectType") ~= "CHICKEN_COOP" then return end
    if (coop:GetAttribute("OwnerId") or player.UserId) ~= player.UserId then
        warn("Player attempted to feed coop they don't own")
        return
    end
    local ok = GameSystems.ResourceManager.removeResources(player, FEED_COST)
    if not ok then return end
    coop:SetAttribute("LastFed", tick())
    coop:SetAttribute("Eggs", 0)
    print(player.Name, "fed chickens.")
end

function AnimalSystem.collect(player, coop)
    if not coop or coop:GetAttribute("ObjectType") ~= "CHICKEN_COOP" then return end
    local eggs = coop:GetAttribute("Eggs") or 0
    if eggs <= 0 then return end
    coop:SetAttribute("Eggs", 0)
    -- Grant FOOD resource as eggs
    GameSystems.ResourceManager.addResource(player, "FOOD", eggs * EGG_YIELD)
end

-- Run each second to update egg readiness
function AnimalSystem.update()
    local now = tick()
    for _,coop in ipairs(activeCoops) do
        if coop.Parent then
            local lastFed = coop:GetAttribute("LastFed") or 0
            if lastFed > 0 and now - lastFed >= GROW_TIME then
                coop:SetAttribute("Eggs",1)
                coop:SetAttribute("LastFed", 0) -- reset until next feed
            end
        end
    end
end

return AnimalSystem 