-- Visuals Script (WallHack/ESP) (Visuals.lua)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Vector2new, Drawingnew, Color3fromRGB = Vector2.new, Drawing.new, Color3.fromRGB

getgenv().PinguinHub = getgenv().PinguinHub or {}
getgenv().PinguinHub.WallHack = getgenv().PinguinHub.WallHack or {
    Settings = {
        Enabled = true,
        TeamCheck = true,
        BoxSettings = {
            Enabled = true,
            Type = 1,
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 0.5,
            FillColor = Color3fromRGB(255, 255, 255),
            FillTransparency = 0.2,
            Thickness = 1,
            Filled = false -- Set to false by default
        }
    },
    WrappedPlayers = {}
}

local Environment = getgenv().PinguinHub.WallHack

-- Function to determine if the player is on the opposite team
local function IsEnemy(Player)
    local leaderboard = LocalPlayer.PlayerGui:FindFirstChild("LeaderboardGui")
    if not leaderboard then return false end

    local mainFrame = leaderboard:FindFirstChild("MainFrame")
    if not mainFrame then return false end

    local teamA = mainFrame:FindFirstChild("A_Players")
    local teamB = mainFrame:FindFirstChild("B_Players")
    if not (teamA and teamB) then return false end

    local myTeam = nil

    for _, playerLabel in pairs(teamA:GetChildren()) do
        if playerLabel.Name == LocalPlayer.Name then
            myTeam = "A_Players"
            break
        end
    end

    for _, playerLabel in pairs(teamB:GetChildren()) do
        if playerLabel.Name == LocalPlayer.Name then
            myTeam = "B_Players"
            break
        end
    end

    if not myTeam then return false end -- LocalPlayer is not on any team

    -- Check if the target player is in the opposite team
    local enemyTeam = (myTeam == "A_Players") and teamB or teamA
    for _, playerLabel in pairs(enemyTeam:GetChildren()) do
        if playerLabel.Name == Player.Name then
            return true
        end
    end

    return false
end

local function CreateBox(Player)
    local Box = {}
    Box.BorderSquare = Drawing.new("Square")
    Box.BorderSquare.Color = Environment.Settings.BoxSettings.Color
    Box.BorderSquare.Transparency = Environment.Settings.BoxSettings.Transparency
    Box.BorderSquare.Thickness = Environment.Settings.BoxSettings.Thickness
    Box.BorderSquare.Filled = false

    Box.FillSquare = Drawing.new("Square")
    Box.FillSquare.Color = Environment.Settings.BoxSettings.FillColor
    Box.FillSquare.Transparency = Environment.Settings.BoxSettings.FillTransparency
    Box.FillSquare.Thickness = 0
    Box.FillSquare.Filled = true
    Box.FillSquare.Visible = Environment.Settings.BoxSettings.Filled

    Box.Update = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(Player) then
            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local height = Player.Character.HumanoidRootPart.Size.Y * 2200
                local Pos, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

                if OnScreen then
                    -- Scale the box size based on the camera's FOV
                    local baseFOV = 70 -- The base FOV for which the size is currently calibrated
                    local currentFOV = Camera.FieldOfView
                    local fovScale = baseFOV / currentFOV

                    local sizeX = (2000 / Pos.Z) * fovScale
                    local sizeY = (height / Pos.Z) * fovScale

                    Box.BorderSquare.Size = Vector2.new(sizeX, sizeY)
                    Box.BorderSquare.Position = Vector2.new(Pos.X - sizeX / 2, Pos.Y - sizeY / 2.475)
                    Box.BorderSquare.Visible = true

                    Box.FillSquare.Size = Vector2.new(sizeX, sizeY)
                    Box.FillSquare.Position = Vector2.new(Pos.X - sizeX / 2, Pos.Y - sizeY / 2.475)

                    Box.FillSquare.Visible = Environment.Settings.BoxSettings.Filled
                else
                    Box.BorderSquare.Visible = false
                    Box.FillSquare.Visible = false
                end
            else
                Box.BorderSquare.Visible = false
                Box.FillSquare.Visible = false
            end
        else
            Box.BorderSquare.Visible = false
            Box.FillSquare.Visible = false
        end
    end

    Box.Remove = function()
        Box.BorderSquare:Remove()
        Box.FillSquare:Remove()
    end

    return Box
end

local function WrapPlayer(Player)
    local PlayerBox = CreateBox(Player)
    Environment.WrappedPlayers[Player.UserId] = PlayerBox

    PlayerBox.UpdateConnection = RunService.RenderStepped:Connect(function()
        PlayerBox.Update()
    end)

    Player.AncestryChanged:Connect(function(_, Parent)
        if not Parent then
            PlayerBox.Remove()
            Environment.WrappedPlayers[Player.UserId] = nil
        end
    end)
end

local function RefreshBoxes()
    while Environment.Settings.BoxSettings.Enabled do
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and not Environment.WrappedPlayers[Player.UserId] and IsEnemy(Player) then
                WrapPlayer(Player)
            end
        end

        wait(0.1)
    end
end

local function toggleESP(state)
    Environment.Settings.BoxSettings.Enabled = state

    if state then
        RefreshBoxes()
    else
        for _, PlayerBox in pairs(Environment.WrappedPlayers) do
            PlayerBox.Remove()
        end
        Environment.WrappedPlayers = {}
    end
end

return toggleESP
