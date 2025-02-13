-- Visuals (WORKBENCH) (ertedWORKBENCHgfdwq.lua) (PinguinDEV)
local function setupWorkbench()
    local serverFurnitureFolder = game:GetService("Workspace").ServerFurniture
    local player = game:GetService("Players").LocalPlayer
    local playerRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local originalPositions = {}
    local followConnections = {}

    local function storeOriginalPositions()
        for _, model in pairs(serverFurnitureFolder:GetChildren()) do
            local foundCraftingStation = false
            local objectsToFollow = {}

            for _, child in pairs(model:GetDescendants()) do
                if child.Name:find("craftingstation4") then
                    foundCraftingStation = true
                    break
                end
            end

            if foundCraftingStation then
                for _, object in pairs(model:GetChildren()) do
                    if object:IsA("BasePart") then
                        table.insert(objectsToFollow, object)
                    end
                end

                if #objectsToFollow > 0 then
                    originalPositions[model] = {
                        Objects = objectsToFollow,
                        OriginalCFrames = {}
                    }

                    for _, object in pairs(objectsToFollow) do
                        originalPositions[model].OriginalCFrames[object] = object.CFrame
                    end
                end
            end
        end
    end

    local function teleportAndFollowWorkbench()
        if not getgenv().AutoWorkbench then return end
        if not playerRootPart then return end

        for model, data in pairs(originalPositions) do
            local objectsToFollow = data.Objects

            local connection
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                if not getgenv().AutoWorkbench then
                    connection:Disconnect()
                    return
                end

                local proximityPrompt = model:FindFirstChildOfClass("ProximityPrompt")
                if proximityPrompt and proximityPrompt.Enabled then
                    fireproximityprompt(proximityPrompt, 0)
                end

                local teleportPosition = playerRootPart.CFrame * CFrame.new(0, 0, -5)
                for _, object in pairs(objectsToFollow) do
                    object.CFrame = teleportPosition
                    object.Transparency = 1
                    object.CanCollide = false
                end
            end)

            table.insert(followConnections, connection)
        end
    end

    local function stopFollowingWorkbench()
        for _, connection in ipairs(followConnections) do
            connection:Disconnect()
        end
        followConnections = {}

        for model, data in pairs(originalPositions) do
            for _, object in pairs(data.Objects) do
                object.Transparency = 0
                object.CanCollide = true
                object.CFrame = data.OriginalCFrames[object]
            end
        end
        originalPositions = {}
    end

    if getgenv().AutoWorkbench then
        storeOriginalPositions()
        teleportAndFollowWorkbench()
    else
        stopFollowingWorkbench()
    end
end

return setupWorkbench
