--[[ INORYA XELEBOT - ROBLOX SCRIPT (GITHUB RAW READY) ]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()

-- Variabel
local fly = false
local noclip = false
local esp = false
local aimbot = false
local speed = 1
local bodyVel = nil
local noclipPart = nil

-- GUI Creator
local function CreateGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "InoryaX"
    sg.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BorderSizePixel = 0
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    title.Text = "⚡ INORYA XELEBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame

    local toggles = {
        {name = "Fly", var = "fly"},
        {name = "NoClip", var = "noclip"},
        {name = "ESP", var = "esp"},
        {name = "Aimbot", var = "aimbot"}
    }

    for i, btn in ipairs(toggles) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.85, 0, 0, 40)
        b.Position = UDim2.new(0.075, 0, 0.12 + (i-1)*0.14, 0)
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        b.Text = btn.name .. " [OFF]"
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 15
        b.Parent = frame

        b.MouseButton1Click:Connect(function()
            if btn.var == "fly" then
                fly = not fly
                b.Text = fly and "Fly [ON]" or "Fly [OFF]"
                if fly then
                    bodyVel = Instance.new("BodyVelocity")
                    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bodyVel.Parent = char.HumanoidRootPart
                else
                    bodyVel:Destroy()
                end
            elseif btn.var == "noclip" then
                noclip = not noclip
                b.Text = noclip and "NoClip [ON]" or "NoClip [OFF]"
                if noclip then
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
                    noclipPart:Destroy()
                end
            elseif btn.var == "esp" then
                esp = not esp
                b.Text = esp and "ESP [ON]" or "ESP [OFF]"
                -- (ESP logic simple - lo bisa tambahin sendiri)
            elseif btn.var == "aimbot" then
                aimbot = not aimbot
                b.Text = aimbot and "Aimbot [ON]" or "Aimbot [OFF]"
            end
        end)
    end

    -- Speed slider
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.85, 0, 0, 30)
    speedLabel.Position = UDim2.new(0.075, 0, 0.75, 0)
    speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    speedLabel.Text = "Speed: 1x"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 14
    speedLabel.Parent = frame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.4, 0, 0, 30)
    speedBox.Position = UDim2.new(0.3, 0, 0.82, 0)
    speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedBox.Text = "1"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextSize = 14
    speedBox.Parent = frame
    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val then
            speed = val
            speedLabel.Text = "Speed: " .. val .. "x"
        end
    end)

    -- Close
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0.2, 0, 0, 30)
    close.Position = UDim2.new(0.8, 0, 0.9, 0)
    close.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)
end

-- Main loop
game:GetService("RunService").Stepped:Connect(function()
    if char and char.HumanoidRootPart then
        if fly and bodyVel then
            local dir = (mouse.Hit.Position - char.HumanoidRootPart.Position).Unit
            bodyVel.Velocity = Vector3.new(dir.X * 10, (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) and 10 or 0), dir.Z * 10)
        end
        if char.Humanoid then
            char.Humanoid.WalkSpeed = 16 * speed
        end
    end
end)

CreateGUI()
print("✅ INORYA XELEBOT LOADED FROM GITHUB RAW!")
