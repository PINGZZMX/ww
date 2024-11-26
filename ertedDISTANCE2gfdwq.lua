-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Ensure the environment is properly initialized
getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.DistanceSettings = getgenv().Pinguin.DistanceSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)  -- Default color (white)
}

-- Initialize espObjects if not already initialized
local espObjects = getgenv().Pinguin.ESPObjects or {}

-- Utility function to calculate distance from the camera
local function GetDistanceFromCamera(part)
    return (part.Position - Camera.CFrame.Position).Magnitude
end

-- Function to update the ESP color for all objects
local function UpdateESPColor()
    -- Ensure espObjects table exists and is valid
    if type(espObjects) ~= "table" then
        espObjects = {}  -- Reinitialize if it's invalid
        getgenv().Pinguin.ESPObjects = espObjects  -- Update the global environment
    end
    
    -- Update the color for each ESP element
    for _, espData in pairs(espObjects) do
        if espData.text then
            espData.text.Color = getgenv().Pinguin.DistanceSettings.Color
        end
    end
end

-- Function to add ESP to a player
local function AddDistanceESP(player)
    -- Ignore the local player or players without a character
    if player == Players.LocalPlayer or not player.Character then return end

    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Create the text label for ESP
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Font = 2
    text.Color = getgenv().Pinguin.DistanceSettings.Color
    text.Size = 13

    -- Store connections to clean up later
    local connections = {}

    -- RenderStepped connection to update position
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

    -- HealthChanged connection to remove ESP when player dies
    connections[#connections + 1] = character:FindFirstChild("Humanoid").HealthChanged:Connect(function(health)
        if health <= 0 then RemoveDistanceESP(player) end
    end)

    -- AncestryChanged connection to remove ESP when player is removed
    connections[#connections + 1] = character.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveDistanceESP(player) end
    end)

    -- Store the ESP data in the table
    espObjects[player.UserId] = {text = text, connections = connections}
end

-- Function to remove ESP from a player
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

-- Function to toggle the Distance ESP
local function ToggleDistanceESP(state)
    getgenv().Pinguin.DistanceSettings.Enabled = state
    if state then
        -- Enable ESP for all players
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
        -- Disable ESP for all players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                RemoveDistanceESP(player)
            end
        end
    end
end

-- Return the toggle function for use in the main script
return ToggleDistanceESP
