--[[ INORYA XELEBOT - DELTA HP SIMPLE VERSION (PASTI MUNCUL) ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")

-- Variabel fitur
local fly = false
local noclip = false
local esp = false
local aimbot = false
local speedEnabled = false
local speedValue = 16
local bodyVel = nil
local bodyGyro = nil
local espData = {}
local mainFrame = nil
local sg = nil
local isMinimized = false

-- FLY
local function toggleFly(state)
    if state then
        if not char or not char.HumanoidRootPart then return end
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = char.HumanoidRootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.Parent = char.HumanoidRootPart
        bodyGyro.CFrame = char.HumanoidRootPart.CFrame
        
        char.Humanoid.PlatformStand = true
    else
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if char and char.Humanoid then
            char.Humanoid.PlatformStand = false
        end
    end
end

-- NOCLIP
local function toggleNoclip(state)
    if state then
        if char and char.HumanoidRootPart then
            char.HumanoidRootPart.CanCollide = false
        end
    else
        if char and char.HumanoidRootPart then
            char.HumanoidRootPart.CanCollide = true
        end
    end
end

-- ESP
local function toggleESP(state)
    for _, data in pairs(espData) do
        if data.box then data.box:Destroy() end
        if data.line then data.line:Destroy() end
        if data.tag then data.tag:Destroy() end
        if data.part then data.part:Destroy() end
    end
    espData = {}
    
    if not state then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- BOX
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 5, 2)
                box.Color3 = Color3.fromRGB(255, 50, 50)
                box.Adornee = root
                box.Parent = plr.Character
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.2
                
                -- LINE 3D
                local linePart = Instance.new("Part")
                linePart.Size = Vector3.new(0.1, 0.1, 1)
                linePart.BrickColor = BrickColor.new("Bright blue")
                linePart.Material = Enum.Material.Neon
                linePart.Anchored = true
                linePart.CanCollide = false
                linePart.Parent = plr.Character
                
                -- NAMA
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 80, 0, 20)
                tag.Adornee = root
                tag.Parent = plr.Character
                tag.AlwaysOnTop = true
                tag.MaxDistance = 300
                tag.StudsOffset = Vector3.new(0, 3, 0)
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name .. " ❤" .. (plr.Character.Humanoid and math.floor(plr.Character.Humanoid.Health) or "?")
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.Gotham
                label.TextSize = 10
                label.Parent = tag
                
                table.insert(espData, {
                    plr = plr,
                    box = box,
                    line = linePart,
                    tag = tag,
                    label = label,
                    root = root
                })
            end
        end
    end
end

-- UPDATE ESP
runService.Heartbeat:Connect(function()
    if esp and char and char.HumanoidRootPart then
        local origin = char.HumanoidRootPart.Position
        for _, data in pairs(espData) do
            if data.plr and data.plr.Character then
                local root = data.plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if data.plr.Character.Humanoid then
                        data.label.Text = data.plr.Name .. " ❤" .. math.floor(data.plr.Character.Humanoid.Health)
                    end
                    
                    if data.line then
                        local dist = (root.Position - origin).Magnitude
                        local midPoint = (origin + root.Position) / 2
                        data.line.Position = midPoint
                        data.line.CFrame = CFrame.lookAt(midPoint, root.Position)
                        data.line.Size = Vector3.new(0.1, 0.1, dist)
                        data.line.BrickColor = dist < 50 and BrickColor.new("Bright green") or dist < 100 and BrickColor.new("Bright yellow") or BrickColor.new("Bright red")
                    end
                end
            end
        end
    end
end)

-- AIMBOT
runService.Heartbeat:Connect(function()
    if aimbot and char and char.HumanoidRootPart then
        local closest = nil
        local minDist = 1e9
        for _, data in pairs(espData) do
            if data.plr and data.plr.Character then
                local root = data.plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = root
                    end
                end
            end
        end
        if closest then
            mouse.Hit = CFrame.new(mouse.Hit.Position, closest.Position)
        end
    end
end)

