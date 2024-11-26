-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.ChamsSettings = getgenv().Pinguin.ChamsSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)
}

-- Function to lighten a color
local function lightenColor(color, factor)
    return Color3.new(
        math.min(color.R + factor, 1), -- Color3 values are from 0 to 1
        math.min(color.G + factor, 1),
        math.min(color.B + factor, 1)
    )
end

-- Function to highlight players
local function highlightPlayer(player)
    if player == LocalPlayer then return end  -- Skip Chams for the local player

    -- Remove existing highlight
    if player.Character then
        local existingHighlight = player.Character:FindFirstChild("PlayerHighlight")
        if existingHighlight then
            existingHighlight:Destroy()
        end
    end

    -- Create new highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"

    -- Set the highlight color to the selected color
    highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
    highlight.FillTransparency = 1

    -- Set the outline color to a lighter version of the color
    highlight.OutlineColor = lightenColor(getgenv().Pinguin.ChamsSettings.Color, 0.3)

    highlight.Parent = player.Character
end

-- Function to handle player added
local function onPlayerAdded(player)
    if player.Character then
        highlightPlayer(player)
    end
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
    end)
end

-- Connect to existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Connect to new players joining
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle team change
Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            highlightPlayer(player)
        end
    end)
end)
