-- Visuals (HIGHLIGHT) (ertedHIGHTLIGHTgfdwqOHIO.lua) (PinguinDEV)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.ChamsSettings = getgenv().Pinguin.ChamsSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)
}

local function lightenColor(color, factor)
    return Color3.new(
        math.min(color.R + factor, 1),
        math.min(color.G + factor, 1),
        math.min(color.B + factor, 1)
    )
end

local function highlightPlayer(player)
    if not player.Character then return end
    local highlight = player.Character:FindFirstChild("PlayerHighlight") or Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = lightenColor(getgenv().Pinguin.ChamsSettings.Color, 0.3)
    highlight.Parent = player.Character
end

local function refreshChams()
    if not getgenv().Pinguin.ChamsSettings.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            highlightPlayer(player)
        end
    end
end

local function ToggleChams(state)
    getgenv().Pinguin.ChamsSettings.Enabled = state
    if state then
        refreshChams()
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("PlayerHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if getgenv().Pinguin.ChamsSettings.Enabled then
            highlightPlayer(player)
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    refreshChams()
end)

return ToggleChams
