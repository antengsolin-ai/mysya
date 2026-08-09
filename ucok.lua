--[[ INORYA XELEBOT - HP ULTIMATE (FOV SLIDER + HS RATIO + ESP RENDER) ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- VARIABEL
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
local fovCircle = nil
local joystick = nil
local joystickBG = nil
local joystickKnob = nil
local joystickActive = false
local joystickPos = Vector2.new(0,0)
local menuOffset = Vector2.new(0,0)
local isDraggingMenu = false
local dragStart = nil

-- AIMBOT SETTINGS (BISA DIATUR USER)
local FOV_RADIUS = 200
local HS_RATIO = 5 -- 1 = 100% HS, 10 = 0% HS
local AIMBOT_SMOOTH = 0.15
local aimbotTarget = nil

-- BUAT SLIDER
local fovSlider = nil
local hsSlider = nil

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
        
        if not joystick then CreateJoystick() end
        if joystick then joystick.Visible = true end
    else
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if char and char.Humanoid then
            char.Humanoid.PlatformStand = false
        end
        if joystick then joystick.Visible = false end
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

-- ==================== ESP RENDER (AUTO UPDATE PLAYER) ====================
local function RenderESP(plr)
    if not esp or not plr or plr == player then return end
    if not plr.Character then return end
    
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Cek udah ada ESP belum
    for _, data in pairs(espData) do
        if data.plr == plr then return end
    end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 2)
    box.Color3 = Color3.fromRGB(255, 50, 50)
    box.Adornee = root
    box.Parent = plr.Character
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.2
    
    local linePart = Instance.new("Part")
    linePart.Size = Vector3.new(0.1, 0.1, 1)
    linePart.BrickColor = BrickColor.new("Bright blue")
    linePart.Material = Enum.Material.Neon
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Parent = plr.Character
    
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

local function ClearESP()
    for _, data in pairs(espData) do
        if data.box then data.box:Destroy() end
        if data.line then data.line:Destroy() end
        if data.tag then data.tag:Destroy() end
        if data.part then data.part:Destroy() end
    end
    espData = {}
end

local function toggleESP(state)
    ClearESP()
    if not state then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        RenderESP(plr)
    end
end

-- Auto ESP buat player baru
players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(0.5)
        if esp then RenderESP(plr) end
    end)
end)

-- Update ESP setiap frame
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

-- ==================== JOYSTICK FLY HP ====================
local function CreateJoystick()
    local sgJoy = Instance.new("ScreenGui")
    sgJoy.Name = "JoystickFly"
    sgJoy.Parent = game.CoreGui
    sgJoy.ResetOnSpawn = false

    joystickBG = Instance.new("ImageLabel")
    joystickBG.Size = UDim2.new(0, 120, 0, 120)
    joystickBG.Position = UDim2.new(0.1, 0, 0.8, 0)
    joystickBG.BackgroundColor3 = Color3.fromRGB(255,255,255)
    joystickBG.BackgroundTransparency = 0.8
    joystickBG.Image = "rbxassetid://3570695787"
    joystickBG.Parent = sgJoy
    joystickBG.Active = true

    joystickKnob = Instance.new("ImageLabel")
    joystickKnob.Size = UDim2.new(0, 50, 0, 50)
    joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
    joystickKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    joystickKnob.BackgroundTransparency = 0.5
    joystickKnob.Image = "rbxassetid://3570695787"
    joystickKnob.Parent = joystickBG

    joystick = sgJoy

    local dragging = false
    local startPos = nil
    local knobStart = nil

    joystickBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            knobStart = joystickKnob.Position
        end
    end)

    joystickBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
            joystickPos = Vector2.new(0,0)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startPos
            local maxDist = 40
            local dist = math.min(delta.Magnitude, maxDist)
            local angle = math.atan2(delta.Y, delta.X)
            
            local offsetX = math.cos(angle) * dist
            local offsetY = math.sin(angle) * dist
            
            joystickKnob.Position = UDim2.new(0.5, -25 + offsetX, 0.5, -25 + offsetY)
            joystickPos = Vector2.new(
                math.clamp(delta.X / maxDist, -1, 1),
                math.clamp(delta.Y / maxDist, -1, 1)
            )
        end
    end)
end

