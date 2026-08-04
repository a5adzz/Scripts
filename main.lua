-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

-- NEON PURPLE THEME
local PURPLE = Color3.fromHex("#b026ff")

-- Safe GUI Parent
local parent
pcall(function() parent = gethui() end)
parent = parent or game:GetService("CoreGui")

-- Cleanup old
pcall(function()
    for _, n in {"StartupSplash", "patrickGui"} do
        local old = parent:FindFirstChild(n)
        if old then old:Destroy() end
    end
end)

-- =============================================
-- STARTUP SPLASH
-- =============================================
local splash = Instance.new("ScreenGui")
splash.Name = "StartupSplash"
splash.ResetOnSpawn = false
splash.IgnoreGuiInset = true
splash.DisplayOrder = 999999
splash.Parent = parent

local box = Instance.new("Frame")
box.AnchorPoint = Vector2.new(0, 0.5)
box.Position = UDim2.new(0, -420, 0.5, 0)
box.Size = UDim2.new(0, 380, 0, 70)
box.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
box.BackgroundTransparency = 0.15
box.Parent = splash
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", box)
stroke.Thickness = 2
stroke.Color = PURPLE
Instance.new("UIGradient", box).Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18))
}
local text = Instance.new("TextLabel", box)
text.BackgroundTransparency = 1
text.Size = UDim2.new(1, -24, 1, 0)
text.Position = UDim2.new(0, 12, 0, 0)
text.Font = Enum.Font.Code
text.TextSize = 20
text.TextXAlignment = Enum.TextXAlignment.Left
text.Text = "Script made by a5adzz"
text.TextColor3 = PURPLE
Instance.new("UIStroke", text).Color = PURPLE

-- Animate and remove
local tweenIn = TweenService:Create(box, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 24, 0.5, 0)})
local tweenOut = TweenService:Create(box, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0, -420, 0.5, 0)})
tweenIn:Play()
tweenIn.Completed:Connect(function()
    task.wait(4)
    tweenOut:Play()
    tweenOut.Completed:Connect(function() splash:Destroy() end)
end)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9112854440"
sound.Volume = 0.8
sound.Parent = SoundService
sound:Play()
sound.Ended:Connect(function() sound:Destroy() end)

-- =============================================
-- CONFIG — PURE SILENT AIM TO HEAD
-- =============================================
local client = Players.LocalPlayer
getgenv().Radius = 80
getgenv().AimPart = "Head"

-- =============================================
-- VARS
-- =============================================
local CurrentTarget = nil

-- =============================================
-- HELPERS
-- =============================================
local function isAlive(p)
    return p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

-- ALWAYS FIND CLOSEST HEAD INSIDE RADIUS
local function UpdateTarget()
    local best, bestDist = nil, getgenv().Radius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,p in pairs(Players:GetPlayers()) do
        if p == client or not isAlive(p) then continue end
        local part = p.Character:FindFirstChild(getgenv().AimPart)
        if not part then continue end
        local pos,on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = p
        end
    end
    CurrentTarget = best
end

-- =============================================
-- MAIN — NO CAMERA MOVEMENT, SEND EXACT HEAD POS
-- =============================================
RunService.RenderStepped:Connect(UpdateTarget)

local function setupChar(char)
    local function hookTool(tool)
        tool.Activated:Connect(function()
            if not CurrentTarget then return end
            local part = CurrentTarget.Character:FindFirstChild(getgenv().AimPart)
            local evt = game.ReplicatedStorage:FindFirstChild("MAINEVENT")
            if part and evt then
                pcall(function() evt:FireServer("MOUSE", part.Position) end)
            end
        end)
    end
    for _, d in ipairs(char:GetDescendants()) do if d:IsA("Tool") then hookTool(d) end end
    char.DescendantAdded:Connect(function(d) if d:IsA("Tool") then hookTool(d) end end)
end
client.CharacterAdded:Connect(setupChar)
if client.Character then setupChar(client.Character) end

-- =============================================
-- UI — FOV PERFECTLY CENTERED
-- =============================================
local gui = Instance.new("ScreenGui")
gui.Name = "patrickGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

-- WATERMARK: ONLY "a5adzz"
local wm = Instance.new("TextLabel", gui)
wm.Size = UDim2.new(0, 120, 0, 30)
wm.AnchorPoint = Vector2.new(1, 1)
wm.Position = UDim2.new(1, -30, 1, -10)
wm.BackgroundTransparency = 1
wm.Text = "a5adzz"
wm.TextColor3 = PURPLE
wm.Font = Enum.Font.Code
wm.TextSize = 18
wm.TextXAlignment = Enum.TextXAlignment.Right
local wmGlow = Instance.new("UIStroke", wm)
wmGlow.Thickness = 1.5
wmGlow.Color = PURPLE
TweenService:Create(wmGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.6}):Play()

-- FOV CIRCLE — DEAD CENTER
local fov = Instance.new("Frame", gui)
fov.AnchorPoint = Vector2.new(0.5, 0.5)
fov.Position = UDim2.new(0.5, 0, 0.5, 0)
fov.Size = UDim2.fromOffset(getgenv().Radius*2, getgenv().Radius*2)
fov.BackgroundTransparency = 1
Instance.new("UICorner", fov).CornerRadius = UDim.new(0.5,0)
local fovStr = Instance.new("UIStroke", fov)
fovStr.Thickness = 2
fovStr.Color = PURPLE

RunService.RenderStepped:Connect(function()
    fov.Size = UDim2.fromOffset(getgenv().Radius*2, getgenv().Radius*2)
end)
