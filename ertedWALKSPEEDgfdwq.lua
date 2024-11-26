getgenv().TPWalkMode = function()
    if getgenv().seltpwallkmode == nil then
        return playerHumanoid.MoveDirection
    else
        if getgenv().seltpwallkmode ~= nil then
            return getgenv().seltpwallkmode()
        end
    end
end

function Tpwalking()
    TpwalkValuefunc = getgenv().TpwalkValue or 3.5
    if getgenv().ToggleTpwalk and playerCharacter and playerHumanoid and playerHumanoidRootPart then
        playerHumanoidRootPart.CFrame += (getgenv().TPWalkMode() * TpwalkValuefunc)
        playerHumanoidRootPart.CanCollide = true
    end
end

local tpwalkmodes = {
    ["Camera LookVector"] = function()
        re = game:GetService("Workspace").Camera.CFrame.LookVector
        return re
    end,
    ["MoveDirection"] = function()
        return playerHumanoid.MoveDirection
    end,
}

Callback = function(Value)
    getgenv().ToggleTpwalk = Value
    ToggleTpwalk = not ToggleTpwalk
    if getgenv().ToggleTpwalk and not TpwalkConnection then
        TpwalkConnection = RunService.Heartbeat:Connect(Tpwalking)
    elseif not getgenv().ToggleTpwalk and TpwalkConnection then
        TpwalkConnection:Disconnect()
        TpwalkConnection = nil
        playerHumanoidRootPart.CanCollide = false
    end
end
