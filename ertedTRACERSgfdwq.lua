local Drawing = Drawing or require(game:GetService("Drawing"))
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.TracerModule = getgenv().Pinguin.TracerModule or { Settings = { Enabled = true, Transparency = 0.5, Thickness = 1, Color = Color3.new(1, 1, 1) }, WrappedPlayers = {} }
local Environment = getgenv().Pinguin.TracerModule

local function Wrap(Player)
    local PlayerTable = Environment.WrappedPlayers[Player.Name]

    if not PlayerTable then
        PlayerTable = { Tracer = Drawing.new("Line"), Connections = {} }
        Environment.WrappedPlayers[Player.Name] = PlayerTable

        PlayerTable.Connections.Tracer = RunService.RenderStepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Environment.Settings.Enabled then
                local Position, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

                if OnScreen then
                    PlayerTable.Tracer.Visible = true
                    PlayerTable.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local offset = 0
                    PlayerTable.Tracer.To = Vector2.new(Position.X, Position.Y + offset)

                    PlayerTable.Tracer.Color = Environment.Settings.Color
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

    Players.PlayerAdded:Connect(Wrap)
    Players.PlayerRemoving:Connect(UnWrap)
end

local function toggleTracersESP(state)
    Environment.Settings.Enabled = state
    print("Tracers ESP:", state and "ON" or "OFF")

    if state then
        Load()
    else
        for PlayerName, PlayerTable in pairs(Environment.WrappedPlayers) do
            UnWrap(Players:FindFirstChild(PlayerName))
        end
    end
end

return toggleTracersESP
