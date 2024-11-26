local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.ChamsSettings = getgenv().Pinguin.ChamsSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)
}

local chamsObjects = {}

local function UpdateChamsColor()
    for _, chamsData in pairs(chamsObjects) do
        chamsData.Highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
        chamsData.Highlight.OutlineColor = getgenv().Pinguin.ChamsSettings.Color
    end
end

local function ApplyChams(player)
    if player == game.Players.LocalPlayer or not player.Character then return end

    local character = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerChams"
    highlight.FillColor = getgenv().Pinguin.ChamsSettings.Color
    highlight.OutlineColor = getgenv().Pinguin.ChamsSettings.Color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.5
    highlight.Parent = character

    chamsObjects[player.UserId] = {Highlight = highlight}
end

local function RemoveChams(player)
    local chamsData = chamsObjects[player.UserId]
    if chamsData then
        chamsData.Highlight:Destroy()
        chamsObjects[player.UserId] = nil
    end
end

local function ToggleChams(state)
    getgenv().Pinguin.ChamsSettings.Enabled = state
    if state then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                player.CharacterAdded:Connect(function()
                    ApplyChams(player)
                end)
                if player.Character then
                    ApplyChams(player)
                end
            end
        end
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                RemoveChams(player)
            end
        end
    end
end

return ToggleChams
