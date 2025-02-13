-- Visuals (NAME) (ertedNAME2gfdwq.lua) (PinguinDEV)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.NameSettings = getgenv().Pinguin.NameSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255)
}

local Holder = CoreGui:FindFirstChild("NameFolder") or Instance.new("Folder", CoreGui)
Holder.Name = "NameFolder"

local nameTags = {}

local function CreateNameTag(player)
    if player == Players.LocalPlayer or not player.Character then return end

    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_NameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = getgenv().Pinguin.NameSettings.Color
    label.Text = player.Name
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14

    billboard.Parent = Holder
    nameTags[player.UserId] = billboard
end

local function RemoveNameTag(player)
    if nameTags[player.UserId] then
        nameTags[player.UserId]:Destroy()
        nameTags[player.UserId] = nil
    end
end

local function ToggleNames(state)
    getgenv().Pinguin.NameSettings.Enabled = state

    for _, player in ipairs(Players:GetPlayers()) do
        if state then
            CreateNameTag(player)
        else
            RemoveNameTag(player)
        end
    end
end

local function UpdateSettings()
    for _, tag in pairs(nameTags) do
        if tag and tag:FindFirstChildOfClass("TextLabel") then
            tag.TextLabel.TextColor3 = getgenv().Pinguin.NameSettings.Color
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if getgenv().Pinguin.NameSettings.Enabled then
        CreateNameTag(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveNameTag(player)
end)

return {
    Initialize = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if getgenv().Pinguin.NameSettings.Enabled then
                CreateNameTag(player)
            end
        end
    end,
    Toggle = ToggleNames,
    UpdateSettings = UpdateSettings
}
