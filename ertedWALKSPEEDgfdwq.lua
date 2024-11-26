local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local playerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local playerHumanoid = playerCharacter:WaitForChild("Humanoid")
local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")

getgenv().TPWalkMode = function()
    if getgenv().seltpwallkmode == nil then
        return playerHumanoid.MoveDirection
    else
        return getgenv().seltpwallkmode()
    end
end

function Tpwalking()
    local TpwalkValuefunc = getgenv().TpwalkValue or 16
    if getgenv().ToggleTpwalk and playerCharacter and playerHumanoid and playerHumanoidRootPart then
        playerHumanoidRootPart.CFrame += (getgenv().TPWalkMode() * TpwalkValuefunc)
        playerHumanoidRootPart.CanCollide = true
    end
end

local tpwalkmodes = {
    ["Camera LookVector"] = function()
        return game:GetService("Workspace").Camera.CFrame.LookVector
    end,
    ["MoveDirection"] = function()
        return playerHumanoid.MoveDirection
    end,
}

-- Add toggle function for Walkspeed
function getgenv().ToggleWalkspeed(State)
    getgenv().ToggleTpwalk = State
    if State then
        TpwalkConnection = RunService.Heartbeat:Connect(Tpwalking)
    elseif TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        playerHumanoidRootPart.CanCollide = false
    end
end

-- Add a Walkspeed Slider function
function getgenv().SetWalkspeed(Value)
    getgenv().TpwalkValue = Value
end
