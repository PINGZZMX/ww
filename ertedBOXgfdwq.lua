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
            Transparency = 1,
            Thickness = 2,
            Filled = false
        }
    },
    WrappedPlayers = {},
    TeammateStatus = {}
}

local Environment = getgenv().PinguinHub.WallHack

-- Function to check if the player is a teammate
local function IsPlayerTeammate(Player)
    if Environment.TeammateStatus[Player.UserId] ~= nil then
        return Environment.TeammateStatus[Player.UserId]
    end

    if Environment.Settings.TeamCheck then
        local character = workspace:FindFirstChild(Player.Name)
        if character and character:FindFirstChild("HumanoidRootPart") then
            local isTeammate = character.HumanoidRootPart:FindFirstChild("TeammateLabel") ~= nil
            Environment.TeammateStatus[Player.UserId] = isTeammate
            return isTeammate
        end
    end

    Environment.TeammateStatus[Player.UserId] = false
    return false
end

-- Function to create ESP box for a player
local function CreateBox(Player)
    local Box = {}
    Box.Square = Drawingnew("Square")
    Box.Square.Color = Environment.Settings.BoxSettings.Color
    Box.Square.Transparency = Environment.Settings.BoxSettings.Transparency
    Box.Square.Thickness = Environment.Settings.BoxSettings.Thickness
    Box.Square.Filled = Environment.Settings.BoxSettings.Filled

    Box.Update = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            if IsPlayerTeammate(Player) then
                Box.Square.Visible = false
                return
            end

            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local height = humanoid.RootPart.Size.Y * 2200
                local Pos, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)

                if OnScreen then
                    Box.Square.Size = Vector2new(2000 / Pos.Z, height / Pos.Z)
                    Box.Square.Position = Vector2new(Pos.X - Box.Square.Size.X / 2, Pos.Y - Box.Square.Size.Y / 2.475)
                    Box.Square.Visible = true
                else
                    Box.Square.Visible = false
                end
            else
                Box.Square.Visible = false
            end
        else
            Box.Square.Visible = false
        end
    end

    Box.Remove = function()
        Box.Square:Remove()
    end

    return Box
end

-- Function to wrap a player with an ESP box
local function WrapPlayer(Player)
    local PlayerBox = CreateBox(Player)
    Environment.WrappedPlayers[Player.UserId] = PlayerBox

    -- Ensure we only update the box if it exists
    PlayerBox.UpdateConnection = RunService.RenderStepped:Connect(function()
        if PlayerBox.Square then
            PlayerBox.Update()
        end
    end)

    Player.AncestryChanged:Connect(function(_, Parent)
        if not Parent then
            -- Only remove the box if it exists
            if PlayerBox.Square then
                PlayerBox.Remove()
            end
            Environment.WrappedPlayers[Player.UserId] = nil
            Environment.TeammateStatus[Player.UserId] = nil
            PlayerBox.UpdateConnection:Disconnect()
            PlayerBox = nil
        end
    end)
end


-- Function to refresh all ESP boxes
local function RefreshBoxes()
    while Environment.Settings.BoxSettings.Enabled do
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and not Environment.WrappedPlayers[Player.UserId] then
                WrapPlayer(Player)
            end
        end
        wait(0.1)
    end
end

-- Function to toggle ESP visibility
local function toggleESP(state)
    Environment.Settings.BoxSettings.Enabled = state
    print("Box ESP:", state and "ON" or "OFF")

    if state then
        RefreshBoxes()
    else
        -- Hide all boxes when ESP is disabled
        for _, PlayerBox in pairs(Environment.WrappedPlayers) do
            PlayerBox.Remove()
        end
        Environment.WrappedPlayers = {}
    end
end

-- Return the toggle function for use in the main script
return toggleESP
