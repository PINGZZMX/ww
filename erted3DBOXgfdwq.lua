-- Visuals (3D BOXES) (erted3DBOXgfdwq.lua) (PinguinDEV)
return function(toggleStateCallback)
    local workspace = game:GetService("Workspace")
    local camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    getgenv().PinguinHub = getgenv().PinguinHub or {}
    getgenv().PinguinHub.WallHack = getgenv().PinguinHub.WallHack or {
        Settings = {
            BoxSettings = {
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 1,
                Thickness = 1,
                Enabled = true
            }
        },
        WrappedPlayers = {}
    }

    local Environment = getgenv().PinguinHub.WallHack

    local function NewLine()
        local line = Drawing.new("Line")
        line.Visible = false
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(1, 1)
        line.Color = Environment.Settings.BoxSettings.Color
        line.Thickness = Environment.Settings.BoxSettings.Thickness
        line.Transparency = Environment.Settings.BoxSettings.Transparency
        return line
    end

    local active = false
    local connections = {}
    local currentESP = {}

    local function clearESP()
        for _, line in pairs(currentESP) do
            line.Visible = false
        end
        currentESP = {}
    end

    local function createESP(player)
        local lines = {
            line1 = NewLine(), line2 = NewLine(),
            line3 = NewLine(), line4 = NewLine(),
            line5 = NewLine(), line6 = NewLine(),
            line7 = NewLine(), line8 = NewLine(),
            line9 = NewLine(), line10 = NewLine(),
            line11 = NewLine(), line12 = NewLine()
        }

        currentESP = lines

        local function updateESP()
            if not active or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                clearESP()
                return
            end

            local pos, vis = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if vis then
                local Scale = player.Character.Head.Size.Y / 2
                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                local Top1 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                local Top2 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                local Top3 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                local Top4 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                local Bottom1 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                local Bottom2 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                local Bottom3 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                local Bottom4 = camera:WorldToViewportPoint((player.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                lines.line1.To = Vector2.new(Top2.X, Top2.Y)
                lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                lines.line2.To = Vector2.new(Top3.X, Top3.Y)
                lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                lines.line3.To = Vector2.new(Top4.X, Top4.Y)
                lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                lines.line9.To = Vector2.new(Top1.X, Top1.Y)
                lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                lines.line10.To = Vector2.new(Top2.X, Top2.Y)
                lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                lines.line11.To = Vector2.new(Top3.X, Top3.Y)
                lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                for _, line in pairs(lines) do
                    line.Visible = true
                end
            else
                clearESP()
            end
        end

        connections[player] = game:GetService("RunService").RenderStepped:Connect(updateESP)
    end

    local function toggleState(state)
        active = state
        if state then
            clearESP()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    createESP(player)
                end
            end
            Players.PlayerAdded:Connect(function(newPlayer)
                createESP(newPlayer)
            end)
        else
            clearESP()
            for _, connection in pairs(connections) do
                connection:Disconnect()
            end
            connections = {}
        end
    end

    toggleStateCallback(toggleState)
end
