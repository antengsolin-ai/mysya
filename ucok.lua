--[[ INORYA XELEBOT - HP ULTIMATE (ESP LENGKAP + AIMBOT TEMBAK + TROLL) ]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local httpService = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local mouse = player:GetMouse()

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
    API_URL = "https://bowarrowapjir.my.id/panel/api.php?key=",
    KEY_FILE = "Zexzo.txt",
}

-- =============================================
-- STATE
-- =============================================
local State = {
    Aimbot = false,
    FOVRadius = 200,
    ShowFOV = false,
    ESP = false,
    Box = false,
    Line = false,
    Health = false,
    Speed = false,
    SpeedValue = 50,
    Jump = false,
    JumpValue = 100,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
}

local espObjects = {}
local fovCircle = nil
local bodyVelocity = nil
local bodyGyro = nil
local remainingSeconds = 0
local remainingText = "∞"
local isLoggedIn = false
local flyUp = false
local flyDown = false
local aimbotTarget = nil

-- =============================================
-- FUNGSI HTTP & VALIDASI KEY
-- =============================================
local function HttpGet(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then return result end
    return nil
end

local function ValidateKey(key)
    if not key or key == "" then return false, "Key tidak boleh kosong." end
    local url = CONFIG.API_URL .. key
    task.wait(3)
    local response = HttpGet(url)
    if not response then return false, "Gagal menghubungi server." end
    local data = httpService:JSONDecode(response)
    if not data then return false, "Response API tidak valid." end
    if data.success == true and data.valid == true then
        remainingSeconds = data.remaining_seconds or 0
        if remainingSeconds > 0 then
            local days = math.floor(remainingSeconds / 86400)
            local hours = math.floor((remainingSeconds % 86400) / 3600)
            local mins = math.floor((remainingSeconds % 3600) / 60)
            local secs = remainingSeconds % 60
            remainingText = string.format("%d hari %02d:%02d:%02d", days, hours, mins, secs)
        else
            remainingText = "∞"
        end
        pcall(function() if writefile then writefile(CONFIG.KEY_FILE, key) end end)
        isLoggedIn = true
        return true, "✅ Login berhasil! Sisa: " .. remainingText
    else
        return false, data.message or "Key tidak valid."
    end
end

-- =============================================
-- LOGIN GUI
-- =============================================
local function CreateLoginGUI(callback)
    local oldGui = playerGui:FindFirstChild("InoryaLogin")
    if oldGui then oldGui:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaLogin"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 360, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))})
    grad.Parent = mainFrame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 55)
    title.BackgroundColor3 = Color3.fromRGB(0, 60, 180)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -30, 0, 30)
    subtitle.Position = UDim2.new(0.05, 0, 0.2, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔑 Masukkan Key untuk mengaktifkan sistem"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 220)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.85, 0, 0, 42)
    keyBox.Position = UDim2.new(0.075, 0, 0.35, 0)
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    keyBox.Text = ""
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 14
    keyBox.PlaceholderText = "Masukkan Key..."
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = mainFrame
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(0.4, 0, 0, 42)
    loginBtn.Position = UDim2.new(0.075, 0, 0.58, 0)
    loginBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    loginBtn.Text = "🔓 LOGIN"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.Font = Enum.Font.GothamBold
    loginBtn.TextSize = 14
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 42)
    getKeyBtn.Position = UDim2.new(0.525, 0, 0.58, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
    getKeyBtn.Text = "🔗 GET KEY"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14
    getKeyBtn.Parent = mainFrame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
    statusLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Silakan masukkan key Anda"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    loginBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text
        if key == "" then statusLabel.Text = "⚠️ Key tidak boleh kosong!"; statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0); return end
        statusLabel.Text = "⏳ Memeriksa key..."; statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        loginBtn.Text = "⏳..."; loginBtn.Active = false
        task.spawn(function()
            local valid, msg = ValidateKey(key)
            if valid then
                statusLabel.Text = "✅ " .. msg; statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                task.wait(0.8)
                screenGui:Destroy()
                if callback then callback() end
            else
                statusLabel.Text = "❌ " .. msg; statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                loginBtn.Text = "🔓 LOGIN"; loginBtn.Active = true
            end
        end)
    end)
    keyBox.FocusLost:Connect(function(enterPressed) if enterPressed then loginBtn.MouseButton1Click:Fire() end end)
    return screenGui
end

