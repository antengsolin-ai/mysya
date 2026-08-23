--[[ 
    INORYA XELEBOT - FINAL ULTIMATE (TAB FIX + TIMER + ESP REALTIME)
    API: https://bowarrowapjir.my.id/panel/api.php?key=KEY
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local httpService = game:GetService("HttpService")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local players = game:GetService("Players")

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
    BypassTroll = false,
    BypassAimbot = false,
}

local espObjects = {}
local fovCircle = nil
local bodyVelocity = nil
local bodyGyro = nil
local keyExpiry = "Unlimited"
local remainingTime = "∞"
local isLoggedIn = false

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
-- VALIDASI KEY (DENGAN DELAY 3 DETIK)
-- =============================================
local function ValidateKey(key)
    if not key or key == "" then
        return false, "Key tidak boleh kosong."
    end
    
    local url = CONFIG.API_URL .. key
    print("📡 Mengecek key: " .. url)
    
    task.wait(3)
    
    local response = HttpGet(url)
    if not response then
        return false, "Gagal menghubungi server."
    end
    
    local data = httpService:JSONDecode(response)
    if not data then
        return false, "Response API tidak valid."
    end
    
    if data.success == true and data.valid == true then
        keyExpiry = data.expiry_text or "Unlimited"
        remainingTime = data.remaining or "∞"
        pcall(function()
            if writefile then
                writefile(CONFIG.KEY_FILE, key)
            end
        end)
        isLoggedIn = true
        return true, "✅ Login berhasil! Sisa: " .. remainingTime
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
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
    })
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
        if key == "" then
            statusLabel.Text = "⚠️ Key tidak boleh kosong!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        statusLabel.Text = "⏳ Memeriksa key (3 detik)..."
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

-- ===== NOCLIP TEMBUS TEBAL =====
local function ToggleNoclip(state)
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
    
    if state then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            task.spawn(function()
                while State.Noclip and char and char.Parent do
                    hrp.CFrame = hrp.CFrame
                    task.wait(0.1)
                end
            end)
        end
    end
end

-- ===== ESP REAL-TIME =====
local function UpdateESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not State.ESP then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
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

-- ===== LOOP ESP REAL-TIME =====
task.spawn(function()
    while task.wait(0.5) do
        if State.ESP then
            UpdateESP()
        end
    end
end)

players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if State.ESP then UpdateESP() end
end)

players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if State.ESP then UpdateESP() end
end)

for _, plr in pairs(players:GetPlayers()) do
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESP then UpdateESP() end
    end)
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

-- =============================================
-- TROLL FUNCTIONS
-- =============================================
local function TrollPlayer(action, target)
    if not target or not target.Character then return end
    local targetChar = target.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    
    if not targetRoot or not targetHumanoid then return end
    
    if State.BypassTroll then
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local force = Instance.new("BodyVelocity")
                    force.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    force.Velocity = Vector3.new(math.random(-500, 500), 500, math.random(-500, 500))
                    force.Parent = r
                    task.wait(0.5)
                    force:Destroy()
                end
            end
        end
        return
    end
    
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
-- UPDATE TIMER REALTIME
-- =============================================
local function UpdateTimer()
    while isLoggedIn do
        if keyExpiry ~= "Unlimited" then
            local now = os.time()
            local exp = os.time({year = tonumber(keyExpiry:sub(7,10)), month = tonumber(keyExpiry:sub(4,5)), day = tonumber(keyExpiry:sub(1,2)), hour = tonumber(keyExpiry:sub(12,13)) or 0, min = tonumber(keyExpiry:sub(15,16)) or 0})
            local diff = exp - now
            if diff > 0 then
                local days = math.floor(diff / 86400)
                local hours = math.floor((diff % 86400) / 3600)
                local mins = math.floor((diff % 3600) / 60)
                remainingTime = string.format("%d hari %02d:%02d", days, hours, mins)
            else
                remainingTime = "Expired"
            end
        end
        task.wait(1)
    end
end

