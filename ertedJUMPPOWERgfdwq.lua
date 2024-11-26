local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerCharacter
local playerHumanoid

local function setupCharacter()
    if LocalPlayer.Character then
        playerCharacter = LocalPlayer.Character
    else
        playerCharacter = LocalPlayer.CharacterAdded:Wait()
    end
    playerHumanoid = playerCharacter:WaitForChild("Humanoid")
end

setupCharacter()

LocalPlayer.CharacterAdded:Connect(function()
    setupCharacter()
    if getgenv().ToggleJumpPower and playerHumanoid then
        playerHumanoid.UseJumpPower = true
        playerHumanoid.JumpPower = getgenv().JumpPowerValue or 50
    end
end)

getgenv().ToggleJumpPower = false
getgenv().JumpPowerValue = 50
