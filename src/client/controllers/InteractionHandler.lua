--[[
    InteractionHandler.lua
    Detects player clicks on interactable objects in the world.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIManager = require(script.Parent.Parent.UIManagerV2)

local InteractionHandler = {}

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local requestActionEvent = remotesFolder:WaitForChild("RequestAction")

function InteractionHandler.initialize()
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()

    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if not target or not target.Parent then return end

        local model = target.Parent
        local objectType = model:GetAttribute("ObjectType")

        if objectType == "RESOURCE_NODE" then
            print("Clicked on a ResourceNode. Firing remote to harvest:", model.Name)
            requestActionEvent:FireServer(model)
        elseif objectType == "FARM_PLOT" then
            local state = model:GetAttribute("PlotState")
            if state == "EMPTY" then
                -- Show the planting menu
                UIManager.showPlantingMenu(model)
            elseif state == "GROWN" then
                -- Harvest the crop
                print("Clicked on a grown FarmPlot. Firing remote action:", model.Name)
                requestActionEvent:FireServer(model)
            end
        end
    end)

    print("InteractionHandler setup. Ready to detect clicks.")
end

return InteractionHandler 