-- Visuals (HIGHLIGHT) (ertedHIGHTLIGHTgfdwq.lua) (PinguinDEV)
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

    if getgenv().Pinguin.ChamsSettings.Enabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
        highlight.FillTransparency = 1
        highlight.OutlineColor = lightenColor(getgenv().Pinguin.ChamsSettings.Color, 0.3)
        highlight.Parent = player.Character
    end
end

local function onPlayerAdded(player)
    if getgenv().Pinguin.ChamsSettings.Enabled then
        if player.Character then
            highlightPlayer(player)
        end
        player.CharacterAdded:Connect(function()
            highlightPlayer(player)
        end)
    end
end

local function onPlayerRemoved(player)
    local highlight = player.Character and player.Character:FindFirstChild("PlayerHighlight")
    if highlight then
        highlight:Destroy()
    end
end

for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoved)

Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            highlightPlayer(player)
        end
    end)
end)

local function ToggleChams(state)
    getgenv().Pinguin.ChamsSettings.Enabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(function(character)
                    highlightPlayer(player)
                end)
                if player.Character then
                    highlightPlayer(player)
                end
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local highlight = player.Character:FindFirstChild("PlayerHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

return ToggleChams
