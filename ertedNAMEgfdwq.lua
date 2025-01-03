-- Name ESP Script (NameESP.lua)

local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.fromRGB(100, 100, 100)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)
local Tag = Instance.new("TextLabel", NameTag)
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 20)
Tag.TextSize = 15
Tag.TextColor3 = Color3.fromRGB(255, 255, 255)
Tag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Tag.TextStrokeTransparency = 1
Tag.Text = "nil"
Tag.Font = Enum.Font.SourceSansBold
Tag.TextScaled = false
Tag.TextTransparency = 0

local localPlayerName = game:GetService("Players").LocalPlayer.Name

local LoadCharacter = function(v)
    if v.Name == localPlayerName then return end

    repeat wait() until v.Character ~= nil
    v.Character:WaitForChild("Humanoid")
    local vHolder = Holder:FindFirstChild(v.Name)
    vHolder:ClearAllChildren()
    local b = Box:Clone()
    b.Name = v.Name .. "Box"
    b.Adornee = v.Character
    b.Parent = vHolder
    local t = NameTag:Clone()
    t.Name = v.Name .. "NameTag"
    t.Enabled = true
    t.Parent = vHolder
    t.Adornee = v.Character:WaitForChild("Head", 5)

    if not t.Adornee then
        return UnloadCharacter(v)
    end

    t.Tag.Text = v.Name
    b.Color3 = Color3.fromRGB(255, 255, 255)
    t.Tag.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Update
    local UpdateNameTag = function()
        if not pcall(function()
            v.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            local maxh = math.floor(v.Character.Humanoid.MaxHealth)
            local h = math.floor(v.Character.Humanoid.Health)
        end) then
            Update:Disconnect()
        end
    end
    UpdateNameTag()
    Update = v.Character.Humanoid.Changed:Connect(UpdateNameTag)
end

local UnloadCharacter = function(v)
    local vHolder = Holder:FindFirstChild(v.Name)
    if vHolder and (vHolder:FindFirstChild(v.Name .. "Box") ~= nil or vHolder:FindFirstChild(v.Name .. "NameTag") ~= nil) then
        vHolder:ClearAllChildren()
    end
end

local LoadPlayer = function(v)
    local vHolder = Instance.new("Folder", Holder)
    vHolder.Name = v.Name
    v.CharacterAdded:Connect(function()
        pcall(LoadCharacter, v)
    end)
    v.CharacterRemoving:Connect(function()
        pcall(UnloadCharacter, v)
    end)
    v.Changed:Connect(function(prop)
        if prop == "TeamColor" then
            UnloadCharacter(v)
            wait()
            LoadCharacter(v)
        end
    end)
    LoadCharacter(v)
end

local UnloadPlayer = function(v)
    UnloadCharacter(v)
    local vHolder = Holder:FindFirstChild(v.Name)
    if vHolder then
        vHolder:Destroy()
    end
end

local NameESPToggled = false

local toggleNameESP = function()
    NameESPToggled = not NameESPToggled

    if NameESPToggled then
        for i, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Name ~= localPlayerName then
                spawn(function() pcall(LoadPlayer, v) end)
            end
        end

        game:GetService("Players").PlayerAdded:Connect(function(v)
            if v.Name ~= localPlayerName then
                pcall(LoadPlayer, v)
            end
        end)

        game:GetService("Players").PlayerRemoving:Connect(function(v)
            if v.Name ~= localPlayerName then
                pcall(UnloadPlayer, v)
            end
        end)

        game:GetService("Players").LocalPlayer.NameDisplayDistance = 0
    else
        for i, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Name ~= localPlayerName then
                pcall(UnloadPlayer, v)
            end
        end

        game:GetService("Players").PlayerAdded:Connect(function(v)
            if v.Name ~= localPlayerName then
                pcall(UnloadPlayer, v)
            end
        end)

        game:GetService("Players").PlayerRemoving:Connect(function(v)
            if v.Name ~= localPlayerName then
                pcall(UnloadPlayer, v)
            end
        end)
    end
end

return toggleNameESP
