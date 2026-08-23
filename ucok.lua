--[[ 
    INORYA XELEBOT - KEY SYSTEM + MAIN SCRIPT
    API: https://bowarrowapjir.my.id/panel/api.php?key=KEY
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local httpService = game:GetService("HttpService")

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
    API_URL = "https://bowarrowapjir.my.id/panel/api.php?key=",
    KEY_FILE = "InoryaKey.txt",
    MAIN_SCRIPT_URL = nil,
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
-- CEK AUTO-LOGIN
-- =============================================
local function CheckAutoLogin()
    if not isfile or not readfile then return false end
    if not isfile(CONFIG.KEY_FILE) then return false end
    
    local savedKey = readfile(CONFIG.KEY_FILE)
    if savedKey and savedKey ~= "" then
        print("🔑 Key tersimpan: " .. savedKey)
        local valid, msg = ValidateKey(savedKey)
        if valid then
            print("✅ Auto-login berhasil!")
            return true, savedKey
        else
            print("❌ Auto-login gagal: " .. msg)
            return false, nil
        end
    end
    return false, nil
end

-- =============================================
-- CREATE LOGIN GUI
-- =============================================
local function CreateLoginGUI()
    local oldGui = playerGui:FindFirstChild("InoryaLogin")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaLogin"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 340, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 30)
    subtitle.Position = UDim2.new(0.05, 0, 0.18, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "🔑 Masukkan Key untuk mengaktifkan"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.Parent = mainFrame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.85, 0, 0, 40)
    keyBox.Position = UDim2.new(0.075, 0, 0.32, 0)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    keyBox.Text = ""
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 14
    keyBox.PlaceholderText = "Masukkan Key..."
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = mainFrame
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    
    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(0.4, 0, 0, 40)
    loginBtn.Position = UDim2.new(0.075, 0, 0.55, 0)
    loginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    loginBtn.Text = "🔓 LOGIN"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.Font = Enum.Font.GothamBold
    loginBtn.TextSize = 14
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    getKeyBtn.Position = UDim2.new(0.525, 0, 0.55, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    getKeyBtn.Text = "🔗 GET KEY"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 14
    getKeyBtn.Parent = mainFrame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Silakan masukkan key Anda"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- ===== LOGIN BUTTON =====
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
                LoadMainSystem()
            else
                statusLabel.Text = "❌ " .. msg
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                loginBtn.Text = "🔓 LOGIN"
                loginBtn.Active = true
            end
        end)
    end)
    
    -- ===== GET KEY BUTTON =====
    getKeyBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "🔗 Hubungi Owner untuk mendapatkan key"
        statusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        if setclipboard then
            setclipboard("https://wa.me/628xxxxxxxxx") -- Ganti kontak lo
            statusLabel.Text = "📋 Link kontak sudah disalin!"
        end
    end)
    
    -- ===== ENTER KEY =====
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            loginBtn.MouseButton1Click:Fire()
        end
    end)
    
    return screenGui
end

-- =============================================
-- MAIN SYSTEM (SETELAH LOGIN)
-- =============================================
local function LoadMainSystem()
    print("🚀 INORYA XELEBOT - MAIN SYSTEM LOADING...")
    
    if CONFIG.MAIN_SCRIPT_URL then
        local success, result = pcall(function()
            return game:HttpGet(CONFIG.MAIN_SCRIPT_URL)
        end)
        if success and result then
            print("📥 Load Main Script dari URL...")
            loadstring(result)()
            return
        end
    end
    
    -- NOTIFIKASI SUKSES
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0.3, 0)
    notif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    notif.Text = "✅ INORYA XELEBOT ACTIVE!"
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.Parent = playerGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    task.wait(2)
    notif:Destroy()
    
    -- Di sini lo bisa tambahin fitur ESP, AIM, DLL
    print("✅ INORYA XELEBOT - SYSTEM ACTIVE!")
end

-- =============================================
-- START
-- =============================================
print("⚡ INORYA XELEBOT - KEY SYSTEM STARTING...")
print("🌐 API URL: " .. CONFIG.API_URL)

local autoLoginSuccess, savedKey = CheckAutoLogin()
if autoLoginSuccess then
    print("✅ Auto-Login sukses!")
    LoadMainSystem()
else
    print("🔑 Menampilkan Login GUI...")
    CreateLoginGUI()
end
