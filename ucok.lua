--[[ 
    INORYA XELEBOT - FULL SYSTEM
    API: https://bowarrowapjir.my.id/panel/api.php?key=KEY
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local httpService = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
    API_URL = "https://bowarrowapjir.my.id/panel/api.php?key=",
    KEY_FILE = "Zexzo.txt",
}

-- =============================================
-- VARIABEL FITUR
-- =============================================
local State = {
    Aimbot = false,
    Smoothness = 15,
    FOVRadius = 150,
    ShowFOV = false,
    ESP = false,
    Box = false,
    Skeleton = false,
    Tracer = false,
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
local flyKeys = {Forward=false, Backward=false, Left=false, Right=false, Up=false, Down=false}
local noclipParts = {}

-- =============================================
-- FUNGSI HTTP
-- =============================================
local function HttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then return result end
    return nil
end

-- =============================================
-- VALIDASI KEY
-- =============================================
local function ValidateKey(key)
    if not key or key == "" then
        return false, "Key tidak boleh kosong."
    end
    
    local url = CONFIG.API_URL .. key
    print("📡 Mengecek key: " .. url)
    
    local response = HttpGet(url)
    if not response then
        return false, "Gagal menghubungi server."
    end
    
    local data = httpService:JSONDecode(response)
    if not data then
        return false, "Response API tidak valid."
    end
    
    if data.success == true and data.valid == true then
        pcall(function()
            if writefile then
                writefile(CONFIG.KEY_FILE, key)
            end
        end)
        return true, "✅ Login berhasil! Sisa waktu: " .. (data.remaining or "Unlimited")
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
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 55)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(0, 180, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -30, 0, 30)
    subtitle.Position = UDim2.new(0.05, 0, 0.2, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔑 Masukkan Key untuk mengaktifkan sistem"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 210)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.85, 0, 0, 42)
    keyBox.Position = UDim2.new(0.075, 0, 0.35, 0)
    keyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
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
    loginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    loginBtn.Text = "🔓 LOGIN"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.Font = Enum.Font.GothamBold
    loginBtn.TextSize = 14
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 42)
    getKeyBtn.Position = UDim2.new(0.525, 0, 0.58, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
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
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    loginBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text
        if key == "" then
            statusLabel.Text = "⚠️ Key tidak boleh kosong!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        statusLabel.Text = "⏳ Memeriksa key..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        loginBtn.Text = "⏳..."
        loginBtn.Active = false
        
        task.spawn(function()
            local valid, msg = ValidateKey(key)
            if valid then
                statusLabel.Text = "✅ " .. msg
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                task.wait(0.8)
                screenGui:Destroy()
                if callback then callback() end
            else
                statusLabel.Text = "❌ " .. msg
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                loginBtn.Text = "🔓 LOGIN"
                loginBtn.Active = true
            end
        end)
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "🔗 Hubungi Owner untuk mendapatkan key"
        statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        if setclipboard then
            setclipboard("https://t.me/InoryaSupport")
            statusLabel.Text = "📋 Link Telegram sudah disalin!"
        end
    end)
    
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            loginBtn.MouseButton1Click:Fire()
        end
    end)
    
    return screenGui
end

-- =============================================
-- FITUR-FITUR
-- =============================================

-- ===== ESP =====
local function UpdateESP()
    -- Hapus ESP lama
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not State.ESP then return end
    
    for _, plr in pairs(game:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Box ESP
                if State.Box then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(4, 5, 2)
                    box.Color3 = Color3.fromRGB(255, 50, 50)
                    box.Adornee = root
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.3
                    box.Parent = plr.Character
                    table.insert(espObjects, box)
                end
                
                -- Name
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 120, 0, 30)
                tag.Adornee = root
                tag.AlwaysOnTop = true
                tag.MaxDistance = 300
                tag.StudsOffset = Vector3.new(0, 3.5, 0)
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

-- ===== FOV CIRCLE =====
local function UpdateFOV()
    if fovCircle then
        fovCircle:Destroy()
        fovCircle = nil
    end
    
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

-- ===== FLY =====
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

-- ===== NOCLIP =====
local function ToggleNoclip(state)
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- =============================================
-- INPUT HANDLER
-- =============================================
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyKeys.Forward = true
    elseif key == Enum.KeyCode.S then flyKeys.Backward = true
    elseif key == Enum.KeyCode.A then flyKeys.Left = true
    elseif key == Enum.KeyCode.D then flyKeys.Right = true
    elseif key == Enum.KeyCode.Space then flyKeys.Up = true
    elseif key == Enum.KeyCode.LeftControl then flyKeys.Down = true
    end
end)

userInput.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyKeys.Forward = false
    elseif key == Enum.KeyCode.S then flyKeys.Backward = false
    elseif key == Enum.KeyCode.A then flyKeys.Left = false
    elseif key == Enum.KeyCode.D then flyKeys.Right = false
    elseif key == Enum.KeyCode.Space then flyKeys.Up = false
    elseif key == Enum.KeyCode.LeftControl then flyKeys.Down = false
    end
end)

