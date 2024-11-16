-- HeadDot ESP Script (HeadDotESP.lua)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Environment
local HeadDotSettings = {
    Enabled = false, -- Initially set to false; button toggles it
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.5,
    Thickness = 1,
    Filled = false,
    Sides = 50
}

-- Table to keep track of head dots for each player
local playerDots = {}

-- Function to add a head dot for a player
local function AddHeadDot(Player)
    if Player == LocalPlayer then return end

    local headDot = Drawing.new("Circle")
    headDot.Visible = HeadDotSettings.Enabled
    headDot.Color = HeadDotSettings.Color
    headDot.Transparency = HeadDotSettings.Transparency
    headDot.Thickness = HeadDotSettings.Thickness
    headDot.Filled = HeadDotSettings.Filled
    headDot.NumSides = HeadDotSettings.Sides

    -- Update loop for the head dot
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Head") then
            local head = Player.Character.Head
            local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
            headDot.Visible = onScreen and HeadDotSettings.Enabled

            if headDot.Visible then
                headDot.Position = Vector2.new(headPosition.X, headPosition.Y)

                -- Calculate radius based on head size
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
        HeadDotSettings.Enabled = state -- Enable or disable head dots based on toggle state

        -- Update visibility for all active head dots
        for _, data in pairs(playerDots) do
            if data.headDot then
                data.headDot.Visible = state
            end
        end
    end,

    Initialize = function()
        -- Initial setup for all players
        for _, player in ipairs(Players:GetPlayers()) do
            AddHeadDot(player)
        end

        -- Connect to player added and removing events
        Players.PlayerAdded:Connect(AddHeadDot)
        Players.PlayerRemoving:Connect(RemoveHeadDot)

        -- Hide head dots if the player character is removed
        LocalPlayer.CharacterRemoving:Connect(function()
            for _, data in pairs(playerDots) do
                if data.headDot then
                    data.headDot.Visible = false
                end
            end
        end)
    end
}