-- ==================== AIMBOT ====================
local function GetClosestTarget()
    if not char or not char.HumanoidRootPart then return nil end
    
    local origin = char.HumanoidRootPart.Position
    local closest = nil
    local minDist = FOV_RADIUS
    
    for _, data in pairs(espData) do
        if data.plr and data.plr.Character then
            local root = data.plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist3D = (root.Position - origin).Magnitude
                if dist3D > 500 then continue end
                
                local screenPos, onScreen = camera:WorldToScreenPoint(root.Position)
                if not onScreen then continue end
                
                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                
                if dist2D < minDist then
                    -- Hitung HS Ratio (1 = 100% headshot, 10 = 0%)
                    local hsChance = (11 - HS_RATIO) / 10 * 100
                    local isHeadshot = math.random(1, 100) <= hsChance
                    
                    if isHeadshot then
                        -- Target ke kepala
                        local head = data.plr.Character:FindFirstChild("Head")
                        if head then
                            minDist = dist2D
                            closest = head
                        end
                    else
                        minDist = dist2D
                        closest = root
                    end
                end
            end
        end
    end
    
    return closest
end

-- Aimbot loop
runService.Heartbeat:Connect(function()
    if aimbot and char and char.HumanoidRootPart then
        local target = GetClosestTarget()
        if target then
            local screenPos, onScreen = camera:WorldToScreenPoint(target.Position)
            if onScreen then
                local currentPos = uis:GetMouseLocation()
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local delta = (targetPos - currentPos) * AIMBOT_SMOOTH
                mouse.Move(targetPos)
            end
        end
    end
end)

-- FOV Circle
local function CreateFOV()
    if fovCircle then fovCircle:Destroy() end
    if not aimbot then return end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Radius = FOV_RADIUS
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(0, 255, 0)
    fovCircle.Filled = false
    fovCircle.Visible = true
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Parent = camera
end

runService.RenderStepped:Connect(function()
    if aimbot and fovCircle then
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        fovCircle.Visible = true
    elseif fovCircle then
        fovCircle.Visible = false
    end
end)

local function toggleAimbot(state)
    aimbot = state
    if state then
        CreateFOV()
    else
        if fovCircle then fovCircle:Destroy(); fovCircle = nil end
    end
end

