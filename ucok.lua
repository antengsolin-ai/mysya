--[[ 
    INORYA XELEBOT - KEY SYSTEM + MENU MODERN
    API: https://bowarrowapjir.my.id/panel/api.php?key=KEY
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local httpService = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
    API_URL = "https://bowarrowapjir.my.id/panel/api.php?key=",
    KEY_FILE = "InoryaKey.txt",
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

-- =============================================
-- FUNGSI HTTP (WORK DI DELTA)
-- =============================================
local function HttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then return result end
    return nil
end

-- =============================================
-- FUNGSI VALIDASI KEY KE API
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
    
    print("📥 Response: " .. response)
    
    local data = httpService:JSONDecode(response)
    if not data then
        return false, "Response API tidak valid."
    end
    
    if data.success == true and data.valid == true then
        -- Simpan key (TAPI GA USAH AUTO-LOGIN)
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
-- CREATE LOGIN GUI
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
    
    -- Gradient Background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    gradient.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 55)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(0, 180, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -30, 0, 30)
    subtitle.Position = UDim2.new(0.05, 0, 0.2, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔑 Masukkan Key untuk mengaktifkan sistem"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 210)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame
    
    -- Key Box
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
    
    -- Login Button
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
    
    -- Get Key Button
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
    
    -- Status Label
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
    
    -- LOGIN BUTTON ACTION
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
    
    -- GET KEY BUTTON
    getKeyBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "🔗 Hubungi Owner untuk mendapatkan key"
        statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        if setclipboard then
            setclipboard("https://t.me/InoryaSupport")
            statusLabel.Text = "📋 Link Telegram sudah disalin!"
        end
    end)
    
    -- ENTER KEY
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            loginBtn.MouseButton1Click:Fire()
        end
    end)
    
    return screenGui
end

-- =============================================
-- MENU MODERN
-- =============================================
local function CreateModernMenu()
    local oldMenu = playerGui:FindFirstChild("InoryaMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaMenu"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 22))
    })
    gradient.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    
    -- Title
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
    
    -- Close Button
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
    
    -- Minimize Button
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
            mainFrame.Size = UDim2.new(0, 320, 0, 420)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= header then
                    child.Visible = true
                end
            end
            minBtn.Text = "—"
        end
    end)
    
    -- Scrolling Frame untuk konten
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
    
    -- ===== SECTION BUATAN =====
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
    
    -- ===== TOGGLE BUTTON =====
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
        end)
        return btn
    end
    
    -- ===== SLIDER =====
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
    
    -- ===== UPDATE CANVAS =====
    task.wait(0.1)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteContentSize.Y + 20)
    
    return screenGui
end

-- =============================================
-- MAIN SYSTEM
-- =============================================
local function LoadMainSystem()
    print("🚀 INORYA XELEBOT - MAIN SYSTEM LOADING...")
    CreateModernMenu()
    print("✅ INORYA XELEBOT - MENU ACTIVE!")
end

-- =============================================
-- START
-- =============================================
print("⚡ INORYA XELEBOT - KEY SYSTEM STARTING...")
print("🌐 API URL: " .. CONFIG.API_URL)

-- Tampilkan Login GUI (MANUAL, ga auto-login)
CreateLoginGUI(function()
    LoadMainSystem()
end)
