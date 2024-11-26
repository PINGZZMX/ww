-- Visuals Script for 2D and 3D ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Vector2new, Drawingnew, Color3fromRGB = Vector2.new, Drawing.new, Color3.fromRGB

getgenv().PinguinHub = getgenv().PinguinHub or {}
getgenv().PinguinHub.WallHack = getgenv().PinguinHub.WallHack or {
    Settings = {
        Enabled = true,
        TeamCheck = true,
        BoxSettings = {
            Enabled = true,
            Type = 1,  -- Default to 2D
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 0.5,
            Thickness = 1,
            Filled = false
        }
    },
    WrappedPlayers = {},
    TeammateStatus = {}
}

local Environment = getgenv().PinguinHub.WallHack

-- 2D Box ESP Code
local function Create2DBox(Player)
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

-- 3D Box ESP Code
local function Create3DBox(Player)
    local Box = {}
    Box.Corners = {}
    local Offset = Vector3.new(0, 2, 0)

    Box.Update = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            if IsPlayerTeammate(Player) then return end

            local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local rootPos = humanoidRootPart.Position
                local height = Player.Character:FindFirstChildOfClass("Humanoid").Height
                local width = 2

                -- Define 3D box corners
                local corners = {
                    rootPos + Vector3.new(-width, height, -width),
                    rootPos + Vector3.new(width, height, -width),
                    rootPos + Vector3.new(width, height, width),
                    rootPos + Vector3.new(-width, height, width),
                    rootPos + Vector3.new(-width, 0, -width),
                    rootPos + Vector3.new(width, 0, -width),
                    rootPos + Vector3.new(width, 0, width),
                    rootPos + Vector3.new(-width, 0, width),
                }

                -- Convert 3D corners to 2D screen positions
                for _, corner in ipairs(corners) do
                    local pos, onScreen = Camera:WorldToViewportPoint(corner)
                    if onScreen then
                        table.insert(Box.Corners, Vector2new(pos.X, pos.Y))
                    end
                end

                -- Draw 3D box if all corners are visible
                if #Box.Corners == 8 then
                    for i = 1, 4 do
                        Drawing.new("Line").From = Box.Corners[i]
                        Drawing.new("Line").To = Box.Corners[i + 4]
                        -- Connecting horizontal edges
                        Drawing.new("Line").From = Box.Corners[i]
                        Drawing.new("Line").To = Box.Corners[(i % 4) + 1]
                        -- Connecting vertical edges
                        Drawing.new("Line").From = Box.Corners[i + 4]
                        Drawing.new("Line").To = Box.Corners[(i + 1) % 4 + 5]
                    end
                end
            end
        end
    end

    Box.Remove = function()
        for _, line in ipairs(Box.Corners) do
            line:Remove()
        end
    end

    return Box
end

-- Function to toggle ESP (2D or 3D)
local function toggleESP(state, boxType)
    if state then
        if boxType == "2D Boxes" then
            -- Toggle 2D ESP
            -- This will be called to create or update 2D boxes.
            for _, player in ipairs(Players:GetPlayers()) do
                local box = Create2DBox(player)
                box.Update()
            end
        elseif boxType == "3D Boxes" then
            -- Toggle 3D ESP
            -- This will create and update 3D boxes.
            for _, player in ipairs(Players:GetPlayers()) do
                local box = Create3DBox(player)
                box.Update()
            end
        end
    end
end

return toggleESP
