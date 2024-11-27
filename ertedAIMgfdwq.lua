-- aimbot.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Vector2new = Vector2.new

local Environment = getgenv().PinguinDeveloperAimbot or {}

local possibleHitParts = {
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "Head"
}

local function RandomizeLockPart()
    if Environment.Settings.LockPart == "Randomization" then
        return possibleHitParts[math.random(1, #possibleHitParts)]
    else
        return Environment.Settings.LockPart
    end
end

local function IsInFOV(player)
    local targetPart = player.Character and player.Character:FindFirstChild(RandomizeLockPart())
    if not targetPart then return false end

    local screenPoint = Camera:WorldToViewportPoint(targetPart.Position)
    local distance = (Vector2new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
    return distance <= Environment.FOVCircle.Radius
end

local function IsVisible(part)
    if not Environment.Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Camera, Players.LocalPlayer.Character}

    local result = workspace:Raycast(origin, direction, raycastParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestPlayer()
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

local function LockTarget(player)
    if player and player.Character then
        Environment.Locked = player
    else
        Environment.Locked = nil
    end
end

RunService.RenderStepped:Connect(function()
    if Environment.Locked and Environment.Settings.Enabled then
        local targetPart = Environment.Locked.Character and Environment.Locked.Character:FindFirstChild(RandomizeLockPart())
        if targetPart then
            local targetPosition = targetPart.Position
            local playerVelocity = Environment.Locked.Character:FindFirstChild("HumanoidRootPart") and Environment.Locked.Character.HumanoidRootPart.Velocity or Vector3.zero
            targetPosition = targetPosition + playerVelocity * Environment.Settings.Prediction
            if Environment.Settings.AimMethod == "MouseMoveRel (LEGIT)" then
                local currentMousePos = UserInputService:GetMouseLocation()
                local targetScreenPos = Camera:WorldToViewportPoint(targetPosition)
                local deltaX = (targetScreenPos.X - currentMousePos.X) * Environment.Settings.ThirdPersonSensitivity
                local deltaY = (targetScreenPos.Y - currentMousePos.Y) * Environment.Settings.ThirdPersonSensitivity
                mousemoverel(deltaX, deltaY)
            elseif Environment.Settings.AimMethod == "CFrame (RISKY)" then
                Camera.CFrame = CFramenew(Camera.CFrame.Position, targetPosition)
            end
            Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
        else
            Environment.Locked = nil
        end
    else
        Environment.FOVCircle.Color = Environment.FOVSettings.Color
    end
end)

return {LockTarget = LockTarget, GetClosestPlayer = GetClosestPlayer}