-- =============================================
-- MAIN LOOP
-- =============================================
runService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    -- ===== SPEED & JUMP =====
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
    
    -- ===== FLY =====
    if State.Fly and bodyVelocity and bodyGyro and hrp then
        local move = Vector3.new()
        local speed = State.FlySpeed
        local forward = hrp.CFrame.LookVector
        local right = hrp.CFrame.RightVector
        
        if flyKeys.Forward then move = move + forward * speed end
        if flyKeys.Backward then move = move - forward * speed end
        if flyKeys.Left then move = move - right * speed end
        if flyKeys.Right then move = move + right * speed end
        if flyKeys.Up then move = move + Vector3.new(0, speed, 0) end
        if flyKeys.Down then move = move - Vector3.new(0, speed, 0) end
        
        bodyVelocity.Velocity = move
        bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
    end
    
    -- ===== NOCLIP =====
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not State.Noclip
            end
        end
    end
    
    -- ===== AIMBOT =====
    if State.Aimbot and camera and hrp then
        local closest = nil
        local minDist = State.FOVRadius
        
        for _, plr in pairs(game:GetPlayers()) do
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
        
        if closest then
            local targetCF = CFrame.lookAt(camera.CFrame.Position, closest.Position)
            local smooth = math.clamp(State.Smoothness / 100, 0.01, 1)
            camera.CFrame = camera.CFrame:Lerp(targetCF, smooth)
        end
    end
end)

-- =============================================
-- UPDATE FITUR SAAT STATE BERUBAH
-- =============================================
local function OnStateChange(key)
    if key == "ESP" or key == "Box" or key == "Skeleton" or key == "Tracer" then
        UpdateESP()
    elseif key == "ShowFOV" or key == "FOVRadius" then
        UpdateFOV()
    elseif key == "Fly" then
        ToggleFly(State.Fly)
    elseif key == "Noclip" then
        ToggleNoclip(State.Noclip)
    end
end

-- =============================================
-- MENU MODERN (DENGAN FITUR)
-- =============================================
local function CreateModernMenu()
    local oldMenu = playerGui:FindFirstChild("InoryaMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaMenu"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(0, 180, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
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
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -72, 0, 8)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
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
            mainFrame.Size = UDim2.new(0, 320, 0, 45)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= header then
                    child.Visible = false
                end
            end
            minBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 320, 0, 460)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= header then
                    child.Visible = true
                end
            end
            minBtn.Text = "—"
        end
    end)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -45)
    scrollFrame.Position = UDim2.new(0, 0, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 70)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    local content = Instance.new("UIListLayout")
    content.Padding = UDim.new(0, 6)
    content.SortOrder = Enum.SortOrder.LayoutOrder
    content.Parent = scrollFrame
    
    -- ===== CREATE SECTION =====
    local function CreateSection(text)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, -10, 0, 28)
        section.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        section.Text = text
        section.TextColor3 = Color3.fromRGB(255, 255, 255)
        section.Font = Enum.Font.GothamBold
        section.TextSize = 13
        section.Parent = scrollFrame
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
        return section
    end
    
    -- ===== CREATE TOGGLE =====
    local function CreateToggle(text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            State[key] = not State[key]
            btn.Text = text .. (State[key] and " [ON]" or " [OFF]")
            btn.BackgroundColor3 = State[key] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(40, 40, 60)
            OnStateChange(key)
        end)
        return btn
    end
    
    -- ===== CREATE SLIDER =====
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
        valueLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = holder
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 6)
        bar.Position = UDim2.new(0, 0, 0, 26)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        bar.BorderSizePixel = 0
        bar.Parent = holder
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((State[key] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
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
                dragging = true
                update(input)
            end
        end)
        
        userInput.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        userInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    
    -- ===== BUILD MENU =====
    CreateSection("🎯 AIMBOT")
    CreateToggle("Aimbot", "Aimbot")
    CreateToggle("Show FOV", "ShowFOV")
    CreateSlider("FOV Radius", "FOVRadius", 10, 400, 10)
    CreateSlider("Smoothness", "Smoothness", 1, 100, 1)
    
    CreateSection("👁️ VISUAL")
    CreateToggle("ESP", "ESP")
    CreateToggle("Box", "Box")
    CreateToggle("Skeleton", "Skeleton")
    CreateToggle("Tracer", "Tracer")
    
    CreateSection("🏃 PLAYER")
    CreateToggle("Speed", "Speed")
    CreateSlider("Speed Value", "SpeedValue", 16, 250, 5)
    CreateToggle("Jump", "Jump")
    CreateSlider("Jump Power", "JumpValue", 50, 250, 10)
    CreateToggle("Fly", "Fly")
    CreateSlider("Fly Speed", "FlySpeed", 10, 300, 10)
    CreateToggle("Noclip", "Noclip")
    
    task.wait(0.1)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteContentSize.Y + 20)
    
    -- Inisialisasi ESP
    UpdateESP()
    UpdateFOV()
    ToggleFly(State.Fly)
    ToggleNoclip(State.Noclip)
    
    return screenGui
end

-- =============================================
-- START
-- =============================================
print("⚡ INORYA XELEBOT - KEY SYSTEM STARTING...")

CreateLoginGUI(function()
    CreateModernMenu()
    print("✅ INORYA XELEBOT - FULL SYSTEM ACTIVE!")
end)
