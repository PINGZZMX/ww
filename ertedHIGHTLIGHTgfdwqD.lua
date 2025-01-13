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
    if player == LocalPlayer then return end

    if player.Character then
        local highlight = player.Character:FindFirstChild("PlayerHighlight") or Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = lightenColor(getgenv().Pinguin.ChamsSettings.Color, 0.3)
        highlight.OutlineTransparency = 0
        highlight.Parent = player.Character
    end
end

local function onCharacterAdded(character)
    local player = Players:GetPlayerFromCharacter(character)
    if player and getgenv().Pinguin.ChamsSettings.Enabled then
        highlightPlayer(player)
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function onPlayerRemoved(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("PlayerHighlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function ToggleChams(state)
    getgenv().Pinguin.ChamsSettings.Enabled = state

    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                onPlayerAdded(player)
            end
        end

        -- Start the update loop to reapply highlights
        RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    highlightPlayer(player)
                end
            end
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("PlayerHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoved)

return ToggleChams
