--[[
    WorldService.lua
    Manages the overall state of the game world.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Lazily loaded to avoid circular dependencies
local GameSystems

local WorldService = {}

-- Day / Night cycle configuration (seconds per full in-game day)
local DAY_LENGTH = 60 * 10 -- 10 minutes

-- In-game hour (0-24) that the world should start at when the server boots
local START_CLOCK_TIME = 8 -- 8 = early morning daylight

-- New configuration for non-linear day/night cycle to make day longer
local DAY_NIGHT_CONFIG = {
    DAWN_START = 5,
    DAY_START = 7,
    DUSK_START = 19,
    NIGHT_START = 21,
}

-- The percentage of real time each phase should take. Must sum to 1.0.
local DAY_NIGHT_DURATION_RATIOS = {
    DAWN = 0.05,  -- 5% (30 seconds)
    DAY = 0.65,   -- 65% (6.5 minutes)
    DUSK = 0.05,  -- 5% (30 seconds)
    NIGHT = 0.25, -- 25% (2.5 minutes)
}

-- Weather configuration
local WEATHER_INTERVAL = 60 * 5 -- 5 minutes between potential weather changes
local AVAILABLE_WEATHER = {"CLEAR", "RAIN"}

local currentWeather = "CLEAR"
local lastWeatherChange = 0
local dayStartTimestamp

-- Helper function to calculate the initial cycle offset to start at START_CLOCK_TIME
local function getInitialCycleSeconds(startClockTime)
    -- This is the inverse of the logic in update().
    -- For simplicity, this implementation assumes the start time is during the DAY phase.
    if startClockTime >= DAY_NIGHT_CONFIG.DAY_START and startClockTime < DAY_NIGHT_CONFIG.DUSK_START then
        local phaseProgress = (startClockTime - DAY_NIGHT_CONFIG.DAY_START) / (DAY_NIGHT_CONFIG.DUSK_START - DAY_NIGHT_CONFIG.DAY_START)
        local dawn_end_progress = DAY_NIGHT_DURATION_RATIOS.DAWN
        local cycleProgress = dawn_end_progress + (phaseProgress * DAY_NIGHT_DURATION_RATIOS.DAY)
        return cycleProgress * DAY_LENGTH
    end
    -- Default to starting at the beginning of dawn if the time isn't in the main day period
    return 0
end

-- Shift the dayStartTimestamp so that initial ClockTime equals START_CLOCK_TIME
dayStartTimestamp = tick() - getInitialCycleSeconds(START_CLOCK_TIME)

-- Ensure initial lighting matches immediately before first update tick
Lighting.ClockTime = START_CLOCK_TIME

-- Forward declaration so we can call inside initialize
local applyWeather

function WorldService.initialize(gameSystems)
    GameSystems = gameSystems

    -- Spawn Town Square once
    local Workspace = game:GetService("Workspace")
    if not Workspace:FindFirstChild("TownSquare") then
        local square = Instance.new("Model")
        square.Name = "TownSquare"

        -- Stone tiled base
        local base = Instance.new("Part")
        base.Name = "Base"
        base.Size = Vector3.new(60,1,60)
        base.Anchored = true
        base.Position = Vector3.new(0,0,0)
        base.Material = Enum.Material.Slate
        base.Color = Color3.fromRGB(110,110,110)
        base.TopSurface = Enum.SurfaceType.Smooth
        base.Parent = square
        square.PrimaryPart = base

        -- Central fountain (simple cylinder + water)
        local fountainBase = Instance.new("Part")
        fountainBase.Shape = Enum.PartType.Cylinder
        fountainBase.Size = Vector3.new(8,2,8)
        fountainBase.Anchored = true
        fountainBase.Position = base.Position + Vector3.new(0,1,0)
        fountainBase.Color = Color3.fromRGB(100,100,100)
        fountainBase.Parent = square

        local water = Instance.new("Part")
        water.Shape = Enum.PartType.Cylinder
        water.Size = Vector3.new(6,0.4,6)
        water.Anchored = true
        water.Position = fountainBase.Position + Vector3.new(0,1.2,0)
        water.Material = Enum.Material.Glass
        water.Color = Color3.fromRGB(0, 170, 255)
        water.Transparency = 0.4
        water.Parent = square

        -- Gentle water splash using particle emitter
        local splash = Instance.new("ParticleEmitter")
        splash.Texture = "rbxasset://textures/particles/splash_main.dds"
        splash.Lifetime = NumberRange.new(1)
        splash.Rate = 20
        splash.Speed = NumberRange.new(2,4)
        splash.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
        splash.Transparency = NumberSequence.new(0.4)
        splash.Parent = water

        -- Four lamp posts at corners
        local function createLamp(offsetX, offsetZ)
            local pole = Instance.new("Part")
            pole.Size = Vector3.new(0.5,7,0.5)
            pole.Anchored = true
            pole.Position = base.Position + Vector3.new(offsetX,3.5, offsetZ)
            pole.Material = Enum.Material.Wood
            pole.Color = Color3.fromRGB(80,60,40)
            pole.Parent = square

            local lightPart = Instance.new("Part")
            lightPart.Shape = Enum.PartType.Ball
            lightPart.Size = Vector3.new(1.5,1.5,1.5)
            lightPart.Anchored = true
            lightPart.Position = pole.Position + Vector3.new(0,3.5,0)
            lightPart.Material = Enum.Material.Neon
            lightPart.Color = Color3.fromRGB(255, 249, 196)
            lightPart.Parent = square

            local pointLight = Instance.new("PointLight")
            pointLight.Range = 15
            pointLight.Brightness = 1
            pointLight.Color = lightPart.Color
            pointLight.Parent = lightPart
        end

        local corner = 28
        createLamp(-corner, -corner)
        createLamp(corner, -corner)
        createLamp(-corner, corner)
        createLamp(corner, corner)

        -- Simple benches on two sides
        local function createBench(x, z)
            local seat = Instance.new("Part")
            seat.Size = Vector3.new(8,0.5,2)
            seat.Anchored = true
            seat.Position = base.Position + Vector3.new(x,1, z)
            seat.Color = Color3.fromRGB(120,80,50)
            seat.Material = Enum.Material.Wood
            seat.Parent = square
        end
        createBench(0, -24)
        createBench(0, 24)

        -- Community bulletin board for future quest postings
        local board = Instance.new("Part")
        board.Size = Vector3.new(6,4,0.5)
        board.Anchored = true
        board.Position = base.Position + Vector3.new(-24,2,0)
        board.Material = Enum.Material.WoodPlanks
        board.Color = Color3.fromRGB(150, 100, 60)
        board:SetAttribute("ObjectType","BULLETIN_BOARD")
        board.Parent = square

        local boardLabel = Instance.new("SurfaceGui")
        boardLabel.Face = Enum.NormalId.Front
        boardLabel.CanvasSize = Vector2.new(400,200)
        boardLabel.Parent = board
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.Text = "Community Board\nComing Soon!"
        text.TextScaled = true
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1,1,1)
        text.Font = Enum.Font.GothamBold
        text.Parent = boardLabel

        square.Parent = Workspace
    end

    dayStartTimestamp = tick()
    lastWeatherChange = tick()
    applyWeather("CLEAR")
end

function WorldService.loadPlayerBuildings(player, buildings)
    if not buildings or #buildings == 0 then
        print("No buildings to load for player:", player.Name)
        return
    end

    print("Loading", #buildings, "buildings for player:", player.Name)
    for _, buildingData in ipairs(buildings) do
        GameSystems.BuildingSystem.loadBuilding(player, buildingData)
    end
end

-- Apply visual/server side settings for a given weather type
function applyWeather(weatherType)
    currentWeather = weatherType

    -- Ensure Atmosphere exists
    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end

    if weatherType == "CLEAR" then
        atmosphere.Density = 0.25
        atmosphere.Offset = 0
        Lighting.Brightness = 2
    elseif weatherType == "RAIN" then
        atmosphere.Density = 0.4
        atmosphere.Offset = -0.5
        Lighting.Brightness = 1.5
    end

    -- Notify clients so they can react (e.g., UI pop-ups)
    local weatherEvent = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("WeatherChanged")
    if weatherEvent then
        weatherEvent:FireAllClients(weatherType)
    end
end

-- Called every server tick from main loop
function WorldService.update(currentTime)
    -- Handle day/night clock progression using a non-linear cycle
    local secondsIntoCycle = (currentTime - dayStartTimestamp) % DAY_LENGTH
    local cycleProgress = secondsIntoCycle / DAY_LENGTH -- Value from 0 to 1

    local clockTime

    local dawn_end_progress = DAY_NIGHT_DURATION_RATIOS.DAWN
    local day_end_progress = dawn_end_progress + DAY_NIGHT_DURATION_RATIOS.DAY
    local dusk_end_progress = day_end_progress + DAY_NIGHT_DURATION_RATIOS.DUSK

    if cycleProgress < dawn_end_progress then
        -- Dawn phase
        local phaseProgress = cycleProgress / DAY_NIGHT_DURATION_RATIOS.DAWN
        clockTime = DAY_NIGHT_CONFIG.DAWN_START + phaseProgress * (DAY_NIGHT_CONFIG.DAY_START - DAY_NIGHT_CONFIG.DAWN_START)
    elseif cycleProgress < day_end_progress then
        -- Day phase
        local phaseProgress = (cycleProgress - dawn_end_progress) / DAY_NIGHT_DURATION_RATIOS.DAY
        clockTime = DAY_NIGHT_CONFIG.DAY_START + phaseProgress * (DAY_NIGHT_CONFIG.DUSK_START - DAY_NIGHT_CONFIG.DAY_START)
    elseif cycleProgress < dusk_end_progress then
        -- Dusk phase
        local phaseProgress = (cycleProgress - day_end_progress) / DAY_NIGHT_DURATION_RATIOS.DUSK
        clockTime = DAY_NIGHT_CONFIG.DUSK_START + phaseProgress * (DAY_NIGHT_CONFIG.NIGHT_START - DAY_NIGHT_CONFIG.DUSK_START)
    else
        -- Night phase (wraps around from 24 to 0)
        local phaseProgress = (cycleProgress - dusk_end_progress) / DAY_NIGHT_DURATION_RATIOS.NIGHT
        local nightHourDuration = (24 - DAY_NIGHT_CONFIG.NIGHT_START) + DAY_NIGHT_CONFIG.DAWN_START
        clockTime = (DAY_NIGHT_CONFIG.NIGHT_START + phaseProgress * nightHourDuration) % 24
    end

    Lighting.ClockTime = clockTime

    -- Handle weather changes
    if (currentTime - lastWeatherChange) >= WEATHER_INTERVAL then
        -- Pick a new weather different from current
        local newWeather = currentWeather
        while newWeather == currentWeather do
            newWeather = AVAILABLE_WEATHER[math.random(1, #AVAILABLE_WEATHER)]
        end
        applyWeather(newWeather)
        lastWeatherChange = currentTime
    end
end

function WorldService.getCurrentWeather()
    return currentWeather
end

return WorldService 