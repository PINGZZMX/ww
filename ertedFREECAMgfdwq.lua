local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 70

local freecamActive = false

local function UpdateCamera()
    if not freecamActive then return end
    Camera.CFrame = CFrame.new(cameraPos) * CFrame.fromEulerAnglesYXZ(cameraRot.x, cameraRot.y, 0)
    Camera.FieldOfView = cameraFov
end

local function StartFreecam()
    freecamActive = true
    local cameraCFrame = Camera.CFrame
    cameraRot = Vector2.new(cameraCFrame:ToEulerAnglesYXZ())
    cameraPos = cameraCFrame.Position

    RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, function()
        UpdateCamera()
    end)

    UserInputService.InputChanged:Connect(function(input)
        if freecamActive then
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                cameraRot = cameraRot + Vector2.new(input.Delta.X / 100, input.Delta.Y / 100)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                cameraPos = cameraPos + (Camera.CFrame.LookVector * 0.1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                cameraPos = cameraPos - (Camera.CFrame.LookVector * 0.1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                cameraPos = cameraPos - (Camera.CFrame.RightVector * 0.1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                cameraPos = cameraPos + (Camera.CFrame.RightVector * 0.1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                cameraPos = cameraPos + Vector3.new(0, 0.1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                cameraPos = cameraPos - Vector3.new(0, 0.1, 0)
            end
        end
    end)
end

local function StopFreecam()
    freecamActive = false
    RunService:UnbindFromRenderStep("Freecam")
end

-- Return functions to be callable
return {
    StartFreecam = StartFreecam,
    StopFreecam = StopFreecam
}