-- ==================== MENU DELTA HP (PASTI MUNCUL) ====================
local function CreateMenu()
    -- PAKE CoreGui (BIAR PASTI MUNCUL DI DELTA)
    sg = Instance.new("ScreenGui")
    sg.Name = "InoryaX"
    sg.Parent = game.CoreGui
    sg.ResetOnSpawn = false

    -- Frame utama
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = sg

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar

    -- Close
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 1, 0)
    close.Position = UDim2.new(1, -30, 0, 0)
    close.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = titleBar
    close.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    -- Minimize
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 1, 0)
    minBtn.Position = UDim2.new(1, -60, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minBtn.Text = "_"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = titleBar
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 280, 0, 30)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= titleBar then
                    child.Visible = false
                end
            end
            minBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 280, 0, 400)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= titleBar then
                    child.Visible = true
                end
            end
            minBtn.Text = "_"
        end
    end)

    -- Tombol fitur
    local toggles = {
        {name = "Fly", var = "fly"},
        {name = "NoClip", var = "noclip"},
        {name = "ESP", var = "esp"},
        {name = "Aimbot", var = "aimbot"},
        {name = "Speed", var = "speed"}
    }

    for i, btn in ipairs(toggles) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.85, 0, 0, 35)
        b.Position = UDim2.new(0.075, 0, 0.08 + (i-1)*0.13, 0)
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        b.Text = btn.name .. " [OFF]"
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Parent = mainFrame

        b.MouseButton1Click:Connect(function()
            if btn.var == "fly" then
                fly = not fly
                b.Text = fly and "Fly [ON]" or "Fly [OFF]"
                toggleFly(fly)
            elseif btn.var == "noclip" then
                noclip = not noclip
                b.Text = noclip and "NoClip [ON]" or "NoClip [OFF]"
                toggleNoclip(noclip)
            elseif btn.var == "esp" then
                esp = not esp
                b.Text = esp and "ESP [ON]" or "ESP [OFF]"
                toggleESP(esp)
            elseif btn.var == "aimbot" then
                aimbot = not aimbot
                b.Text = aimbot and "Aimbot [ON]" or "Aimbot [OFF]"
            elseif btn.var == "speed" then
                speedEnabled = not speedEnabled
                b.Text = speedEnabled and "Speed [ON]" or "Speed [OFF]"
                if char and char.Humanoid then
                    char.Humanoid.WalkSpeed = speedEnabled and speedValue or 16
                end
            end
        end)
    end

    -- Speed input
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.4, 0, 0, 25)
    speedLabel.Position = UDim2.new(0.075, 0, 0.78, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    speedLabel.Text = "Speed: 16"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 13
    speedLabel.Parent = mainFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.35, 0, 0, 25)
    speedBox.Position = UDim2.new(0.5, 0, 0.78, 0)
    speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedBox.Text = "16"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextSize = 13
    speedBox.Parent = mainFrame
    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            speedValue = val
            speedLabel.Text = "Speed: " .. val
            if speedEnabled and char and char.Humanoid then
                char.Humanoid.WalkSpeed = speedValue
            end
        end
    end)
end

-- ==================== MAIN LOOP ====================
runService.Heartbeat:Connect(function()
    if char and char.HumanoidRootPart and char.Humanoid then
        if speedEnabled then
            char.Humanoid.WalkSpeed = speedValue
        else
            char.Humanoid.WalkSpeed = 16
        end

        if fly and bodyVel and bodyGyro then
            local moveDir = Vector3.new()
            local speed = 60
            local forward = char.HumanoidRootPart.CFrame.LookVector
            local right = char.HumanoidRootPart.CFrame.RightVector
            
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward * speed end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward * speed end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right * speed end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right * speed end
            if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, speed, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, speed, 0) end
            
            bodyVel.Velocity = moveDir
            bodyGyro.CFrame = CFrame.new(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + (mouse.Hit.Position - char.HumanoidRootPart.Position))
        end
        
        if noclip then
            char.HumanoidRootPart.CanCollide = false
            char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        else
            char.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    wait(0.5)
    if noclip then toggleNoclip(true) end
    if fly then toggleFly(true) end
    if speedEnabled and char and char.Humanoid then
        char.Humanoid.WalkSpeed = speedValue
    end
    if esp then
        wait(0.5)
        toggleESP(true)
    end
end)

-- INIT
CreateMenu()
print("✅ INORYA XELEBOT - DELTA HP SIMPLE READY!")
