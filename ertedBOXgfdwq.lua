-- 3D Boxes ESP Script (3DBoxes.lua)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Drawingnew = Drawing.new
local Vector2new = Vector2.new
local Color3fromRGB = Color3.fromRGB

getgenv().PinguinHub = getgenv().PinguinHub or {}
getgenv().PinguinHub.ESP = getgenv().PinguinHub.ESP or {
    Settings = {
        Enabled = true,
        BoxSettings = {
            Enabled = true,
            Color = Color3fromRGB(255, 255, 255),
            Transparency = 1,
            Thickness = 1,
            Filled = false
        }
    },
    WrappedPlayers = {}
}

local Environment = getgenv().PinguinHub.ESP

-- Function to create ESP box for a player
local function CreateBox(Player)
    local Box = {}
    Box.Lines = {
        line1 = Drawingnew("Line"),
        line2 = Drawingnew("Line"),
        line3 = Drawingnew("Line"),
        line4 = Drawingnew("Line"),
        line5 = Drawingnew("Line"),
        line6 = Drawingnew("Line"),
        line7 = Drawingnew("Line"),
        line8 = Drawingnew("Line"),
        line9 = Drawingnew("Line"),
        line10 = Drawingnew("Line"),
        line11 = Drawingnew("Line"),
        line12 = Drawingnew("Line")
    }

    for _, line in pairs(Box.Lines) do
        line.Color = Environment.Settings.BoxSettings.Color
        line.Transparency = Environment.Settings.BoxSettings.Transparency
        line.Thickness = Environment.Settings.BoxSettings.Thickness
        line.Filled = Environment.Settings.BoxSettings.Filled
        line.Visible = false
    end

    Box.Update = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Scale = Player.Character.Head.Size.Y / 2
                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                local Top1 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                local Top2 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                local Top3 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                local Top4 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                local Bottom1 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                local Bottom2 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                local Bottom3 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                local Bottom4 = Camera:WorldToViewportPoint((Player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                Box.Lines.line1.From = Vector2new(Top1.X, Top1.Y)
                Box.Lines.line1.To = Vector2new(Top2.X, Top2.Y)
                Box.Lines.line2.From = Vector2new(Top2.X, Top2.Y)
                Box.Lines.line2.To = Vector2new(Top3.X, Top3.Y)
                Box.Lines.line3.From = Vector2new(Top3.X, Top3.Y)
                Box.Lines.line3.To = Vector2new(Top4.X, Top4.Y)
                Box.Lines.line4.From = Vector2new(Top4.X, Top4.Y)
                Box.Lines.line4.To = Vector2new(Top1.X, Top1.Y)

                Box.Lines.line5.From = Vector2new(Bottom1.X, Bottom1.Y)
                Box.Lines.line5.To = Vector2new(Bottom2.X, Bottom2.Y)
                Box.Lines.line6.From = Vector2new(Bottom2.X, Bottom2.Y)
                Box.Lines.line6.To = Vector2new(Bottom3.X, Bottom3.Y)
                Box.Lines.line7.From = Vector2new(Bottom3.X, Bottom3.Y)
                Box.Lines.line7.To = Vector2new(Bottom4.X, Bottom4.Y)
                Box.Lines.line8.From = Vector2new(Bottom4.X, Bottom4.Y)
                Box.Lines.line8.To = Vector2new(Bottom1.X, Bottom1.Y)

                Box.Lines.line9.From = Vector2new(Bottom1.X, Bottom1.Y)
                Box.Lines.line9.To = Vector2new(Top1.X, Top1.Y)
                Box.Lines.line10.From = Vector2new(Bottom2.X, Bottom2.Y)
                Box.Lines.line10.To = Vector2new(Top2.X, Top2.Y)
                Box.Lines.line11.From = Vector2new(Bottom3.X, Bottom3.Y)
                Box.Lines.line11.To = Vector2new(Top3.X, Top3.Y)
                Box.Lines.line12.From = Vector2new(Bottom4.X, Bottom4.Y)
                Box.Lines.line12.To = Vector2new(Top4.X, Top4.Y)

                for _, line in pairs(Box.Lines) do
                    line.Visible = true
                end
            else
                for _, line in pairs(Box.Lines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(Box.Lines) do
                line.Visible = false
            end
        end
    end

    Box.Remove = function()
        for _, line in pairs(Box.Lines) do
            line:Remove()
        end
    end

    return Box
end

-- Function to wrap a player with an ESP box
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
    print("3D Box ESP:", state and "ON" or "OFF")

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
