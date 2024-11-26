-- Name ESP Module (Refactored)
getgenv().Pinguin = getgenv().Pinguin or {}
getgenv().Pinguin.NameESPSettings = getgenv().Pinguin.NameESPSettings or {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.5,
    TextSize = 15
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local playerTags = {}

local function AddNameTag(Player)
    if Player == LocalPlayer then return end

    local folder = Instance.new("Folder", Holder)
    folder.Name = Player.Name

    local tagGui = Instance.new("BillboardGui", folder)
    tagGui.Name = Player.Name .. "NameTag"
    tagGui.Size = UDim2.new(0, 200, 0, 50)
    tagGui.AlwaysOnTop = true
    tagGui.StudsOffset = Vector3.new(0, 1.8, 0)

    local tagLabel = Instance.new("TextLabel", tagGui)
    tagLabel.Size = UDim2.new(1, 0, 1, 0)
    tagLabel.BackgroundTransparency = 1
    tagLabel.TextColor3 = getgenv().Pinguin.NameESPSettings.Color
    tagLabel.TextTransparency = getgenv().Pinguin.NameESPSettings.Transparency
    tagLabel.Text = Player.Name
    tagLabel.TextSize = getgenv().Pinguin.NameESPSettings.TextSize
    tagLabel.Font = Enum.Font.SourceSansBold

    playerTags[Player.UserId] = { gui = tagGui }
end

local function RemoveNameTag(Player)
    local tagData = playerTags[Player.UserId]
    if tagData and tagData.gui then
        tagData.gui:Destroy()
        playerTags[Player.UserId] = nil
    end
end

local function UpdateAllTags()
    for _, data in pairs(playerTags) do
        if data.gui then
            data.gui:FindFirstChildOfClass("TextLabel").TextColor3 = getgenv().Pinguin.NameESPSettings.Color
            data.gui:FindFirstChildOfClass("TextLabel").TextTransparency = getgenv().Pinguin.NameESPSettings.Transparency
        end
    end
end

return {
    ToggleNameESP = function(state)
        getgenv().Pinguin.NameESPSettings.Enabled = state

        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                AddNameTag(player)
            end
            Players.PlayerAdded:Connect(AddNameTag)
            Players.PlayerRemoving:Connect(RemoveNameTag)
        else
            for _, data in pairs(playerTags) do
                if data.gui then
                    data.gui:Destroy()
                end
            end
            playerTags = {}
        end
    end,
    UpdateSettings = UpdateAllTags
}
