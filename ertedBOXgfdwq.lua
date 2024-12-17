local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().PinguinHub = getgenv().PinguinHub or {}
getgenv().PinguinHub.WallHack = getgenv().PinguinHub.WallHack or {
    Settings = {
        Enabled = true,
        TeamCheck = true,
        BoxSettings = {
            Enabled = true,
            Type = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.5,
            FillColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.2,
            Thickness = 1,
            Filled = false
        }
    },
    WrappedPlayers = {},
    TeammateStatus = {}
}

local Environment = getgenv().PinguinHub.WallHack

local function IsPlayerTeammate(Player)
    if Environment.TeammateStatus[Player.UserId] ~= nil then
        return Environment.TeammateStatus[Player.UserId]
    end

    -- If the player has no team, they are not a teammate
    if not Player.Team then
        Environment.TeammateStatus[Player.UserId] = false
        return false
    end

    -- Compare the teams
    local isTeammate = LocalPlayer.Team and Player.Team == LocalPlayer.Team
    Environment.TeammateStatus[Player.UserId] = isTeammate
    print("Checking player: ", Player.Name, "Teammate: ", isTeammate)
    return isTeammate
end

local function CreateBox(Player)
    -- Skip box creation if the player is a teammate and Team Check is enabled
    if Environment.Settings.TeamCheck and IsPlayerTeammate(Player) then
        return nil
    end
    
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
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
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
    -- Skip wrapping if the player is a teammate and Team Check is enabled
    if Environment.Settings.TeamCheck and IsPlayerTeammate(Player) then
        return
    end

    local PlayerBox = CreateBox(Player)
    Environment.WrappedPlayers[Player.UserId] = PlayerBox

    PlayerBox.UpdateConnection = RunService.RenderStepped:Connect(function()
        PlayerBox.Update()
    end)

    Player.AncestryChanged:Connect(function(_, Parent)
        if not Parent then
            PlayerBox.Remove()
            Environment.WrappedPlayers[Player.UserId] = nil
            Environment.TeammateStatus[Player.UserId] = nil
            PlayerBox.UpdateConnection:Disconnect()
            PlayerBox = nil
        end
    end)
end

Players.PlayerAdded:Connect(WrapPlayer)
for _, Player in ipairs(Players:GetPlayers()) do
    WrapPlayer(Player)
end
