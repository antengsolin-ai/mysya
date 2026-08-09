--[[ INORYA XELEBOT - ULTIMATE FIX (RESIZEABLE MENU + ESP LINE + BOX) ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- VARIABEL
local fly = false
local noclip = false
local esp = false
local aimbot = false
local speedEnabled = false
local speedValue = 16
local bodyVel = nil
local bodyGyro = nil
local noclipPart = nil
local espObjects = {}
local mainFrame = nil
local isResizing = false

-- FUNGSI FLY (FIXED)
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

-- FUNGSI NOCLIP
local function toggleNoclip(state)
    if state then
        noclipPart = Instance.new("Part")
        noclipPart.Size = char.HumanoidRootPart.Size
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Parent = char
    else
        if noclipPart then noclipPart:Destroy(); noclipPart = nil end
    end
end

-- FUNGSI ESP (LINE + BOX + NAMA KECIL)
local function toggleESP(state)
    -- Hapus ESP lama
    for _, obj in pairs(espObjects) do
        if obj.box then obj.box:Destroy() end
        if obj.line then obj.line:Destroy() end
        if obj.tag then obj.tag:Destroy() end
    end
    espObjects = {}
    
    if not state then return end
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- BOX ESP (kotak di sekeliling)
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 5, 2)
                box.Color3 = Color3.fromRGB(255, 50, 50)
                box.Adornee = root
                box.Parent = plr.Character
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.3
                
                -- LINE ESP (tali dari player ke target)
                local line = Instance.new("SelectionBox")
                line.Adornee = root
                line.Color3 = Color3.fromRGB(0, 200, 255)
                line.LineThickness = 0.05
                line.Transparency = 0.5
                line.Parent = plr.Character
                
                -- NAMA KECIL + HP (di atas kepala)
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 100, 0, 30)
                tag.Adornee = root
                tag.Parent = plr.Character
                tag.AlwaysOnTop = true
                tag.MaxDistance = 200
                tag.StudsOffset = Vector3.new(0, 3.5, 0)
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name .. " ❤" .. (plr.Character.Humanoid and math.floor(plr.Character.Humanoid.Health) or "?")
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.Gotham
                label.TextSize = 12
                label.Parent = tag
                
                table.insert(espObjects, {
                    plr = plr,
                    box = box,
                    line = line,
                    tag = tag,
                    label = label
                })
            end
        end
    end
end

-- UPDATE ESP (jarak, hp, line)
runService.Heartbeat:Connect(function()
    if esp and char and char.HumanoidRootPart then
        local origin = char.HumanoidRootPart.Position
        for _, obj in pairs(espObjects) do
            if obj.plr and obj.plr.Character then
                local root = obj.plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Update HP
                    if obj.plr.Character.Humanoid then
                        obj.label.Text = obj.plr.Name .. " ❤" .. math.floor(obj.plr.Character.Humanoid.Health)
                    end
                    
                    -- Update line (jarak)
                    local dist = (root.Position - origin).Magnitude
                    if obj.line then
                        obj.line.Color3 = dist < 50 and Color3.fromRGB(0, 255, 0) or dist < 100 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    end
end)

-- FUNGSI FLOATING MENU + RESIZE
local function CreateFloatingGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "InoryaX"
    sg.Parent = game.CoreGui
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = sg
    mainFrame.Active = true
    mainFrame.Draggable = true

    -- Gradient bg
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    gradient.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame

    -- Tombol Close
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -30, 0, 0)
    close.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = mainFrame
    close.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    -- Tombol Resize (seperti chrome)
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.Size = UDim2.new(0, 25, 0, 25)
    resizeBtn.Position = UDim2.new(0, 5, 0, 5)
    resizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    resizeBtn.Text = "◢"
    resizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resizeBtn.Font = Enum.Font.GothamBold
    resizeBtn.TextSize = 12
    resizeBtn.Parent = mainFrame
    resizeBtn.MouseButton1Down:Connect(function()
        isResizing = true
    end)
    resizeBtn.MouseButton1Up:Connect(function()
        isResizing = false
    end)

    -- Resize logic
    uis.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Delta
            local newSize = mainFrame.Size + UDim2.new(0, delta.X, 0, delta.Y)
            if newSize.X.Offset > 150 and newSize.Y.Offset > 250 then
                mainFrame.Size = newSize
            end
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
        b.Position = UDim2.new(0.075, 0, 0.10 + (i-1)*0.13, 0)
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

    -- Speed Value (angka)
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

-- MAIN LOOP (FLY GERAK + SPEED)
runService.Heartbeat:Connect(function()
    if char and char.HumanoidRootPart and char.Humanoid then
        -- SPEED
        if speedEnabled then
            char.Humanoid.WalkSpeed = speedValue
        else
            char.Humanoid.WalkSpeed = 16
        end

        -- FLY (gerak pake WASD + Space + Shift)
        if fly and bodyVel and bodyGyro then
            local moveDir = Vector3.new()
            local speed = 50
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
        
        -- NOCLIP
        if noclip and noclipPart then
            noclipPart.CFrame = char.HumanoidRootPart.CFrame
        end
    end
end)

-- RE-APPLY SAAT RESPAWN
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
CreateFloatingGUI()
print("✅ INORYA XELEBOT - ULTIMATE EDITION READY!")
