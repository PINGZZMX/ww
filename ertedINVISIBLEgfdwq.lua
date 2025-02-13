-- Visuals (INVISIBLE) (ertedINVISIBLEgfdwq.lua) (PinguinDEV)
local function setupInvisibility()
    local Keybind = "K"
    local Transparency = true
    local Player = game:GetService("Players").LocalPlayer
    local RealCharacter = Player.Character or Player.CharacterAdded:Wait()
    local IsInvisible = false
    RealCharacter.Archivable = true
    local FakeCharacter = RealCharacter:Clone()
    
    local Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(7, 1, 7)
    Part.CFrame = CFrame.new(1653.3216552734375, -16.953155517578125, -529.6856079101562)
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
    
    for _, v in pairs(RealCharacter:GetChildren()) do
        if v:IsA("LocalScript") then
            local clone = v:Clone()
            clone.Disabled = true
            clone.Parent = FakeCharacter
        end
    end

    if Transparency then
        for _, v in pairs(FakeCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0.8
            end
        end
    end

    local CanInvis = true

    local function RealCharacterDied()
        CanInvis = false
        RealCharacter:Destroy()
        RealCharacter = Player.Character
        CanInvis = true
        IsInvisible = false
        FakeCharacter:Destroy()
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
        RealCharacter.Archivable = true
        FakeCharacter = RealCharacter:Clone()
        Part:Destroy()
        Part = Instance.new("Part", workspace)
        Part.Anchored = true
        Part.Size = Vector3.new(7, 1, 7)
        Part.CFrame = CFrame.new(1653.3216552734375, -16.953155517578125, -529.6856079101562)
        Part.CanCollide = true
        FakeCharacter.Parent = workspace
        FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
        for _, v in pairs(RealCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                local clone = v:Clone()
                clone.Disabled = true
                clone.Parent = FakeCharacter
            end
        end
        if Transparency then
            for _, v in pairs(FakeCharacter:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 0.7
                end
            end
        end
    end

    RealCharacter.Humanoid.Died:Connect(RealCharacterDied)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)

    local PseudoAnchor = FakeCharacter.HumanoidRootPart
    game:GetService("RunService").RenderStepped:Connect(function()
        if PseudoAnchor then
            PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
        end
    end)

    local function Invisible()
        if not IsInvisible then
            local StoredCF = RealCharacter.HumanoidRootPart.CFrame
            RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
            FakeCharacter.HumanoidRootPart.CFrame = StoredCF
            RealCharacter.Humanoid:UnequipTools()
            Player.Character = FakeCharacter
            workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
            PseudoAnchor = RealCharacter.HumanoidRootPart
            for _, v in pairs(FakeCharacter:GetChildren()) do
                if v:IsA("LocalScript") then
                    v.Disabled = false
                end
            end
            IsInvisible = true
        else
            local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
            FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
            RealCharacter.HumanoidRootPart.CFrame = StoredCF
            FakeCharacter.Humanoid:UnequipTools()
            Player.Character = RealCharacter
            workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
            PseudoAnchor = FakeCharacter.HumanoidRootPart
            for _, v in pairs(FakeCharacter:GetChildren()) do
                if v:IsA("LocalScript") then
                    v.Disabled = true
                end
            end
            IsInvisible = false
        end
    end

    game:GetService("UserInputService").InputBegan:Connect(function(key, gameProcessed)
        if gameProcessed then return end
        if key.KeyCode.Name:lower() == Keybind:lower() and CanInvis and RealCharacter and FakeCharacter then
            if RealCharacter:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("HumanoidRootPart") then
                Invisible()
            end
        end
    end)
end

return setupInvisibility
