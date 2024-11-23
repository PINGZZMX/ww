-- 3D Boxes ESP Script (3DBoxes.lua)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local connections = {}
local isESPEnabled = false -- Initial state is off

local function NewLine()
    local line = Drawing.new("Line")
    line.Visible = false
    return line
end

local function clearESP()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

local function toggleESP(state)
    if state == isESPEnabled then
        return -- No state change, exit
    end

    isESPEnabled = state
    print("v1 - ESP state changed to:", isESPEnabled)  -- Debug print for state change

    if isESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player then
                local lines = {
                    line1 = NewLine(), line2 = NewLine(), line3 = NewLine(), line4 = NewLine(),
                    line5 = NewLine(), line6 = NewLine(), line7 = NewLine(), line8 = NewLine(),
                    line9 = NewLine(), line10 = NewLine(), line11 = NewLine(), line12 = NewLine()
                }

                local function ESP()
                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        if isESPEnabled and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
                            local pos, vis = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                            if vis then
                                local Scale = v.Character.Head.Size.Y / 2
                                local Size = Vector3.new(2, 3, 1.5) * (Scale * 2) 

                                -- Calculating the top and bottom points for the box
                                local Top1 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                                local Top2 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, Size.Y, Size.Z)).p)
                                local Top3 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, Size.Z)).p)
                                local Top4 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, Size.Y, -Size.Z)).p)

                                local Bottom1 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, -Size.Z)).p)
                                local Bottom2 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(-Size.X, -Size.Y, Size.Z)).p)
                                local Bottom3 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, Size.Z)).p)
                                local Bottom4 = camera:WorldToViewportPoint((v.Character.HumanoidRootPart.CFrame * CFrame.new(Size.X, -Size.Y, -Size.Z)).p)

                                -- Top lines
                                lines.line1.From = Vector2.new(Top1.X, Top1.Y)
                                lines.line1.To = Vector2.new(Top2.X, Top2.Y)

                                lines.line2.From = Vector2.new(Top2.X, Top2.Y)
                                lines.line2.To = Vector2.new(Top3.X, Top3.Y)

                                lines.line3.From = Vector2.new(Top3.X, Top3.Y)
                                lines.line3.To = Vector2.new(Top4.X, Top4.Y)

                                lines.line4.From = Vector2.new(Top4.X, Top4.Y)
                                lines.line4.To = Vector2.new(Top1.X, Top1.Y)

                                -- Bottom lines
                                lines.line5.From = Vector2.new(Bottom1.X, Bottom1.Y)
                                lines.line5.To = Vector2.new(Bottom2.X, Bottom2.Y)

                                lines.line6.From = Vector2.new(Bottom2.X, Bottom2.Y)
                                lines.line6.To = Vector2.new(Bottom3.X, Bottom3.Y)

                                lines.line7.From = Vector2.new(Bottom3.X, Bottom3.Y)
                                lines.line7.To = Vector2.new(Bottom4.X, Bottom4.Y)

                                lines.line8.From = Vector2.new(Bottom4.X, Bottom4.Y)
                                lines.line8.To = Vector2.new(Bottom1.X, Bottom1.Y)

                                -- Side lines
                                lines.line9.From = Vector2.new(Bottom1.X, Bottom1.Y)
                                lines.line9.To = Vector2.new(Top1.X, Top1.Y)

                                lines.line10.From = Vector2.new(Bottom2.X, Bottom2.Y)
                                lines.line10.To = Vector2.new(Top2.X, Top2.Y)

                                lines.line11.From = Vector2.new(Bottom3.X, Bottom3.Y)
                                lines.line11.To = Vector2.new(Top3.X, Top3.Y)

                                lines.line12.From = Vector2.new(Bottom4.X, Bottom4.Y)
                                lines.line12.To = Vector2.new(Top4.X, Top4.Y)

                                -- Making the lines visible
                                for _, line in pairs(lines) do
                                    line.Visible = true
                                end
                            else
                                for _, line in pairs(lines) do
                                    line.Visible = false
                                end
                            end
                        else
                            for _, line in pairs(lines) do
                                line.Visible = false
                            end
                        end
                    end)
                end

                -- Create ESP for the player
                coroutine.wrap(ESP)()
            end
        end
    else
        clearESP()  -- Disable ESP by disconnecting all connections
    end
end

-- Function to toggle the ESP from the external script
return toggleESP
