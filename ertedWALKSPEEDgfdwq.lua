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

local TpwalkConnection
RunService.Heartbeat:Connect(function()
    if getgenv().ToggleTpwalk then
        if not TpwalkConnection then
            TpwalkConnection = RunService.Heartbeat:Connect(Tpwalking)
        end
    elseif TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        playerHumanoidRootPart.CanCollide = false
    end
end)

function ToggleWalkspeed(State)
    getgenv().ToggleTpwalk = State
    if State then
        TpwalkConnection = RunService.Heartbeat:Connect(Tpwalking)
    elseif TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        playerHumanoidRootPart.CanCollide = false
    end
end