-- =============================================
-- ESP (BOX + LINE + HEALTH)
-- =============================================
local function UpdateESP()
    for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
    espObjects = {}
    if not State.ESP then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if root then
                -- ===== BOX =====
                if State.Box then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(4, 5, 2)
                    box.Color3 = Color3.fromRGB(255, 50, 50)
                    box.Adornee = root
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.2
                    box.Parent = plr.Character
                    table.insert(espObjects, box)
                end
                
                -- ===== LINE (tali dari kaki ke tanah) =====
                if State.Line then
                    local line = Instance.new("SelectionBox")
                    line.Adornee = root
                    line.Color3 = Color3.fromRGB(0, 200, 255)
                    line.LineThickness = 0.1
                    line.Transparency = 0.5
                    line.Parent = plr.Character
                    table.insert(espObjects, line)
                end
                
                -- ===== HEALTH BAR =====
                if State.Health and humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local hpColor = Color3.new(1 - healthPercent, healthPercent, 0)
                    
                    local healthBack = Instance.new("Frame")
                    healthBack.Size = UDim2.new(0, 2, 0, 50)
                    healthBack.Position = UDim2.new(0, 0, 0, 0)
                    healthBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    healthBack.BorderSizePixel = 0
                    healthBack.Parent = root
                    
                    local healthFill = Instance.new("Frame")
                    healthFill.Size = UDim2.new(1, 0, healthPercent, 0)
                    healthFill.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
                    healthFill.BackgroundColor3 = hpColor
                    healthFill.BorderSizePixel = 0
                    healthFill.Parent = healthBack
                    
                    -- Billboard buat posisi health di atas player
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 30, 0, 60)
                    bill.Adornee = root
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0, 3, 0)
                    bill.Parent = root
                    healthBack.Parent = bill
                    healthFill.Parent = healthBack
                    
                    table.insert(espObjects, bill)
                    table.insert(espObjects, healthBack)
                    table.insert(espObjects, healthFill)
                end
                
                -- ===== NAMA =====
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 120, 0, 30)
                tag.Adornee = root
                tag.AlwaysOnTop = true
                tag.MaxDistance = 300
                tag.StudsOffset = Vector3.new(0, 4, 0)
                tag.Parent = plr.Character
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 12
                label.Parent = tag
                
                table.insert(espObjects, tag)
                table.insert(espObjects, label)
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if State.ESP then UpdateESP() end
    end
end)

players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if State.ESP then UpdateESP() end
end)

for _, plr in pairs(players:GetPlayers()) do
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESP then UpdateESP() end
    end)
end

-- =============================================
-- FOV
-- =============================================
local function UpdateFOV()
    if fovCircle then fovCircle:Destroy(); fovCircle = nil end
    if State.ShowFOV and State.Aimbot then
        fovCircle = Drawing.new("Circle")
        fovCircle.Radius = State.FOVRadius
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(0, 255, 0)
        fovCircle.Filled = false
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        fovCircle.Parent = camera
    end
end

-- =============================================
-- FLY
-- =============================================
local function ToggleFly(state)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if state then
        if not hrp or not humanoid then return end
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.Parent = hrp
        bodyGyro.CFrame = hrp.CFrame
        humanoid.PlatformStand = true
    else
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- =============================================
-- TOMBOL PANAH FLY
-- =============================================
local flyKeys = {Up = false, Down = false, Left = false, Right = false}

local function CreateFlyButtons()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FlyButtons"
    sg.Parent = playerGui
    sg.ResetOnSpawn = false
    sg.Enabled = false
    
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 55, 0, 55)
    upBtn.Position = UDim2.new(0.8, 0, 0.6, 0)
    upBtn.Text = "▲"
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 24
    upBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.Parent = sg
    Instance.new("UICorner", upBtn)
    
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 55, 0, 55)
    downBtn.Position = UDim2.new(0.8, 0, 0.75, 0)
    downBtn.Text = "▼"
    downBtn.Font = Enum.Font.GothamBold
    downBtn.TextSize = 24
    downBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.Parent = sg
    Instance.new("UICorner", downBtn)
    
    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0, 55, 0, 55)
    rightBtn.Position = UDim2.new(0.9, 0, 0.675, 0)
    rightBtn.Text = "►"
    rightBtn.Font = Enum.Font.GothamBold
    rightBtn.TextSize = 24
    rightBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    rightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightBtn.Parent = sg
    Instance.new("UICorner", rightBtn)
    
    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0, 55, 0, 55)
    leftBtn.Position = UDim2.new(0.7, 0, 0.675, 0)
    leftBtn.Text = "◄"
    leftBtn.Font = Enum.Font.GothamBold
    leftBtn.TextSize = 24
    leftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    leftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftBtn.Parent = sg
    Instance.new("UICorner", leftBtn)
    
    upBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Up = true end
    end)
    upBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Up = false end
    end)
    downBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Down = true end
    end)
    downBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Down = false end
    end)
    rightBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Right = true end
    end)
    rightBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Right = false end
    end)
    leftBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Left = true end
    end)
    leftBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then flyKeys.Left = false end
    end)
    
    return sg
