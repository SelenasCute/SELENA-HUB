--[[ VARIABLE & SERVICES ]]
local icon = "rbxassetid://140413750237602"
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local function Notif(title, message)
    local old = CoreGui:FindFirstChild("SelenaNotifGui")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SelenaNotifGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local fr = Instance.new("Frame", gui)
    fr.AnchorPoint = Vector2.new(0.5, 0)
    fr.Position = UDim2.new(0.5, 0, 0, -80)
    fr.Size = UDim2.new(0, 280, 0, 60)
    fr.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    fr.BorderSizePixel = 0
    fr.ClipsDescendants = true
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", fr)
    st.Thickness = 1
    st.Color = Color3.fromRGB(50, 50, 50)

    local ic = Instance.new("ImageLabel", fr)
    ic.BackgroundTransparency = 1
    ic.Size = UDim2.new(0, 28, 0, 28)
    ic.Position = UDim2.new(0, 10, 0.5, -14)
    ic.Image = icon
    ic.ImageTransparency = 0.05

    local ttl = Instance.new("TextLabel", fr)
    ttl.BackgroundTransparency = 1
    ttl.Position = UDim2.new(0, 45, 0, 8)
    ttl.Size = UDim2.new(1, -50, 0, 20)
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 16
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.TextColor3 = Color3.new(1, 1, 1)
    ttl.Text = title

    local msg = Instance.new("TextLabel", fr)
    msg.BackgroundTransparency = 1
    msg.Position = UDim2.new(0, 45, 0, 30)
    msg.Size = UDim2.new(1, -50, 0, 20)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 14
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextColor3 = Color3.fromRGB(180, 180, 180)
    msg.Text = message

    -- Animasi masuk
    TweenService:Create(fr, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()

    task.wait(2.5)

    -- Animasi keluar (FIXED)
    local tweenOut = TweenService:Create(fr, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0, -80)
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        gui:Destroy()
    end)
end

local SupportedGames = {
    [121864768012064] = "https://raw.githubusercontent.com/SelenasCute/PHOENIX-HUB/main/FISH_IT.lua",
}

--// Loader
local id = game.PlaceId
local url = SupportedGames[id]

if url then
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(id)
    end)
    local gName = ok and info.Name or "Unknown Game"

    print("Phoenix HUB | Game Detected:", gName)
    Notif("Phoenix HUB", "Loading " .. gName .. "...")

    task.wait(1)

    local okLoad, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if okLoad then
        Notif("Phoenix HUB", "Successfully Loaded " .. gName)
    else
        Notif("Phoenix HUB", "Error: Failed to Load Script")
        warn("❌ Load Error:", err)
    end
else
    warn("⚠️ Phoenix HUB | Game Not Supported:", id)
    Notif("Phoenix HUB", "This Game is Not Supported")
end

