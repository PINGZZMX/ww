-- Visuals (BOXES PLANKS) (ertedBOXgfdwqPLANKS.lua) (PinguinDEV)
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
        WallCheckEnabled = false,
        BoxSettings = {
            Enabled = true,
            Type = 1,
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 0.5,
            FillColor = Color3fromRGB(255, 255, 255),
            FillTransparency = 0.2,
            Thickness = 1,
            Filled = false
        }
    },
    WrappedPlayers = {},
    TeammateStatus = {}
}

local Environment = getgenv().PinguinHub.WallHack

local function GetMyTeam()
    local leaderboard = LocalPlayer.PlayerGui:FindFirstChild("LeaderboardGui")
    if not leaderboard then return nil, nil end

    local mainFrame = leaderboard:FindFirstChild("MainFrame")
    if not mainFrame then return nil, nil end

    local teamA = mainFrame:FindFirstChild("A_Players")
    local teamB = mainFrame:FindFirstChild("B_Players")
    if not (teamA and teamB) then return nil, nil end

    local myTeam = nil
    local myTeamFrame = nil

    for _, playerLabel in pairs(teamA:GetChildren()) do
        if playerLabel.Name == LocalPlayer.Name then
            myTeam = "A_Players"
            myTeamFrame = teamA
            break
        end
    end

    if not myTeam then
        for _, playerLabel in pairs(teamB:GetChildren()) do
            if playerLabel.Name == LocalPlayer.Name then
                myTeam = "B_Players"
                myTeamFrame = teamB
                break
            end
        end
    end

    return myTeam, myTeamFrame
end

local function IsEnemy(Player)
    local _, myTeamFrame = GetMyTeam()
    if not myTeamFrame then
        return false
    end

    for _, playerLabel in pairs(myTeamFrame:GetChildren()) do
        if playerLabel.Name == Player.Name then
            return false
        end
    end
    return true
end

local function IsAlive(Player)
    if not Player.Character then return false end
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsPlayerBehindWall(player)
    local origin = Camera.CFrame.Position
    local target = player.Character.HumanoidRootPart.Position
    local ray = Ray.new(origin, (target - origin).unit * (origin - target).magnitude)
    local hitPart, hitPosition = workspace:FindPartOnRay(ray)

    return hitPart and not player.Character:FindFirstChild(hitPart.Name)
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
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and IsAlive(Player) and IsEnemy(Player) then
            local distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= 250 then
                local height = Player.Character.HumanoidRootPart.Size.Y * 2200
                local Pos, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

                if OnScreen then
                    local sizeX = 2000 / Pos.Z
                    local sizeY = height / Pos.Z

                    Box.BorderSquare.Size = Vector2.new(sizeX, sizeY)
                    Box.BorderSquare.Position = Vector2.new(Pos.X - sizeX / 2, Pos.Y - sizeY / 2.475)
                    Box.BorderSquare.Visible = true

                    Box.FillSquare.Size = Vector2.new(sizeX, sizeY)
                    Box.FillSquare.Position = Vector2.new(Pos.X - sizeX / 2, Pos.Y - sizeY / 2.475)
                    Box.FillSquare.Visible = Environment.Settings.BoxSettings.Filled

                    if Environment.Settings.WallCheckEnabled then
                        if IsPlayerBehindWall(Player) then
                            Box.BorderSquare.Color = Color3.fromRGB(255, 0, 0)
                        else
                            Box.BorderSquare.Color = Color3.fromRGB(0, 255, 0)
                        end
                    else
                        Box.BorderSquare.Color = Environment.Settings.BoxSettings.Color
                    end
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

local function UpdateBoxSettings(Box)
    Box.BorderSquare.Color = Environment.Settings.BoxSettings.Color
    Box.BorderSquare.Transparency = Environment.Settings.BoxSettings.Transparency
    Box.BorderSquare.Thickness = Environment.Settings.BoxSettings.Thickness
    Box.FillSquare.Color = Environment.Settings.BoxSettings.FillColor
    Box.FillSquare.Transparency = Environment.Settings.BoxSettings.FillTransparency
    Box.FillSquare.Visible = Environment.Settings.BoxSettings.Filled
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
            PlayerBox.UpdateConnection:Disconnect()
        end
    end)
end

local function RefreshBoxes()
    while Environment.Settings.BoxSettings.Enabled do
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and not Environment.WrappedPlayers[Player.UserId] then
                WrapPlayer(Player)
            end
        end

        for _, PlayerBox in pairs(Environment.WrappedPlayers) do
            UpdateBoxSettings(PlayerBox)
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
