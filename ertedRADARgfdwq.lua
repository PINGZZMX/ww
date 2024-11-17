local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RS = game:GetService("RunService")

repeat wait() until Player.Character and Player.Character.PrimaryPart

-- Lerp Color Module for health bar
local LerpColorModule = loadstring(game:HttpGet("https://pastebin.com/raw/wRnsJeid"))()
local HealthBarLerp = LerpColorModule:Lerp(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))

local RadarInfo = {
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
    PlayerDot = Color3.fromRGB(60, 170, 255),
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Health_Color = true,
    Team_Check = true
}

-- Initialize drawing elements (only once)
local RadarBackground, RadarBorder
local LocalPlayerDot
local PlayerDots = {}

local function NewCircle(Transparency, Color, Radius, Filled, Thickness)
    local c = Drawing.new("Circle")
    c.Transparency = Transparency
    c.Color = Color
    c.Visible = false
    c.Thickness = Thickness
    c.Position = Vector2.new(0, 0)
    c.Radius = Radius
    c.NumSides = math.clamp(Radius * 55 / 100, 10, 75)
    c.Filled = Filled
    return c
end

local function GetRelative(pos)
    local char = Player.Character
    if char and char.PrimaryPart then
        local pmpart = char.PrimaryPart
        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
        local newcf = CFrame.new(pmpart.Position, camerapos)
        return newcf:PointToObjectSpace(pos).X, newcf:PointToObjectSpace(pos).Z
    end
    return 0, 0
end

local function PlaceDot(plr)
    local PlayerDot = NewCircle(1, RadarInfo.PlayerDot, 3, true, 1)
    PlayerDots[plr.Name] = PlayerDot

    local function Update()
        local c
        c = RS.RenderStepped:Connect(function()
            local char = plr.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.PrimaryPart and char.Humanoid.Health > 0 then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local scale = RadarInfo.Scale
                local relx, rely = GetRelative(char.PrimaryPart.Position)
                local newpos = RadarInfo.Position - Vector2.new(relx * scale, rely * scale)

                if (newpos - RadarInfo.Position).magnitude < RadarInfo.Radius - 2 then
                    PlayerDot.Radius = 3
                    PlayerDot.Position = newpos
                    PlayerDot.Visible = true
                else
                    local dist = (RadarInfo.Position - newpos).magnitude
                    local calc = (RadarInfo.Position - newpos).unit * (dist - RadarInfo.Radius)
                    local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                    PlayerDot.Radius = 2
                    PlayerDot.Position = inside
                    PlayerDot.Visible = true
                end

                PlayerDot.Color = RadarInfo.PlayerDot
                if RadarInfo.Team_Check then
                    if plr.TeamColor == Player.TeamColor then
                        PlayerDot.Color = RadarInfo.Team
                    else
                        PlayerDot.Color = RadarInfo.Enemy
                    end
                end

                if RadarInfo.Health_Color then
                    PlayerDot.Color = HealthBarLerp(hum.Health / hum.MaxHealth)
                end
            else
                PlayerDot.Visible = false
                if Players:FindFirstChild(plr.Name) == nil then
                    PlayerDot:Remove()
                    c:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

local function NewLocalDot()
    local d = Drawing.new("Triangle")
    d.Visible = true
    d.Thickness = 1
    d.Filled = true
    d.Color = RadarInfo.LocalPlayerDot
    d.PointA = RadarInfo.Position + Vector2.new(0, -6)
    d.PointB = RadarInfo.Position + Vector2.new(-3, 6)
    d.PointC = RadarInfo.Position + Vector2.new(3, 6)
    return d
end

local function LoadRadar()
    -- Initialize elements if not already done
    if not RadarBackground then
        RadarBackground = NewCircle(0.9, RadarInfo.RadarBack, RadarInfo.Radius, true, 1)
        RadarBackground.Visible = true
    end

    if not RadarBorder then
        RadarBorder = NewCircle(0.75, RadarInfo.RadarBorder, RadarInfo.Radius, false, 3)
        RadarBorder.Visible = true
    end

    if not LocalPlayerDot then
        LocalPlayerDot = NewLocalDot()
    end

    RadarBackground.Position = RadarInfo.Position
    RadarBorder.Position = RadarInfo.Position
    LocalPlayerDot.Position = RadarInfo.Position

    -- Loop through all players to display their radar dots
    for _, v in pairs(Players:GetChildren()) do
        if v.Name ~= Player.Name then
            PlaceDot(v)
        end
    end
end

local function UnloadRadar()
    -- Remove all player dots
    for _, dot in pairs(PlayerDots) do
        dot:Remove()
    end
    PlayerDots = {}

    -- Remove radar elements
    if RadarBackground then
        RadarBackground.Visible = false
    end
    if RadarBorder then
        RadarBorder.Visible = false
    end
    if LocalPlayerDot then
        LocalPlayerDot.Visible = false
    end
end

-- Return the functions and objects needed by the main script
return {
    LoadRadar = LoadRadar,
    UnloadRadar = UnloadRadar,
    RadarInfo = RadarInfo,
    RadarBackground = RadarBackground,
    RadarBorder = RadarBorder,
    LocalPlayerDot = LocalPlayerDot
}