end

local flyButtons = CreateFlyButtons()

-- =============================================
-- TROLL (FIX)
-- =============================================
local function TrollPlayer(action, target)
    if not target or not target.Character then return end
    local targetChar = target.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    if not targetRoot or not targetHumanoid then return end
    
    if action == "Freeze" then
        targetHumanoid.WalkSpeed = 0
        targetHumanoid.JumpPower = 0
        targetHumanoid.PlatformStand = true
        task.wait(3)
        targetHumanoid.WalkSpeed = 16
        targetHumanoid.JumpPower = 50
        targetHumanoid.PlatformStand = false
        
    elseif action == "Fling" then
        local force = Instance.new("BodyVelocity")
        force.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        force.Velocity = Vector3.new(math.random(-200, 200), 300, math.random(-200, 200))
        force.Parent = targetRoot
        task.wait(0.5)
        force:Destroy()
        
    elseif action == "Kill" then
        targetHumanoid.Health = 0
        
    elseif action == "Steal" then
        for _, tool in pairs(targetChar:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = player.Character
            end
        end
    end
end

-- =============================================
-- Cari target terdekat
-- =============================================
local function GetClosestTarget()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest = nil
    local minDist = State.FOVRadius
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = root
                    end
                end
            end
        end
    end
    
    return closest
end

-- =============================================
-- DETEKSI TOMBOL TEMBAK (MOUSE BUTTON 1)
-- =============================================
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if State.Aimbot and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = GetClosestTarget()
        if target then
            aimbotTarget = target
        end
    end
end)

userInput.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimbotTarget = nil
    end
end)

-- =============================================
-- MAIN LOOP
-- =============================================
runService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        if State.Speed then
            humanoid.WalkSpeed = State.SpeedValue
        else
            humanoid.WalkSpeed = 16
        end
        
        if State.Jump then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = State.JumpValue
        else
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 50
        end
    end
    
    -- FLY
    if State.Fly and bodyVelocity and bodyGyro and hrp then
        local move = Vector3.new()
        local speed = State.FlySpeed
        local forward = hrp.CFrame.LookVector
        local right = hrp.CFrame.RightVector
        
        if flyKeys.Up then move = move + forward * speed end
        if flyKeys.Down then move = move - forward * speed end
        if flyKeys.Left then move = move - right * speed end
        if flyKeys.Right then move = move + right * speed end
        
        bodyVelocity.Velocity = move
        bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
    end
    
    -- NOCLIP
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not State.Noclip
            end
        end
    end
    
    -- AIMBOT (hanya saat tombol tembak ditekan)
    if State.Aimbot and aimbotTarget and camera then
        local targetCF = CFrame.lookAt(camera.CFrame.Position, aimbotTarget.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCF, 0.2)
    end
end)

-- =============================================
-- TIMER
-- =============================================
local function UpdateTimer()
    while isLoggedIn do
        if remainingSeconds > 0 then
            remainingSeconds = remainingSeconds - 1
            local days = math.floor(remainingSeconds / 86400)
            local hours = math.floor((remainingSeconds % 86400) / 3600)
            local mins = math.floor((remainingSeconds % 3600) / 60)
            local secs = remainingSeconds % 60
            remainingText = string.format("%d hari %02d:%02d:%02d", days, hours, mins, secs)
            
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui.Name == "InoryaMenu" then
                    for _, child in pairs(gui:GetDescendants()) do
                        if child.Name == "TimerLabel" and child:IsA("TextLabel") then
                            child.Text = "⏳ " .. remainingText
                        end
                    end
                end
            end
        else
            remainingText = "∞"
        end
        task.wait(1)
    end
end

-- =============================================
-- UPDATE STATE
-- =============================================
local function OnStateChange(key)
    if key == "ESP" or key == "Box" or key == "Line" or key == "Health" then
        UpdateESP()
    elseif key == "ShowFOV" or key == "FOVRadius" then
        UpdateFOV()
    elseif key == "Fly" then
        ToggleFly(State.Fly)
        flyButtons.Enabled = State.Fly
    elseif key == "Noclip" then
        ToggleNoclip(State.Noclip)
    end
