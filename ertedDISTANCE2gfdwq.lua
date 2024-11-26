local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.DistanceSettings = getgenv().Pinguin.DistanceSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)  -- Default color is white
}

local espObjects = {}

local function GetDistanceFromCamera(part)
    return (part.Position - Camera.CFrame.Position).Magnitude
end

local function UpdateESPColor()
    for _, espData in pairs(espObjects) do
        espData.text.Color = getgenv().Pinguin.DistanceSettings.Color
    end
end

local function AddDistanceESP(player)
    if player == Players.LocalPlayer or not player.Character then return end

    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Font = 2
    text.Color = getgenv().Pinguin.DistanceSettings.Color
    text.Size = 13

    local connections = {}

    connections[#connections + 1] = RunService.RenderStepped:Connect(function()
        local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            text.Position = Vector2.new(position.X, position.Y - 50)
            text.Text = string.format("[%.1f]", GetDistanceFromCamera(rootPart))
            text.Visible = true
        else
            text.Visible = false
        end
    end)

    connections[#connections + 1] = character:FindFirstChild("Humanoid").HealthChanged:Connect(function(health)
        if health <= 0 then RemoveDistanceESP(player) end
    end)

    connections[#connections + 1] = character.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveDistanceESP(player) end
    end)

    espObjects[player.UserId] = {text = text, connections = connections}
end

local function RemoveDistanceESP(player)
    local espData = espObjects[player.UserId]
    if espData then
        espData.text:Remove()
        for _, connection in pairs(espData.connections) do
            connection:Disconnect()
        end
        espObjects[player.UserId] = nil
    end
end

local function ToggleDistanceESP(state)
    getgenv().Pinguin.DistanceSettings.Enabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                player.CharacterAdded:Connect(function(character)
                    AddDistanceESP(player)
                end)
                if player.Character then
                    AddDistanceESP(player)
                end
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                RemoveDistanceESP(player)
            end
        end
    end
end

return ToggleDistanceESP
