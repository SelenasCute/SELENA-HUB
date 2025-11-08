--[[
    Selena HUB Universal Loader
    Supported Games:
    - Fish It
--]]

local selenaLogo = "rbxassetid://112969347193102" -- Ganti ID logo jika ada logo Selena HUB sendiri
print("Selena HUB Universal Loader")


local function BuatNotifikasi(title, message)
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("SelenaNotifGui") then
        CoreGui.SelenaNotifGui:Destroy()
    end

    local TweenService = game:GetService("TweenService")

    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "SelenaNotifGui"
    NotifGui.Parent = CoreGui
    NotifGui.IgnoreGuiInset = true
    NotifGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Parent = NotifGui
    Frame.AnchorPoint = Vector2.new(0.5, 0)
    Frame.Position = UDim2.new(0.5, 0, 0, -80)
    Frame.Size = UDim2.new(0, 280, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Frame

    local Icon = Instance.new("ImageLabel")
    Icon.Parent = Frame
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 28, 0, 28)
    Icon.Position = UDim2.new(0, 10, 0.5, -14)
    Icon.Image = selenaLogo
    Icon.ImageTransparency = 0.1

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Frame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 45, 0, 8)
    TitleLabel.Size = UDim2.new(1, -50, 0, 20)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Text = title

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Parent = Frame
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Position = UDim2.new(0, 45, 0, 30)
    MessageLabel.Size = UDim2.new(1, -50, 0, 20)
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 14
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    MessageLabel.Text = message

    -- Animasi Slide In
    local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 20)
    })
    tweenIn:Play()

    task.wait(2.5)

    -- Animasi Slide Out
    local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)), {
        Position = UDim2.new(0.5, 0, 0, -80)
    }
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0, -80)
    }):Play()

    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        NotifGui:Destroy()
    end)
end

-- // Daftar Game Support
local SupportedGames = {
    [121864768012064] = "https://raw.githubusercontent.com/Vinzyy13/VinzHub/refs/heads/main/Fish-It",
    [109983668079237] = "https://raw.githubusercontent.com/Vinzyy13/VinzHub/refs/heads/main/Restaurant-Tycoon-2",
}

-- // Loader Logic
local PlaceId = game.PlaceId
local URL = SupportedGames[PlaceId]

if URL then
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(PlaceId)
    end)
    local gameName = success and info.Name or "Unknown Game"

    print("✅ Selena HUB | Game Detected:", gameName)
    BuatNotifikasi("Selena HUB", "Loading " .. gameName .. "...")

    task.wait(1)

    local successLoad, err = pcall(function()
        loadstring(game:HttpGet(URL))()
    end)

    if successLoad then
        BuatNotifikasi("Selena HUB", "Successfully Loaded " .. gameName)
    else
        BuatNotifikasi("Selena HUB", "Error: Failed to Load Script")
        warn("❌ Load Error:", err)
    end
else
    warn("⚠️ Selena HUB | Game Not Supported:", PlaceId)
    BuatNotifikasi("Selena HUB", "This Game is Not Supported")
end