end

-- =============================================
-- MENU
-- =============================================
local function CreateMenu()
    local oldMenu = playerGui:FindFirstChild("InoryaMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaMenu"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))})
    grad.Parent = mainFrame
    
    -- DRAG
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(0, 60, 180)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    header.Active = true
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    userInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    timerLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "⏳ " .. remainingText
    timerLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextSize = 11
    timerLabel.TextXAlignment = Enum.TextXAlignment.Left
    timerLabel.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -72, 0, 8)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = header
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0, 300, 0, 45)
            for _, child in pairs(mainFrame:GetChildren()) do if child ~= header then child.Visible = false end end
            minBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 500)
            for _, child in pairs(mainFrame:GetChildren()) do if child ~= header then child.Visible = true end end
            minBtn.Text = "—"
        end
    end)
    
    -- SCROLLING FRAME
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -45)
    scrollFrame.Position = UDim2.new(0, 0, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 80, 200)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    -- HELPERS
    local function CreateSection(text)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, -10, 0, 28)
        section.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        section.Text = text
        section.TextColor3 = Color3.fromRGB(255, 255, 255)
        section.Font = Enum.Font.GothamBold
        section.TextSize = 13
        section.Parent = scrollFrame
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
        return section
    end
    
    local function CreateToggle(text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(20, 20, 50)
        btn.Text = text .. (State[key] and " [ON]" or " [OFF]")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            State[key] = not State[key]
            btn.Text = text .. (State[key] and " [ON]" or " [OFF]")
            btn.BackgroundColor3 = State[key] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(20, 20, 50)
            OnStateChange(key)
        end)
        return btn
    end
    
    local function CreateSlider(text, key, min, max, step)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 50)
        holder.BackgroundTransparency = 1
        holder.Parent = scrollFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = holder
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(State[key])
        valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = holder
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 6)
        bar.Position = UDim2.new(0, 0, 0, 26)
        bar.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
        bar.BorderSizePixel = 0
        bar.Parent = holder
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((State[key] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local draggingSlider = false
        local function update(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * rel
            val = math.floor(val / step) * step
            val = math.clamp(val, min, max)
            State[key] = val
            valueLabel.Text = tostring(val)
            fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
            OnStateChange(key)
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                update(input)
            end
        end)
        userInput.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        userInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)
    end
    
    -- ===== BUILD MENU =====
    CreateSection("🎯 AIMBOT")
    CreateToggle("Aimbot [Tekan Tembak]", "Aimbot")
    CreateToggle("Show FOV", "ShowFOV")
    CreateSlider("FOV Radius", "FOVRadius", 10, 400, 10)
    
    CreateSection("👁️ ESP")
    CreateToggle("ESP", "ESP")
    CreateToggle("Box", "Box")
    CreateToggle("Line", "Line")
    CreateToggle("Health Bar", "Health")
    
    CreateSection("🏃 PLAYER")
    CreateToggle("Speed", "Speed")
    CreateSlider("Speed Value", "SpeedValue", 16, 1000, 5)
    CreateToggle("Jump", "Jump")
    CreateSlider("Jump Power", "JumpValue", 50, 500, 10)
    CreateToggle("Fly", "Fly")
    CreateSlider("Fly Speed", "FlySpeed", 10, 300, 10)
    CreateToggle("Noclip", "Noclip")
    
    CreateSection("🎭 TROLL")
    local trollActions = {"Freeze", "Fling", "Kill", "Steal"}
    for _, action in ipairs(trollActions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.45, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
        btn.Text = action
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            local target = nil
            local minDist = 1000
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            for _, plr in pairs(players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and hrp then
                        local dist = (root.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = plr
                        end
                    end
                end
            end
            if target then TrollPlayer(action, target) end
        end)
    end
    
    task.wait(0.1)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    
    UpdateESP()
    UpdateFOV()
    ToggleFly(State.Fly)
    flyButtons.Enabled = State.Fly
    ToggleNoclip(State.Noclip)
    
    return screenGui
end

-- =============================================
-- START
-- =============================================
print("⚡ INORYA XELEBOT - HP ULTIMATE STARTING...")

CreateLoginGUI(function()
    CreateMenu()
    task.spawn(UpdateTimer)
    print("✅ INORYA XELEBOT - ACTIVE!")
end)
