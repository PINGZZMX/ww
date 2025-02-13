-- Visuals (WALKSPEED) (ertedWALKSPEEDgfdwq.lua) (PinguinDEV)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local playerCharacter, playerHumanoid, playerHumanoidRootPart

local function updateCharacterReferences()
    playerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    playerHumanoid = playerCharacter:WaitForChild("Humanoid")
    playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")
end

updateCharacterReferences()

LocalPlayer.CharacterAdded:Connect(function()
    updateCharacterReferences()
end)

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.TpwalkValue = 16
getgenv().Pinguin.ToggleTpwalk = false

local function TPWalkMode()
    return playerHumanoid.MoveDirection
end

local function Tpwalking()
    local TpwalkValuefunc = getgenv().Pinguin.TpwalkValue / 100
    if getgenv().Pinguin.ToggleTpwalk and playerCharacter and playerHumanoid and playerHumanoidRootPart then
        playerHumanoidRootPart.CFrame += (TPWalkMode() * TpwalkValuefunc)
        playerHumanoidRootPart.CanCollide = true
    end
end

local TpwalkConnection

RunService.Heartbeat:Connect(function()
    if getgenv().Pinguin.ToggleTpwalk then
        if not TpwalkConnection then
            TpwalkConnection = RunService.Heartbeat:Connect(Tpwalking)
        end
    elseif TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        playerHumanoidRootPart.CanCollide = false
    end
end)

return {
    ToggleWalkspeed = function(State)
        getgenv().Pinguin.ToggleTpwalk = State
    end,
    SetWalkspeed = function(Value)
        getgenv().Pinguin.TpwalkValue = Value
    end,
}
