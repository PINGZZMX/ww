-- Distance ESP Script (DistanceESP.lua)

local c = workspace.CurrentCamera
local ps = game:GetService("Players")
local lp = ps.LocalPlayer
local rs = game:GetService("RunService")

local activeESP = false  -- Flag to track if the ESP is active or not
local espObjects = {}  -- Table to store ESP objects

local function getdistancefc(part)
    return (part.Position - c.CFrame.Position).Magnitude
end

local function esp(p, cr)
    -- Prevent adding multiple ESPs for the same player
    if espObjects[p.Name] then return end

    local h = cr:WaitForChild("Humanoid")
    local hrp = cr:WaitForChild("HumanoidRootPart")

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Font = 2
    text.Color = Color3.fromRGB(173, 216, 230)
    text.Transparency = 0.9
    text.Size = 13

    -- Add a RenderStepped listener
    local c1
    c1 = rs.RenderStepped:Connect(function()
        local hrp_pos, hrp_os = c:WorldToViewportPoint(hrp.Position)
        if hrp_os then
            text.Position = Vector2.new(hrp_pos.X, hrp_pos.Y - 50)  -- Adjust Y position to make text appear above head
            text.Text = string.format("[%.1f]", getdistancefc(hrp))
            text.Visible = true
        else
            text.Visible = false
        end
    end)

    -- Track health change to remove ESP when the player dies
    local c2
    c2 = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then
            dc(p)
        end
    end)

    -- Track character removal to remove ESP when the character is removed
    local c3
    c3 = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then
            dc(p)
        end
    end)

    -- Store ESP elements for cleanup later
    espObjects[p.Name] = {text, c1, c2, c3}
end

-- Function to remove ESP for a player
local function dc(p)
    local espData = espObjects[p.Name]
    if espData then
        espData[1]:Remove()  -- Remove the drawing
        if espData[2] then espData[2]:Disconnect() end  -- Disconnect RenderStepped
        if espData[3] then espData[3]:Disconnect() end  -- Disconnect HealthChanged
        if espData[4] then espData[4]:Disconnect() end  -- Disconnect AncestryChanged
        espObjects[p.Name] = nil  -- Remove from the list
    end
end

-- Enable/Disable ESP
local function ToggleDistanceESP(state)
    activeESP = state
    if activeESP then
        -- Enable ESP for all players
        for _, p in pairs(ps:GetPlayers()) do
            if p ~= lp then
                p.CharacterAdded:Connect(function(cr)
                    esp(p, cr)
                end)
                if p.Character then
                    esp(p, p.Character)
                end
            end
        end
    else
        -- Disable ESP for all players
        for _, p in pairs(ps:GetPlayers()) do
            if p ~= lp then
                dc(p)
            end
        end
    end
end

-- Return the toggle function for use in the main script
return ToggleDistanceESP
