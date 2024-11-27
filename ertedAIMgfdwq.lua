-- AimbotModule.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Vector2new, CFramenew, Color3fromRGB, Drawingnew = Vector2.new, CFrame.new, Color3.fromRGB, Drawing.new

local AimbotModule = {}

AimbotModule.Environment = getgenv().PinguinDeveloperAimbot or {
    Settings = {
        Enabled = false,
        LockPart = "Head",
        TriggerKey = nil,
        ThirdPerson = true,
        ThirdPersonSensitivity = 0.5,
        TeamCheck = false,
        WallCheck = false,
        Prediction = 0,
        AimMethod = "MouseMoveRel (LEGIT)"
    },
    FOVSettings = {
        Radius = 150,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 80, 80),
        Thickness = 1,
        Transparency = 0.5,
        Visible = false
    },
    Locked = nil,
    FOVCircle = Drawing.new("Circle")
}

AimbotModule.Environment.FOVCircle.Visible = AimbotModule.Environment.FOVSettings.Visible
AimbotModule.Environment.FOVCircle.Radius = AimbotModule.Environment.FOVSettings.Radius
AimbotModule.Environment.FOVCircle.Color = AimbotModule.Environment.FOVSettings.Color
AimbotModule.Environment.FOVCircle.Filled = false
AimbotModule.Environment.FOVCircle.Thickness = AimbotModule.Environment.FOVSettings.Thickness
AimbotModule.Environment.FOVCircle.Transparency = AimbotModule.Environment.FOVSettings.Transparency

local possibleHitParts = {
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "Head"
}

local function RandomizeLockPart()
    if AimbotModule.Environment.Settings.LockPart == "Randomization" then
        return possibleHitParts[math.random(1, #possibleHitParts)]
    else
        return AimbotModule.Environment.Settings.LockPart
    end
end

local function IsInFOV(player)
    local targetPart = player.Character and player.Character:FindFirstChild(RandomizeLockPart())
    if not targetPart then return false end

    local screenPoint = Camera:WorldToViewportPoint(targetPart.Position)
    local distance = (Vector2new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
    return distance <= AimbotModule.Environment.FOVCircle.Radius
end

local function IsVisible(part)
    if not AimbotModule.Environment.Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Camera, Players.LocalPlayer.Character}

    local result = workspace:Raycast(origin, direction, raycastParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

function AimbotModule.GetClosestPlayer()
    local closest, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(RandomizeLockPart())
            if targetPart and IsInFOV(player) and IsVisible(targetPart) then
                local screenPoint = Camera:WorldToViewportPoint(targetPart.Position)
                local distance = (Vector2new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < closestDistance then
                    closest, closestDistance = player, distance
                end
            end
        end
    end
    return closest
end

function AimbotModule.LockTarget(player)
    if player and player.Character then
        AimbotModule.Environment.Locked = player
    else
        AimbotModule.Environment.Locked = nil
    end
end

function AimbotModule.UpdateAimbot()
    RunService.RenderStepped:Connect(function()
        AimbotModule.Environment.FOVCircle.Position = UserInputService:GetMouseLocation()
        if AimbotModule.Environment.Locked and AimbotModule.Environment.Settings.Enabled then
            local targetPart = AimbotModule.Environment.Locked.Character and AimbotModule.Environment.Locked.Character:FindFirstChild(RandomizeLockPart())
            if targetPart then
                local targetPosition = targetPart.Position
                local playerVelocity = AimbotModule.Environment.Locked.Character:FindFirstChild("HumanoidRootPart") and AimbotModule.Environment.Locked.Character.HumanoidRootPart.Velocity or Vector3.zero
                targetPosition = targetPosition + playerVelocity * AimbotModule.Environment.Settings.Prediction
                if AimbotModule.Environment.Settings.AimMethod == "MouseMoveRel (LEGIT)" then
                    local currentMousePos = UserInputService:GetMouseLocation()
                    local targetScreenPos = Camera:WorldToViewportPoint(targetPosition)
                    local deltaX = (targetScreenPos.X - currentMousePos.X) * AimbotModule.Environment.Settings.ThirdPersonSensitivity
                    local deltaY = (targetScreenPos.Y - currentMousePos.Y) * AimbotModule.Environment.Settings.ThirdPersonSensitivity
                    mousemoverel(deltaX, deltaY)
                elseif AimbotModule.Environment.Settings.AimMethod == "CFrame (RISKY)" then
                    Camera.CFrame = CFramenew(Camera.CFrame.Position, targetPosition)
                end
                AimbotModule.Environment.FOVCircle.Color = AimbotModule.Environment.FOVSettings.LockedColor
            else
                AimbotModule.Environment.Locked = nil
            end
        else
            AimbotModule.Environment.FOVCircle.Color = AimbotModule.Environment.FOVSettings.Color
        end
    end)
end

return AimbotModule
