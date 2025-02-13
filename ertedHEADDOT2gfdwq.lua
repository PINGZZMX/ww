-- Visuals (HEADDOT) (ertedHEADDOT2gfdwq.lua) (PinguinDEV)
getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.HeadDotSettings = getgenv().Pinguin.HeadDotSettings or {
    Enabled = false,
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

local playerDots = {}

local function CreateHeadDot(player)
    local headDot = Drawing.new("Circle")
    headDot.Visible = getgenv().Pinguin.HeadDotSettings.Enabled
    headDot.Color = getgenv().Pinguin.HeadDotSettings.Color
    headDot.Transparency = getgenv().Pinguin.HeadDotSettings.Transparency
    headDot.Thickness = getgenv().Pinguin.HeadDotSettings.Thickness
    headDot.Filled = getgenv().Pinguin.HeadDotSettings.Filled
    headDot.NumSides = getgenv().Pinguin.HeadDotSettings.Sides

    playerDots[player.UserId] = {
        player = player,
        headDot = headDot,
    }
end

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

local function RemoveHeadDot(player)
    if playerDots[player.UserId] then
        playerDots[player.UserId].headDot:Remove()
        playerDots[player.UserId] = nil
    end
end

local function ToggleHeadDots(state)
    getgenv().Pinguin.HeadDotSettings.Enabled = state
    for _, data in pairs(playerDots) do
        data.headDot.Visible = state
    end
end

RunService.RenderStepped:Connect(function()
    for _, data in pairs(playerDots) do
        UpdateHeadDot(data.player)
    end
end)

local function InitializeHeadDots()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateHeadDot(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateHeadDot(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveHeadDot)

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
