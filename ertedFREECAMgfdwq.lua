local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 70

local function UpdateCamera()
    Camera.CFrame = CFrame.new(cameraPos) * CFrame.fromEulerAnglesYXZ(cameraRot.x, cameraRot.y, 0)
    Camera.FieldOfView = cameraFov
end

local function StartFreecam()
    local cameraCFrame = Camera.CFrame
    cameraRot = Vector2.new(cameraCFrame:ToEulerAnglesYXZ())
    cameraPos = cameraCFrame.Position

    RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, function()
        UpdateCamera()
    end)
end

local function StopFreecam()
    RunService:UnbindFromRenderStep("Freecam")
end

local Input = {} do
    function Input.Vel()
        return Vector3.new(
            UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0,
            UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0,
            UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0
        )
    end

    function Input.Pan()
        return Vector2.new(
            UserInputService:GetMouseDelta().X / 100,
            UserInputService:GetMouseDelta().Y / 100
        )
    end

    function Input.Fov()
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and 1 or 0
    end
end

local function StepFreecam()
    local vel = Input.Vel()
    local pan = Input.Pan()
    local fov = Input.Fov()

    cameraPos = cameraPos + vel
    cameraRot = cameraRot + pan
    cameraFov = cameraFov + fov
end

function Freecam()
    StartFreecam()
end

function StopFreecam()
    StopFreecam()
end
