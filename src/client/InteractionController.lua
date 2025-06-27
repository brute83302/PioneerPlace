--[[
    InteractionController.lua
    Handles player interaction with objects in the world, like clicking on resources.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIManagerV2 = require(script.Parent.UIManagerV2)
local UserInputService = game:GetService("UserInputService")
local DeleteMode = require(script.Parent.DeleteMode)
local PlacementController = require(script.Parent.controllers.PlacementController)

local InteractionController = {}

function InteractionController.setup()
    local player = Players.LocalPlayer
    if not player then return end

    local mouse = player:GetMouse()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local requestActionEvent = remotesFolder:WaitForChild("RequestAction")

    mouse.Button1Up:Connect(function()
        -- If we're in placement mode, ignore clicks so we don't open UIs
        if PlacementController.isPlacing then return end

        local target = mouse.Target
        
        -- Check if we clicked on a valid part
        if not target or not target.Parent then return end

        -- First, check if the clicked part itself carries ObjectType
        if target:GetAttribute("ObjectType") then
            local objectType = target:GetAttribute("ObjectType")
            if objectType == "BULLETIN_BOARD" then
                UIManagerV2.showBulletinBoard()
                return
            end
        end

        -- Otherwise, check the parent model like before
        local model = target.Parent
        if model and model:IsA("Model") and model:GetAttribute("ObjectType") then
            local objectType = model:GetAttribute("ObjectType")

            -- Special client-side handling for opening the planting menu
            if DeleteMode.isActive() or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                remotesFolder.RequestDeleteObject:FireServer(model)
                return
            end

            if objectType == "FARM_PLOT" and model:GetAttribute("PlotState") == "EMPTY" then
                UIManagerV2.showPlantingMenu(model)
            elseif objectType == "CRAFTING_BENCH" then
                UIManagerV2.showCraftingMenu(model)
            elseif objectType == "MARKET_STALL" then
                UIManagerV2.showMarketMenu(model)
            elseif objectType == "CAMPFIRE" then
                UIManagerV2.showCookingMenu(model)
            elseif objectType == "CHICKEN_COOP" then
                UIManagerV2.showChickenMenu(model)
            elseif objectType == "TRAVELING_MERCHANT" or objectType == "SEED_STALL" then
                UIManagerV2.showMerchantMenu()
            elseif objectType == "BED" then
                remotesFolder.RequestSleep:FireServer(model)
            elseif objectType == "WOOD_SILO" or objectType == "STONE_SHED" or objectType == "FOOD_CELLAR" then
                -- Show a quick capacity popup
                local getDataFunc = remotesFolder:WaitForChild("GetPlayerData")
                local success, data = pcall(function()
                    return getDataFunc:InvokeServer()
                end)
                if success and data and data.Capacity then
                    local resType = (objectType=="WOOD_SILO") and "WOOD" or (objectType=="STONE_SHED" and "STONE" or "FOOD")
                    local current = data.Resources and data.Resources[resType] or 0
                    local capacity = data.Capacity[resType] or 0
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "CapacityPopupGui"
                    sg.ResetOnSpawn = false
                    sg.IgnoreGuiInset = true
                    sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0,220,0,40)
                    label.Position = UDim2.new(0.5,-110,0.18,0)
                    label.AnchorPoint = Vector2.new(0.5,0)
                    label.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    label.BackgroundTransparency = 0.35
                    label.TextColor3 = Color3.new(1,1,1)
                    label.Font = Enum.Font.GothamBold
                    label.TextScaled = true
                    label.Text = resType..": "..current.." / "..capacity
                    label.Parent = sg

                    game:GetService("Debris"):AddItem(sg,2)
                end
                return
            else
                -- For all other interactable objects, just notify the server
                requestActionEvent:FireServer(model)
            end
        end
    end)

    print("InteractionController setup complete.")
end

return InteractionController 