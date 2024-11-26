-- Ensure HeadDotSettings is globally accessible
getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.HeadDotSettings = getgenv().Pinguin.HeadDotSettings or {
    Enabled = false, -- Initially set to false; button toggles it
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

-- Table to keep track of head dots for each player
local playerDots = {}

-- Function to add a head dot for a player
local function AddHeadDot(Player)
    if Player == LocalPlayer then return end

    local headDot = Drawing.new("Circle")
    headDot.Visible = getgenv().Pinguin.HeadDotSettings.Enabled
    headDot.Color = getgenv().Pinguin.HeadDotSettings.Color
    headDot.Transparency = getgenv().Pinguin.HeadDotSettings.Transparency
    headDot.Thickness = getgenv().Pinguin.HeadDotSettings.Thickness
    headDot.Filled = getgenv().Pinguin.HeadDotSettings.Filled
    headDot.NumSides = getgenv().Pinguin.HeadDotSettings.Sides

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Head") then
            local head = Player.Character.Head
            local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
            headDot.Visible = onScreen and getgenv().Pinguin.HeadDotSettings.Enabled

            if headDot.Visible then
                headDot.Position = Vector2.new(headPosition.X, headPosition.Y)

                local top = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, head.Size.Y / 2, 0)).Position)
                local bottom = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, -head.Size.Y / 2, 0)).Position)
                headDot.Radius = math.abs((top.Y - bottom.Y) - 3)
            end
        else
            headDot.Visible = false
        end
    end)

    playerDots[Player.UserId] = { headDot = headDot, connection = connection }
end

-- Function to remove a head dot for a player
local function RemoveHeadDot(Player)
    local data = playerDots[Player.UserId]
    if data then
        data.headDot:Remove()
        data.connection:Disconnect()
        playerDots[Player.UserId] = nil
    end
end

-- Return functions for toggling HeadDot ESP
return {
    ToggleHeadDotESP = function(state)
        getgenv().Pinguin.HeadDotSettings.Enabled = state

        -- Update visibility for all active head dots
        for _, data in pairs(playerDots) do
            if data.headDot then
                data.headDot.Visible = state
            end
        end
    end,

    Initialize = function()
        -- Ensure the playerDots table is initialized
        if not next(playerDots) then
            for _, player in ipairs(Players:GetPlayers()) do
                AddHeadDot(player)
            end
        end

        Players.PlayerAdded:Connect(AddHeadDot)
        Players.PlayerRemoving:Connect(RemoveHeadDot)

        LocalPlayer.CharacterRemoving:Connect(function()
            for _, data in pairs(playerDots) do
                if data.headDot then
                    data.headDot.Visible = false
                end
            end
        end)
    end
}
