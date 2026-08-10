--[[ INORYA XELEBOT - KEY SYSTEM DENGAN DEBUG ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local http = game:GetService("HttpService")

-- ==================== VARIABEL KEY ====================
local userKey = ""
local keyStatus = "❌ Invalid"
local keyDuration = "0 Days"
local keyExpiry = ""
local isKeyValid = false

-- ==================== FUNGSI CEK KEY DENGAN DEBUG ====================
local function CheckKey(key)
    if not key or key == "" then 
        print("⚠️ Key kosong!")
        return false 
    end
    
    local url = "https://bowarrowapjir.my.id/panel/api.php?key=" .. key
    print("📡 Mengirim request ke: " .. url)
    
    local success, response = pcall(function()
        return http:GetAsync(url)
    end)
    
    if success and response then
        print("📥 Response dari server: " .. response)
        
        -- Coba parse JSON
        local data = http:JSONDecode(response)
        if data then
            print("✅ JSON terparse: ", data)
            if data.status and data.status == "success" then
                keyStatus = "✅ Active"
                keyExpiry = data.expiry or "Unknown"
                keyDuration = "Exp: " .. keyExpiry
                isKeyValid = true
                return true
            else
                keyStatus = "❌ Invalid (Status: " .. (data.status or "unknown") .. ")"
                keyDuration = "Expired"
                isKeyValid = false
                return false
            end
        else
            keyStatus = "⚠️ Response bukan JSON"
            keyDuration = "Check Failed"
            isKeyValid = false
            return false
        end
    else
        print("❌ Gagal menghubungi API: " .. tostring(response))
        keyStatus = "⚠️ API Error (HTTP: " .. tostring(response) .. ")"
        keyDuration = "Check Failed"
        isKeyValid = false
        return false
    end
end

-- ==================== POPUP INPUT KEY ====================
local function ShowKeyPopup()
    local sgPopup = Instance.new("ScreenGui")
    sgPopup.Name = "KeyPopup"
    sgPopup.Parent = game.CoreGui
    sgPopup.ResetOnSpawn = false

    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.new(0, 380, 0, 250)
    popupFrame.Position = UDim2.new(0.5, -190, 0.5, -125)
    popupFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    popupFrame.BorderSizePixel = 0
    popupFrame.Parent = sgPopup

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "🔑 MASUKAN KEY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = popupFrame

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.8, 0, 0, 40)
    keyBox.Position = UDim2.new(0.1, 0, 0.28, 0)
    keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    keyBox.Text = ""
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 16
    keyBox.PlaceholderText = "Masukan Key..."
    keyBox.Parent = popupFrame

    -- DEBUG RESPONSE LABEL
    local debugLabel = Instance.new("TextLabel")
    debugLabel.Size = UDim2.new(0.9, 0, 0, 50)
    debugLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    debugLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    debugLabel.Text = "📡 Belum ada request"
    debugLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    debugLabel.Font = Enum.Font.Gotham
    debugLabel.TextSize = 11
    debugLabel.TextWrapped = true
    debugLabel.Parent = popupFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.1, 0, 0.75, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🔴 Belum divalidasi"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.Parent = popupFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.4, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.3, 0, 0.85, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    submitBtn.Text = "VALIDASI"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 16
    submitBtn.Parent = popupFrame

    submitBtn.MouseButton1Click:Connect(function()
        local key = keyBox.Text
        if key == "" then
            statusLabel.Text = "⚠️ Key tidak boleh kosong!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end

        statusLabel.Text = "⏳ Mengecek key..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        debugLabel.Text = "📡 Mengirim request ke API..."

        -- Delay biar keliatan prosesnya
        wait(0.5)

        local valid = CheckKey(key)
        
        -- Update debug label dengan response terakhir
        debugLabel.Text = "📥 Response: " .. (keyStatus or "Tidak ada response")

        if valid then
            userKey = key
            statusLabel.Text = "✅ KEY VALID! Memuat sistem..."
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            debugLabel.Text = "✅ Key valid! Load system..."
            wait(0.5)
            sgPopup:Destroy()
            LoadSystem()
        else
            statusLabel.Text = "❌ KEY INVALID! Cek debug di bawah."
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            debugLabel.Text = debugLabel.Text .. "\n❌ Key tidak dikenali oleh server."
        end
    end)

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitBtn.MouseButton1Click:Fire()
        end
    end)
end

-- ==================== SISTEM UTAMA ====================
local function LoadSystem()
    -- (SEMUA FITUR YANG SAMA KAYAK SEBELUMNYA)
    -- Gw singkat di sini karena udah panjang, tapi intinya semua fitur (Fly, Noclip, ESP, Aimbot, Troll) tetap sama.
    -- Lo bisa copy paste dari script sebelumnya di bagian ini.
    print("✅ SISTEM BERHASIL DIMUAT! Selamat bermain, Bos!")
end

-- ==================== START ====================
ShowKeyPopup()
