local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")
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
    if player == LocalPlayer then return end

    if player.Character then
        local existingHighlight = player.Character:FindFirstChild("PlayerHighlight")
        if existingHighlight then
            existingHighlight:Destroy()
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = lightenColor(getgenv().Pinguin.ChamsSettings.Color, 0.3)
    highlight.Parent = player.Character
end

local function onPlayerAdded(player)
    if player.Character then
        highlightPlayer(player)
    end
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            highlightPlayer(player)
        end
    end)
end)