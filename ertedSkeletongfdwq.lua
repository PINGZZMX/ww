local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local skeletons = {}

getgenv().PinguinDeveloperSkeleton = {
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Thickness = 1,
}

local function createSkeleton(player)
    if player ~= Players.LocalPlayer then
        skeletons[player] = {}
        local bones = {
            "RightUpperLeg", "RightLowerLeg", "RightFoot",
            "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
            "UpperTorso", "LowerTorso", "HumanoidRootPart",
            "LeftUpperArm", "LeftLowerArm", "LeftHand",
            "RightUpperArm", "RightLowerArm", "RightHand",
            "Head"
        }
        for _, _ in pairs(bones) do
            local line = Drawing.new("Line")
            line.Thickness = getgenv().PinguinDeveloperSkeleton.Thickness
            line.Color = getgenv().PinguinDeveloperSkeleton.Color
            line.Transparency = getgenv().PinguinDeveloperSkeleton.Transparency
            line.Visible = false
            table.insert(skeletons[player], line)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        createSkeleton(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createSkeleton(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if skeletons[player] then
        for _, line in ipairs(skeletons[player]) do
            line:Remove()
        end
        skeletons[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for player, lines in pairs(skeletons) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local function getPartPosition(partName)
                local part = char:FindFirstChild(partName)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    return screenPos, onScreen
                end
                return nil, false
            end

            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local rootScreenPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if not rootOnScreen then
                    for _, line in ipairs(lines) do
                        line.Visible = false
                    end
                    continue
                end
            end

            local connections = {
                {"RightFoot", "RightLowerLeg"}, {"RightLowerLeg", "RightUpperLeg"}, {"RightUpperLeg", "LowerTorso"},
                {"LeftFoot", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftUpperLeg"}, {"LeftUpperLeg", "LowerTorso"},
                {"LowerTorso", "UpperTorso"}, {"UpperTorso", "Head"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}
            }

            for i, connection in ipairs(connections) do
                local part1, part2 = connection[1], connection[2]
                local pos1, onScreen1 = getPartPosition(part1)
                local pos2, onScreen2 = getPartPosition(part2)

                local line = lines[i]
                if pos1 and pos2 and onScreen1 and onScreen2 then
                    line.From = Vector2.new(pos1.X, pos1.Y)
                    line.To = Vector2.new(pos2.X, pos2.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(lines) do
                line.Visible = false
            end
        end
    end
end)
