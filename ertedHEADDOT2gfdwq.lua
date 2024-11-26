-- Ensure HeadDotSettings is globally accessible
getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.HeadDotSettings = getgenv().Pinguin.HeadDotSettings or {
    Enabled = false, -- Initially set to false; toggle button updates this
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.5,
    Thickness = 1,
    Filled = false,
    Sides = 50
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Data structure to store players and their associated head dots
local playerDots = {}

-- Function to create and initialize a head dot
local function CreateHeadDot(player)
    local headDot = Drawing.new("Circle")
    headDot.Visible = getgenv().Pinguin.HeadDotSettings.Enabled
    headDot.Color = getgenv().Pinguin.HeadDotSettings.Color
    headDot.Transparency = getgenv().Pinguin.HeadDotSettings.Transparency
    headDot.Thickness = getgenv().Pinguin.HeadDotSettings.Thickness
    headDot.Filled = getgenv().Pinguin.HeadDotSettings.Filled
    headDot.NumSides = getgenv().Pinguin.HeadDotSettings.Sides

    -- Attach the head dot to the player's data
    playerDots[player.UserId] = {
        player = player,
        headDot = headDot,
    }
end

-- Function to update a player's head dot
local function UpdateHeadDot(player)
    local data = playerDots[player.UserId]
    if not data or not data.player.Character then return end

    local head = data.player.Character:FindFirstChild("Head")
    if not head then return end

    local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
    data.headDot.Visible = onScreen and getgenv().Pinguin.HeadDotSettings.Enabled
    if data.headDot.Visible then
        data.headDot.Position = Vector2.new(headPosition.X, headPosition.Y)
        local top = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, head.Size.Y / 2, 0)).Position)
        local bottom = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, -head.Size.Y / 2, 0)).Position)
        data.headDot.Radius = math.abs((top.Y - bottom.Y) - 3)
    end
end

-- Function to remove a head dot when a player leaves
local function RemoveHeadDot(player)
    if playerDots[player.UserId] then
        playerDots[player.UserId].headDot:Remove()
        playerDots[player.UserId] = nil
    end
end

-- Function to toggle all head dots
local function ToggleHeadDots(state)
    getgenv().Pinguin.HeadDotSettings.Enabled = state
    for _, data in pairs(playerDots) do
        data.headDot.Visible = state
    end
end

-- Update all head dots each frame
RunService.RenderStepped:Connect(function()
    for _, data in pairs(playerDots) do
        UpdateHeadDot(data.player)
    end
end)

-- Initialize head dots for all current players
local function InitializeHeadDots()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateHeadDot(player)
        end
    end
end

-- Player connections
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateHeadDot(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveHeadDot)

-- Public API
return {
    Initialize = InitializeHeadDots,
    ToggleHeadDotESP = ToggleHeadDots,
    UpdateColor = function(color)
        getgenv().Pinguin.HeadDotSettings.Color = color
        for _, data in pairs(playerDots) do
            data.headDot.Color = color
        end
    end
}
