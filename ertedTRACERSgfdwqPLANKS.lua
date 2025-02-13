-- Visuals (TRACERS) (ertedTRACERSgfdwqPLANKS.lua) (PinguinDEV)
local Drawing = Drawing or require(game:GetService("Drawing"))
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.TracerModule = getgenv().Pinguin.TracerModule or {
    Settings = {
        Enabled = true,
        Transparency = 0.5,
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        TracerPosition = "Bottom"
    },
    WrappedPlayers = {}
}
local Environment = getgenv().Pinguin.TracerModule

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

    if not myTeam then return false end

    local enemyTeam = (myTeam == "A_Players") and teamB or teamA
    for _, playerLabel in pairs(enemyTeam:GetChildren()) do
        if playerLabel.Name == Player.Name then
            return true
        end
    end

    return false
end

local function IsPlayerDead(Player)
    local leaderboard = LocalPlayer.PlayerGui:FindFirstChild("LeaderboardGui")
    if not leaderboard then return false end

    local mainFrame = leaderboard:FindFirstChild("MainFrame")
    if not mainFrame then return false end

    local teamA = mainFrame:FindFirstChild("A_Players")
    local teamB = mainFrame:FindFirstChild("B_Players")
    if not (teamA and teamB) then return false end

    local playerFrame = teamA:FindFirstChild(Player.Name) or teamB:FindFirstChild(Player.Name)
    if not playerFrame then return false end

    local deadLabel = playerFrame:FindFirstChild("Dead")
    if deadLabel and deadLabel:IsA("ImageLabel") then
        return deadLabel.Visible
    end

    return false
end

local function isVisible(Player)
    local character = Player.Character
    if not character then return false end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).unit * (rootPart.Position - Camera.CFrame.Position).magnitude)
    local hitPart = workspace:FindPartOnRay(ray, character)

    return hitPart == nil
end

local function getTracerStartPosition()
    local viewportSize = Camera.ViewportSize
    if Environment.Settings.TracerPosition == "Center" then
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    elseif Environment.Settings.TracerPosition == "Mouse" then
        return UserInputService:GetMouseLocation()
    elseif Environment.Settings.TracerPosition == "Top" then
        return Vector2.new(viewportSize.X / 2, 0)
    elseif Environment.Settings.TracerPosition == "Left" then
        return Vector2.new(0, viewportSize.Y / 2)
    elseif Environment.Settings.TracerPosition == "Right" then
        return Vector2.new(viewportSize.X, viewportSize.Y / 2)
    else
        return Vector2.new(viewportSize.X / 2, viewportSize.Y)
    end
end

local function Wrap(Player)
    local PlayerTable = Environment.WrappedPlayers[Player.Name]

    if not PlayerTable then
        PlayerTable = { Tracer = Drawing.new("Line"), Connections = {} }
        Environment.WrappedPlayers[Player.Name] = PlayerTable

        PlayerTable.Connections.Tracer = RunService.RenderStepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Environment.Settings.Enabled then
                local Position, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

                if OnScreen and IsEnemy(Player) and not IsPlayerDead(Player) then
                    PlayerTable.Tracer.Visible = true
                    PlayerTable.Tracer.From = getTracerStartPosition()
                    PlayerTable.Tracer.To = Vector2.new(Position.X, Position.Y)

                    -- Wall check logic
                    if isVisible(Player) then
                        PlayerTable.Tracer.Color = Color3.new(0, 255, 0)
                    else
                        PlayerTable.Tracer.Color = Color3.new(255, 0, 0)
                    end
                    
                    PlayerTable.Tracer.Thickness = Environment.Settings.Thickness
                    PlayerTable.Tracer.Transparency = Environment.Settings.Transparency
                else
                    PlayerTable.Tracer.Visible = false
                end
            else
                PlayerTable.Tracer.Visible = false
            end
        end)
    end
end

local function UnWrap(Player)
    if Environment.WrappedPlayers[Player.Name] then
        local PlayerTable = Environment.WrappedPlayers[Player.Name]
        PlayerTable.Tracer:Remove()
        PlayerTable.Connections.Tracer:Disconnect()
        Environment.WrappedPlayers[Player.Name] = nil
    end
end

local function Load()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            Wrap(Player)
        end
    end

    Players.PlayerAdded:Connect(function(Player)
        Wrap(Player)
    end)
    Players.PlayerRemoving:Connect(UnWrap)
end

local function toggleTracersESP(state)
    Environment.Settings.Enabled = state

    if state then
        Load()
    else
        for PlayerName, PlayerTable in pairs(Environment.WrappedPlayers) do
            UnWrap(Players:FindFirstChild(PlayerName))
        end
    end
end

return toggleTracersESP