-- =============================================
-- MENU TAB (AIM, VISUAL, PLAYER, TROLL)
-- =============================================
local function CreateModernMenu()
    local oldMenu = playerGui:FindFirstChild("InoryaMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InoryaMenu"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 340, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
    })
    grad.Parent = mainFrame
    
    -- ===== DRAG =====
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
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ===== HEADER =====
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
    
    -- Timer (di kiri bawah)
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    timerLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "⏳ " .. remainingTime
    timerLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextSize = 11
    timerLabel.TextXAlignment = Enum.TextXAlignment.Left
    timerLabel.Parent = header
    
    task.spawn(function()
        while screenGui and screenGui.Parent do
            timerLabel.Text = "⏳ " .. remainingTime
            task.wait(1)
        end
    end)
    
    -- Close
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
    
    -- Minimize
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
            mainFrame.Size = UDim2.new(0, 340, 0, 45)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= header then
                    child.Visible = false
                end
            end
            minBtn.Text = "□"
        else
            mainFrame.Size = UDim2.new(0, 340, 0, 480)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= header then
                    child.Visible = true
                end
            end
            minBtn.Text = "—"
        end
    end)
    
    -- ===== TAB SYSTEM =====
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 45)
    tabBar.BackgroundColor3 = Color3.fromRGB(0, 40, 120)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    local tabs = {"AIM", "VISUAL", "PLAYER", "TROLL"}
    local tabButtons = {}
    local currentTab = "AIM"
    
    local function SwitchTab(tab)
        currentTab = tab
        for _, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (btn.Text == tab) and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(0, 40, 120)
        end
        for _, child in pairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        BuildTabContent(tab)
        task.wait(0.1)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
        btn.BackgroundColor3 = (tab == "AIM") and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(0, 40, 120)
        btn.Text = tab
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = tabBar
        btn.Name = tab
        table.insert(tabButtons, btn)
        btn.MouseButton1Click:Connect(function()
            SwitchTab(tab)
        end)
    end
    
    -- ===== CONTENT FRAME =====
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, -80)
    contentFrame.Position = UDim2.new(0, 0, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 80, 200)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    -- ===== HELPERS =====
    local function CreateSection(text)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, -10, 0, 28)
        section.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        section.Text = text
        section.TextColor3 = Color3.fromRGB(255, 255, 255)
        section.Font = Enum.Font.GothamBold
        section.TextSize = 13
        section.Parent = contentFrame
        Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
        return section
    end
    
    local function CreateToggle(text, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = contentFrame
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
        holder.Parent = contentFrame
        
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
    
    -- ===== BUILD TAB CONTENT =====
    local function BuildTabContent(tab)
        if tab == "AIM" then
            CreateSection("🎯 AIMBOT")
            CreateToggle("Aimbot", "Aimbot")
            CreateToggle("Show FOV", "ShowFOV")
            CreateSlider("FOV Radius", "FOVRadius", 10, 400, 10)
            CreateSlider("Smoothness", "Smoothness", 1, 100, 1)
            CreateToggle("Bypass Aimbot", "BypassAimbot")
            
        elseif tab == "VISUAL" then
            CreateSection("👁️ VISUAL")
            CreateToggle("ESP", "ESP")
            CreateToggle("Box", "Box")
            CreateToggle("Skeleton", "Skeleton")
            CreateToggle("Tracer", "Tracer")
            
        elseif tab == "PLAYER" then
            CreateSection("🏃 PLAYER")
            CreateToggle("Speed", "Speed")
            CreateSlider("Speed Value", "SpeedValue", 16, 1000, 5)
            CreateToggle("Jump", "Jump")
            CreateSlider("Jump Power", "JumpValue", 50, 250, 10)
            CreateToggle("Fly", "Fly")
            CreateSlider("Fly Speed", "FlySpeed", 10, 300, 10)
            CreateToggle("Noclip", "Noclip")
            
        elseif tab == "TROLL" then
            CreateSection("🎭 TROLL")
            CreateToggle("Bypass Troll", "BypassTroll")
            
            local trollActions = {"Freeze", "Fling", "Kill", "Steal"}
            for _, action in ipairs(trollActions) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.45, 0, 0, 36)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
                btn.Text = action
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 13
                btn.Parent = contentFrame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                
                btn.MouseButton1Click:Connect(function()
                    local target = nil
                    local minDist = 1000
                    for _, plr in pairs(players:GetPlayers()) do
                        if plr ~= player and plr.Character then
                            local root = plr.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local dist = (root.Position - (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    target = plr
                                end
                            end
                        end
                    end
                    if target then
                        TrollPlayer(action, target)
                    end
                end)
            end
        end
    end
    
    BuildTabContent("AIM")
    
    task.wait(0.1)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    
    UpdateESP()
    UpdateFOV()
    ToggleFly(State.Fly)
    ToggleNoclip(State.Noclip)
    
    return screenGui
end

-- =============================================
-- UPDATE SAAT STATE BERUBAH
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
-- START
-- =============================================
print("⚡ INORYA XELEBOT - ULTIMATE STARTING...")

CreateLoginGUI(function()
    CreateModernMenu()
    task.spawn(UpdateTimer)
    print("✅ INORYA XELEBOT - ULTIMATE ACTIVE!")
end)
