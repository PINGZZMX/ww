-- 3D Boxes ESP Script (3DBoxes.lua)
return function(toggleStateCallback)
    local workspace = game:GetService("Workspace")
    local camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local Box_Color = Color3.new(1, 1, 1)
    local Box_Thickness = 1
    local Box_Transparency = 1

    local Team_Check = false
    local red = Color3.fromRGB(227, 52, 52)
    local green = Color3.fromRGB(88, 217, 24)

    local function NewLine()
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Box_Color
        line.Thickness = Box_Thickness
        line.Transparency = Box_Transparency
        return line
    end

    local active = false
    local connections = {}
    local currentESP = {}

    local function clearESP()
        for _, lines in pairs(currentESP) do
            for _, line in pairs(lines) do
                line.Visible = false
                line:Remove() -- Ensure lines are removed from memory
            end
        end
        currentESP = {}
    end

    local function createESP(targetPlayer)
        local lines = {
            NewLine(), NewLine(), NewLine(), NewLine(),
            NewLine(), NewLine(), NewLine(), NewLine(),
            NewLine(), NewLine(), NewLine(), NewLine()
        }

        currentESP[targetPlayer] = lines

        local function updateESP()
            if not active or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, line in pairs(lines) do
                    line.Visible = false
                end
                return
            end

            local rootPart = targetPlayer.Character.HumanoidRootPart
            local pos, vis = camera:WorldToViewportPoint(rootPart.Position)
            if vis then
                local Scale = targetPlayer.Character.Head.Size.Y / 2
                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2)

                local corners = {
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).Position),
                    camera:WorldToViewportPoint((rootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).Position),
                }

                local pairsToDraw = {
                    {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Top rectangle
                    {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Bottom rectangle
                    {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Connecting lines
                }

                for index, pair in pairsToDraw do
                    local from = corners[pair[1]]
                    local to = corners[pair[2]]
                    local line = lines[index]
                    line.From = Vector2.new(from.X, from.Y)
                    line.To = Vector2.new(to.X, to.Y)
                    line.Visible = true
                end
            else
                for _, line in pairs(lines) do
                    line.Visible = false
                end
            end
        end

        connections[targetPlayer] = game:GetService("RunService").RenderStepped:Connect(updateESP)
    end

    local function toggleState(state)
        active = state
        if state then
            clearESP()
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    createESP(targetPlayer)
                end
            end
            connections["PlayerAdded"] = Players.PlayerAdded:Connect(createESP)
            connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(removedPlayer)
                if currentESP[removedPlayer] then
                    for _, line in pairs(currentESP[removedPlayer]) do
                        line.Visible = false
                        line:Remove()
                    end
                    currentESP[removedPlayer] = nil
                end
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
