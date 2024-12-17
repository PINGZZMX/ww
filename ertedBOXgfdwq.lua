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
    if not Environment.Settings.TeamCheck then
        return false
    end

    if Environment.TeammateStatus[Player.UserId] ~= nil then
        return Environment.TeammateStatus[Player.UserId]
    end

    local isTeammate = LocalPlayer.Team and Player.Team and Player.Team == LocalPlayer.Team
    Environment.TeammateStatus[Player.UserId] = isTeammate
    return isTeammate
end

local function CreateBox(Player)
    if Environment.Settings.TeamCheck and IsPlayerTeammate(Player) then
        return nil  -- Skip if the player is a teammate
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
    if Environment.Settings.TeamCheck and IsPlayerTeammate(Player) then
        return  -- Skip wrapping if the player is a teammate
    end

    local PlayerBox = CreateBox(Player)
    if not PlayerBox then return end

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