-- ==================== MENU HP + MOVE + SLIDER ====================
local function CreateMenu()
    sg = Instance.new("ScreenGui")
    sg.Name = "InoryaX"
    sg.Parent = game.CoreGui
    sg.ResetOnSpawn = false

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = sg

    -- Title bar (buat move)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar

    -- Tombol panah buat mindahin menu
    local moveUp = Instance.new("TextButton")
    moveUp.Size = UDim2.new(0, 25, 1, 0)
    moveUp.Position = UDim2.new(1, -90, 0, 0)
    moveUp.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moveUp.Text = "▲"
    moveUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    moveUp.Font = Enum.Font.GothamBold
    moveUp.TextSize = 14
    moveUp.Parent = titleBar
    moveUp.MouseButton1Click:Connect(function()
        mainFrame.Position = mainFrame.Position - UDim2.new(0, 0, 0, 10)
    end)

    local moveDown = Instance.new("TextButton")
    moveDown.Size = UDim2.new(0, 25, 1, 0)
    moveDown.Position = UDim2.new(1, -60, 0, 0)
    moveDown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moveDown.Text = "▼"
    moveDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    moveDown.Font = Enum.Font.GothamBold
    moveDown.TextSize = 14
    moveDown.Parent = titleBar
    moveDown.MouseButton1Click:Connect(function()
        mainFrame.Position = mainFrame.Position + UDim2.new(0, 0, 0, 10)
    end)

    local moveLeft = Instance.new("TextButton")
    moveLeft.Size = UDim2.new(0, 25, 1, 0)
    moveLeft.Position = UDim2.new(1, -120, 0, 0)
    moveLeft.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moveLeft.Text = "◄"
    moveLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
    moveLeft.Font = Enum.Font.GothamBold
    moveLeft.TextSize = 14
    moveLeft.Parent = titleBar
    moveLeft.MouseButton1Click:Connect(function()
        mainFrame.Position = mainFrame.Position - UDim2.new(0, 10, 0, 0)
    end)

    local moveRight = Instance.new("TextButton")
    moveRight.Size = UDim2.new(0, 25, 1, 0)
    moveRight.Position = UDim2.new(1, -30, 0, 0)
    moveRight.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moveRight.Text = "►"
    moveRight.TextColor3 = Color3.fromRGB(255, 255, 255)
    moveRight.Font = Enum.Font.GothamBold
    moveRight.TextSize = 14
    moveRight.Parent = titleBar
    moveRight.MouseButton1Click:Connect(function()
        mainFrame.Position = mainFrame.Position + UDim2.new(0, 10, 0, 0)
    end)

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
        if fovCircle then fovCircle:Destroy(); fovCircle = nil end
        if joystick then joystick:Destroy(); joystick = nil end
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
            mainFrame.Size = UDim2.new(0, 300, 0, 30)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= titleBar then
                    child.Visible = false
                end
            end
            minBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 500)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= titleBar then
                    child.Visible = true
                end
            end
            minBtn.Text = "_"
        end
    end)

    -- Toggle buttons
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
        b.Position = UDim2.new(0.075, 0, 0.06 + (i-1)*0.11, 0)
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
                toggleAimbot(aimbot)
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
    speedLabel.Position = UDim2.new(0.075, 0, 0.65, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    speedLabel.Text = "Speed: 16"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 13
    speedLabel.Parent = mainFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.35, 0, 0, 25)
    speedBox.Position = UDim2.new(0.5, 0, 0.65, 0)
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

    -- FOV SLIDER
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0.4, 0, 0, 25)
    fovLabel.Position = UDim2.new(0.075, 0, 0.75, 0)
    fovLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    fovLabel.Text = "FOV: 200"
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.TextSize = 13
    fovLabel.Parent = mainFrame

    fovSlider = Instance.new("TextBox")
    fovSlider.Size = UDim2.new(0.35, 0, 0, 25)
    fovSlider.Position = UDim2.new(0.5, 0, 0.75, 0)
    fovSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    fovSlider.Text = "200"
    fovSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovSlider.Font = Enum.Font.GothamBold
    fovSlider.TextSize = 13
    fovSlider.Parent = mainFrame
    fovSlider.FocusLost:Connect(function()
        local val = tonumber(fovSlider.Text)
        if val and val > 0 then
            FOV_RADIUS = val
            fovLabel.Text = "FOV: " .. val
            if aimbot then CreateFOV() end
        end
    end)

    -- HS RATIO SLIDER
    local hsLabel = Instance.new("TextLabel")
    hsLabel.Size = UDim2.new(0.4, 0, 0, 25)
    hsLabel.Position = UDim2.new(0.075, 0, 0.83, 0)
    hsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    hsLabel.Text = "HS Ratio: 5"
    hsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hsLabel.Font = Enum.Font.GothamBold
    hsLabel.TextSize = 13
    hsLabel.Parent = mainFrame

    hsSlider = Instance.new("TextBox")
    hsSlider.Size = UDim2.new(0.35, 0, 0, 25)
    hsSlider.Position = UDim2.new(0.5, 0, 0.83, 0)
    hsSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    hsSlider.Text = "5"
    hsSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    hsSlider.Font = Enum.Font.GothamBold
    hsSlider.TextSize = 13
    hsSlider.Parent = mainFrame
    hsSlider.FocusLost:Connect(function()
        local val = tonumber(hsSlider.Text)
        if val and val >= 1 and val <= 10 then
            HS_RATIO = val
            hsLabel.Text = "HS Ratio: " .. val
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

        if fly and bodyVel and bodyGyro and joystick then
            local moveDir = Vector3.new()
            local speed = 60
            local forward = char.HumanoidRootPart.CFrame.LookVector
            local right = char.HumanoidRootPart.CFrame.RightVector
            
            local joyX = joystickPos.X
            local joyY = joystickPos.Y
            
            if math.abs(joyX) > 0.1 or math.abs(joyY) > 0.1 then
                moveDir = moveDir + forward * joyY * speed
                moveDir = moveDir + right * joyX * speed
            end
            
            -- Naik/turun pake tap layar (space/shift)
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
print("✅ INORYA XELEBOT - HP ULTIMATE READY!")
