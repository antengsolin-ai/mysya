--[[ INORYA XELEBOT - FULL FIXED + FLOATING GUI ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")

-- VARIABEL
local fly = false
local noclip = false
local esp = false
local aimbot = false
local speed = 16
local bodyVel = nil
local bodyGyro = nil
local noclipPart = nil
local espObjects = {}

-- FUNGSI FLY (PAKE BODYGYRO BIAR STABIL)
local function toggleFly(state)
    if state then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = char.HumanoidRootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.Parent = char.HumanoidRootPart
        bodyGyro.CFrame = char.HumanoidRootPart.CFrame
    else
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end

-- FUNGSI NOCLIP (PAKE CANCOLLIDE FALSE)
local function toggleNoclip(state)
    if state then
        noclipPart = Instance.new("Part")
        noclipPart.Size = char.HumanoidRootPart.Size
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Parent = char
        game:GetService("RunService").Stepped:Connect(function()
            if noclip and char and char.HumanoidRootPart then
                noclipPart.CFrame = char.HumanoidRootPart.CFrame
            end
        end)
    else
        if noclipPart then noclipPart:Destroy() end
    end
end

-- FUNGSI ESP (PAKE HIGHLIGHT + NAMETAG)
local function toggleESP(state)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if state then
                    -- Highlight (biar keliatan jelas)
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = plr.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = plr.Character

                    -- Nama + HP
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.Adornee = root
                    bill.Parent = plr.Character
                    bill.AlwaysOnTop = true

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name .. " ❤️ " .. (plr.Character.Humanoid and math.floor(plr.Character.Humanoid.Health) or "?")
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = bill

                    -- Simpen
                    table.insert(espObjects, {plr = plr, highlight = highlight, bill = bill, label = label})
                else
                    -- Hapus ESP
                    for i, obj in pairs(espObjects) do
                        if obj.plr == plr then
                            obj.highlight:Destroy()
                            obj.bill:Destroy()
                            table.remove(espObjects, i)
                        end
                    end
                end
            end
        end
    end
end

-- UPDATE ESP (LOOP BIAR HP NYA SEGAR)
game:GetService("RunService").Stepped:Connect(function()
    if esp then
        for _, obj in pairs(espObjects) do
            if obj.plr and obj.plr.Character and obj.plr.Character.Humanoid then
                obj.label.Text = obj.plr.Name .. " ❤️ " .. math.floor(obj.plr.Character.Humanoid.Health)
            end
        end
    end
end)

-- FUNGSI FLOATING MENU (DRAG)
local function CreateFloatingGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "InoryaX"
    sg.Parent = game.CoreGui
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 400)
    frame.Position = UDim2.new(0.5, -140, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    frame.Active = true
    frame.Draggable = true

    -- Biar keliatan keren (gradient)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Parent = frame

    -- Title + Close
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 40, 0, 30)
    close.Position = UDim2.new(1, -40, 0, 0)
    close.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    -- Tombol
    local toggles = {
        {name = "Fly", var = "fly"},
        {name = "NoClip", var = "noclip"},
        {name = "ESP", var = "esp"},
        {name = "Aimbot", var = "aimbot"}
    }

    for i, btn in ipairs(toggles) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.85, 0, 0, 35)
        b.Position = UDim2.new(0.075, 0, 0.12 + (i-1)*0.14, 0)
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        b.Text = btn.name .. " [OFF]"
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Parent = frame

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
            end
        end)
    end

    -- Speed Slider
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.85, 0, 0, 25)
    speedLabel.Position = UDim2.new(0.075, 0, 0.72, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    speedLabel.Text = "Speed: 16"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 14
    speedLabel.Parent = frame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.4, 0, 0, 25)
    speedBox.Position = UDim2.new(0.3, 0, 0.80, 0)
    speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedBox.Text = "16"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextSize = 14
    speedBox.Parent = frame
    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            speed = val
            speedLabel.Text = "Speed: " .. val
        end
    end)
end

-- MAIN LOOP (FLY + SPEED)
game:GetService("RunService").Heartbeat:Connect(function()
    if char and char.HumanoidRootPart and char.Humanoid then
        -- SPEED
        char.Humanoid.WalkSpeed = speed

        -- FLY (pakai mouse)
        if fly and bodyVel and bodyGyro then
            local moveDir = Vector3.new()
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + char.HumanoidRootPart.CFrame.LookVector * 50 end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - char.HumanoidRootPart.CFrame.LookVector * 50 end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - char.HumanoidRootPart.CFrame.RightVector * 50 end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + char.HumanoidRootPart.CFrame.RightVector * 50 end
            if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 50, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 50, 0) end

            bodyVel.Velocity = moveDir
            bodyGyro.CFrame = CFrame.new(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + mouse.Hit.Position - char.HumanoidRootPart.Position)
        end
    end
end)

-- INIT
CreateFloatingGUI()
print("✅ INORYA XELEBOT - FIXED & READY!")

-- NOCLIP SENSOR (BIAR NOCLIP WORK)
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    wait(0.5)
    if noclip then toggleNoclip(true) end
    if fly then toggleFly(true) end
end)
