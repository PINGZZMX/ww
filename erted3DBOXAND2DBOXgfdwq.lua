-- Global environment for storing settings and states
getgenv().PinguinHub = getgenv().PinguinHub or {}
getgenv().PinguinHub.WallHack = getgenv().PinguinHub.WallHack or {}
getgenv().PinguinHub.WallHack.Settings = getgenv().PinguinHub.WallHack.Settings or { BoxSettings = {} }
getgenv().PinguinHub.WallHack.WrappedPlayers = getgenv().PinguinHub.WallHack.WrappedPlayers or {}

-- Default Box settings
getgenv().PinguinHub.WallHack.Settings.BoxSettings.Color = Color3.fromRGB(255, 255, 255)
getgenv().PinguinHub.WallHack.Settings.BoxSettings.Type = "2D Boxes"  -- Default set to 2D boxes
getgenv().PinguinHub.WallHack.Settings.BoxSettings.IsEnabled = false

-- Services
local camera = game:GetService("Workspace").CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local runService = game:GetService("RunService")

-- Drawing objects for ESP
local boxConnections = {}  -- Store connections to stop render loops
local line = Drawing.new("Line")  -- Example of a drawing object for lines

-- Function to clear existing ESP and stop 3D box rendering
local function clearESP()
    for _, connection in pairs(boxConnections) do
        connection:Disconnect()
    end
    boxConnections = {}
    getgenv().PinguinHub.WallHack.WrappedPlayers = {}
end

-- Function to draw 2D boxes (screen space)
local function draw2DBox(player)
    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = getgenv().PinguinHub.WallHack.Settings.BoxSettings.Color
    box.Thickness = 2
    box.Transparency = 1
    -- Define the position and size of the box
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local pos = camera:WorldToViewportPoint(humanoidRootPart.Position)
        box.Position = Vector2.new(pos.X - 50, pos.Y - 50)  -- Example positioning
        box.Size = Vector2.new(100, 200)  -- Example size
    end
    getgenv().PinguinHub.WallHack.WrappedPlayers[player.Name] = box
end

-- Function to draw 3D boxes (world space)
local function draw3DBox(player)
    local box = Drawing.new("Line")
    box.Visible = true
    box.Color = getgenv().PinguinHub.WallHack.Settings.BoxSettings.Color
    box.Thickness = 2
    box.Transparency = 1
    -- Similar to 2D, but with 3D world space handling
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local pos1 = camera:WorldToViewportPoint(humanoidRootPart.Position)
        local pos2 = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(1, 0, 0))  -- Simple line for demonstration
        box.From = Vector2.new(pos1.X, pos1.Y)
        box.To = Vector2.new(pos2.X, pos2.Y)
    end
    getgenv().PinguinHub.WallHack.WrappedPlayers[player.Name] = box
end

-- Toggle function for Boxes (2D and 3D)
local function toggleESP(state, boxType)
    getgenv().PinguinHub.WallHack.Settings.BoxSettings.IsEnabled = state
    getgenv().PinguinHub.WallHack.Settings.BoxSettings.Type = boxType

    clearESP()  -- Clear existing ESP and connections

    if state then
        -- Start drawing the selected type of boxes
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if boxType == "2D Boxes" then
                    draw2DBox(player)
                elseif boxType == "3D Boxes" then
                    draw3DBox(player)
                end
            end
        end
    end
end

-- Connect to player addition for dynamic ESP
Players.PlayerAdded:Connect(function(player)
    if getgenv().PinguinHub.WallHack.Settings.BoxSettings.IsEnabled then
        if getgenv().PinguinHub.WallHack.Settings.BoxSettings.Type == "2D Boxes" then
            draw2DBox(player)
        elseif getgenv().PinguinHub.WallHack.Settings.BoxSettings.Type == "3D Boxes" then
            draw3DBox(player)
        end
    end
end)

-- Clear ESP when player leaves
Players.PlayerRemoving:Connect(function(player)
    clearESP()
end)

-- Dropdown logic for selecting box types (2D or 3D)
local function createBoxTypeDropdown()
    -- Dropdown implementation to select 2D or 3D boxes
    return {
        Name = "Box Type",
        Options = {"2D Boxes", "3D Boxes"},
        Default = "2D Boxes",
        Callback = function(selectedOption)
            toggleESP(getgenv().PinguinHub.WallHack.Settings.BoxSettings.IsEnabled, selectedOption)
        end
    }
end

-- Return the dropdown function for use in the main UI script
return createBoxTypeDropdown
