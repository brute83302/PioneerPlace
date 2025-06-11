--[[
    InteractionController.lua
    Handles player interaction with objects in the world, like clicking on resources.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractionController = {}

function InteractionController.setup()
    local player = Players.LocalPlayer
    if not player then return end

    local mouse = player:GetMouse()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local requestAssetEvent = remotesFolder:WaitForChild("RequestAssetCreation")

    mouse.Button1Up:Connect(function()
        local target = mouse.Target
        
        -- Check if we clicked on a valid part
        if not target then return end

        -- Check if the part is a harvestable resource node
        if target.Name == "ResourceNode" then
            print("Clicked on a ResourceNode. Firing remote to harvest:", target.Parent.Name)
            -- We send the entire model to the server
            requestAssetEvent:FireServer(target.Parent)
        end
    end)

    print("InteractionController setup. Ready to detect clicks on resources.")
end

return InteractionController 