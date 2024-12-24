-- Distance ESP Script (DistanceESP.lua)

local c = workspace.CurrentCamera
local ps = game:GetService("Players")
local lp = ps.LocalPlayer
local rs = game:GetService("RunService")

local activeESP = false  
local espObjects = {}  

local function getdistancefc(part)
    return (part.Position - c.CFrame.Position).Magnitude
end

local function esp(p, cr)
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

    local c1
    c1 = rs.RenderStepped:Connect(function()
        local hrp_pos, hrp_os = c:WorldToViewportPoint(hrp.Position)
        if hrp_os then
            text.Position = Vector2.new(hrp_pos.X, hrp_pos.Y - 50)  
            text.Text = string.format("[%.1f]", getdistancefc(hrp))
            text.Visible = true
        else
            text.Visible = false
        end
    end)

    local c2
    c2 = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then
            dc(p)
        end
    end)

    local c3
    c3 = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then
            dc(p)
        end
    end)

    espObjects[p.Name] = {text, c1, c2, c3}
end

local function dc(p)
    local espData = espObjects[p.Name]
    if espData then
        espData[1]:Remove()  
        if espData[2] then espData[2]:Disconnect() end  
        if espData[3] then espData[3]:Disconnect() end  
        if espData[4] then espData[4]:Disconnect() end  
        espObjects[p.Name] = nil  
    end
end

local function ToggleDistanceESP(state)
    activeESP = state
    if activeESP then
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
        for _, p in pairs(ps:GetPlayers()) do
            if p ~= lp then
                dc(p)
            end
        end
    end
end

return ToggleDistanceESP
