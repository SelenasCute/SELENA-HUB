-- ====================================================================
--                      Selena HUB | Fish it
--                      Last Update 11/4/2025
-- ====================================================================

--[[]]
local GAME = "Selena HUB | Fish It"
local VERSION = 1.1
local DISCORD_LINK = "discord.gg/selenahub"

-- ====== CRITICAL DEPENDENCY VALIDATION ======
local success, errorMsg = pcall(function()
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService")
    }
    
    for serviceName, service in pairs(services) do
        if not service then
            error("Critical service missing: " .. serviceName)
        end
    end
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not available")
    end
    
    return true
end)

if not success then
    error("❌ [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local leaderstats = Player:FindFirstChild("leaderstats")

-- ====================================================================
--                        MODULES
-- ====================================================================
local Modules = {
    Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Player.lua"))(),
}
-- ====================================================================
--                        CONFIGURATION
-- ====================================================================

local DefaultConfig = {
    AutoSummit = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    WalkOnWater = false,
    Fly = false,
    FlySpeed = 100,
    FPSBoost = false,
    LowGraphics = false,
    Disable3DRendering = false,

}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end


-- ====================================================================
--                     NOTIFICATION
-- ====================================================================

local function Notify(title: string, content: string, icon: string, duration: number)
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

-- ====================================================================
--                     NETWORK EVENTS
-- ====================================================================
local function getNetworkEvents()

end

local Events = getNetworkEvents()

-- ====================================================================
--                     TELEPORT SYSTEM (from dev1.lua)
-- ====================================================================
local Teleport = {}

function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then
        warn("❌ [Teleport] Location not found: " .. tostring(locationName))
        return false
    end
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        rootPart.CFrame = cframe
        print("✅ [Teleport] Moved to " .. locationName)
    end)
    
    return success
end


-- ====================================================================
--                        SETTINGS
-- ====================================================================

-- // 🔔 NOTIFY HANDLER
local function NotifySafe(title, content, icon)
	if Notify then
		Notify(title, content, icon)
	else
		warn(("[Notify] %s: %s"):format(title, content))
	end
end

-- // 💥 DESTROY UI
local function DestroyUI()
	if Window and type(Window.Destroy) == "function" then
		Window:Destroy()
		NotifySafe("UI Closed", "Successfully destroyed WindUI interface.", "shield-off")
	else
		NotifySafe("Error", "UI window not found or already closed.", "xmark")
	end
end

-- // 🔁 REJOIN SERVER
local function RejoinServer()
	NotifySafe("Rejoining", "Rejoining current server...", "refresh-cw")
	task.wait(1)
	game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end

-- // 💤 ANTI AFK
local AntiAFKConnection
local function ToggleAntiAFK(state)
	local vu = game:GetService("VirtualUser")
	local player = game.Players.LocalPlayer

	if state then
		NotifySafe("Anti AFK", "Enabled Anti AFK system.", "check")
		AntiAFKConnection = player.Idled:Connect(function()
			vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
	else
		NotifySafe("Anti AFK", "Disabled Anti AFK system.", "xmark")
		if AntiAFKConnection then
			AntiAFKConnection:Disconnect()
			AntiAFKConnection = nil
		end
	end
end

local function DestroyUI()
	if Window and type(Window.Destroy) == "function" then
		Window:Destroy()
		Notify("UI Closed", "Successfully destroyed WindUI interface.", "shield-off")
	else
		Notify("Error", "UI window not found or already closed.", "xmark")
	end
end

local function RejoinServer()
	Notify("Rejoining", "Rejoining current server...", "refresh-cw")
	task.wait(0.5)
	game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local function ToggleFPSBoost(state)
    Config.FPSBoost = state
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if state then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                pcall(function() v.Enabled = false end)
            end
        end
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
    else
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                pcall(function() v.Enabled = true end)
            end
        end
        if Terrain then
            Terrain.WaterWaveSize = 0.05
            Terrain.WaterWaveSpeed = 8
            Terrain.WaterReflectance = 1
            Terrain.WaterTransparency = 0.3
        end
    end
end

local AntiAFKConnection
local function ToggleAntiAFK(state)
	Config.AntiAFK = state
	local vu = game:GetService("VirtualUser")
	local player = game.Players.LocalPlayer

	if state then
		AntiAFKConnection = player.Idled:Connect(function()
			vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
	else
		if AntiAFKConnection then
			AntiAFKConnection:Disconnect()
			AntiAFKConnection = nil
		end
	end
end

local function ToggleLowGraphics(state)
    Config.LowGraphics = state
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                pcall(function() v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end)
            end
            if v:IsA("Decal") or v:IsA("Texture") then pcall(function() v.Transparency = 1 end) end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then pcall(function() v.Transparency = 0 end) end
        end
    end
end

local blackFrame
local function Toggle3DRenderingDisable(state)
    Config.Disable3DRendering = state
    if state then
        RunService:Set3dRenderingEnabled(false)
        if not blackFrame then
            local gui = Instance.new("ScreenGui")
            gui.Name = "BlackoutGui"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.DisplayOrder = -99999
            gui.Parent = Player:WaitForChild("PlayerGui")

            -- FRAME
            blackFrame = Instance.new("Frame")
            blackFrame.Size = UDim2.new(1, 0, 1, 0)
            blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
            blackFrame.BorderSizePixel = 0
            blackFrame.BackgroundTransparency = 0
            blackFrame.ZIndex = 0
            blackFrame.Parent = gui

            -- TEXT
            local v1 = Instance.new("TextLabel")
            v1.Size = UDim2.new(0.7, 0, 0.7, 0)
            v1.AnchorPoint = Vector2.new(0.5, 0.5)
            v1.Position = UDim2.new(0.5, 0, 0.5, 0)
            v1.BackgroundTransparency = 1
            v1.Text = "SELENA HUB"
            v1.TextColor3 = Color3.fromRGB(255, 255, 255)
            v1.TextScaled = true
            v1.Font = Enum.Font.GothamBold -- font tebal & modern
            v1.ZIndex = 1
            v1.Parent = blackFrame

        else
            blackFrame.Visible = true
        end
    else
        RunService:Set3dRenderingEnabled(true)
        if blackFrame then blackFrame.Visible = false end
    end
end

local function SetToggleKey(key)
	Window:SetToggleKey(Enum.KeyCode[key])
	Notify("UI Toggle", "UI toggle key set to " .. key, "keyboard")
end

-- ====================================================================
--                         //NOTE MAIN UI
-- ====================================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local OpenButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Library/OpenButton.lua"))()
local Window = WindUI:CreateWindow({
    Title = GAME,
    Icon = "rbxassetid://112969347193102",
    Author = "Discord.gg/selenaHub",
    Folder = "Selenahub",
    NewElements = true,
    Size = UDim2.fromOffset(590, 350),
    MinSize = Vector2.new(560, 330),
    MaxSize = Vector2.new(620, 370),
    HideSearchBar = false,
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "rbxassetid://138742999874945",
    BackgroundImageTransparency = 0.9,
})
OpenButton.Create(Window)
Window:Tag({Title = "v" .. VERSION, Icon = "github", Color = Color3.fromHex("#6b31ff")})
local function Notify(title: string, content: string, icon: string, duration: number)
    duration = duration or 3
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

Notify("Selena HUB Executed", "Press [RightShift] to open/close UI", "check")

-- ====================================================================
--                         //ANCHOR ABOUT TAB
-- ==================================================================== //tab1
local AboutTab = Window:Tab({Title = "About", Icon = "info"})
AboutTab:Select()

local aboutParagraph = AboutTab:Paragraph({
    Title = "Hello, " .. Player.Name .. " 👋", 
    Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420), 
    ImageSize = 70, 
    Locked = false
})

local DiscordSection = AboutTab:Section({Title = "Join our discord", Opened = true})
DiscordSection:Button({Title = "Copy Discord Link", Icon = "link", Color = Color3.fromHex("#5865F2"), Callback = CopyDiscordLink})

-- ====================================================================
--                         //ANCHOR MAIN TAB
-- ==================================================================== //tab2
local MainTab = Window:Tab({Title = "Main", Icon = "house"})

local checkpoint = {
    ["Spawn"] = CFrame.new(-718.088379, 1978.024414, 5365.936523, -0.061904, 0.000000, 0.998082, 0.000000, 1.000000, -0.000000, -0.998082, -0.000000, -0.061904),
    ["Area 1"] = CFrame.new(-225.961075, 442.024597, 2140.634033, 0.012784, -0.000000, -0.999918, 0.000000, 1.000000, -0.000000, 0.999918, -0.000000, 0.012784),
    ["Area 2"] = CFrame.new(-424.295105, 850.024597, 3204.946533, -0.439290, -0.000000, -0.898345, 0.000000, 1.000000, -0.000000, 0.898345, -0.000000, -0.439290),
    ["Area 3"] = CFrame.new(41.666550, 1270.024414, 4042.483154, -0.685106, 0.000000, 0.728444, 0.000000, 1.000000, -0.000000, -0.728444, -0.000000, -0.685106),
    ["Area 4"] = CFrame.new(-1143.418213, 1554.024414, 4901.778320, -0.987211, -0.000000, -0.159418, 0.000000, 1.000000, -0.000000, 0.159418, -0.000000, -0.987211),
    ["Area 5"] = CFrame.new(-718.088379, 1978.024414, 5365.936523, -0.061904, 0.000000, 0.998082, 0.000000, 1.000000, -0.000000, -0.998082, -0.000000, -0.061904)

}

local AutoSummitSection = MainTab:Section({Title = "Auto Summit", Opened = true})
AutoSummitSection:Toggle({Flag = "AutoSummitToggle", Title = "Enable Auto Summit", Default = Config.AutoSummit, 
    Callback = function(state)
        if state then
            Notify("Auto Summit", "Auto Summit Enabled", "check")
            end)
        else
            Notify("Auto Summit", "Auto Summit Disabled", "xmark")
        end
    end
})

-- ====================================================================
--                         //ANCHOR PLAYER TAB
-- ==================================================================== //tab4
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

local MovementSection = PlayerTab:Section({Title = "Movement", Opened = true})
MovementSection:Slider({Flag = "SpeedSlider", Title = "Walk Speed", Step = 1, Value = {Min = 16, Max = 200, Default = Config.WalkSpeed}, 
    Callback = function(value)
        Config.WalkSpeed = value
        Modules.Player.SetWalkSpeed(value)
    end
})
MovementSection:Space()
MovementSection:Slider({Flag = "JumpSlider", Title = "Jump Power", Step = 1, Value = {Min = 50, Max = 300, Default = Config.JumpPower}, 
    Callback = function(value)
        Config.JumpPower = value
        Modules.Player.SetJumpPower(value)
    end
})
MovementSection:Space()
MovementSection:Toggle({Flag = "InfiniteJumpToggle", Title = "Infinite Jump", Default = Config.InfiniteJump, 
    Callback = function(state)
        Config.InfiniteJump = state
        Modules.Player.ToggleInfiniteJump(state)
    end
})
MovementSection:Space()
MovementSection:Toggle({Flag = "NoClipToggle", Title = "NoClip", Default = Config.NoClip, 
    Callback = function(state)
        Config.NoClip = state
        Modules.Player.ToggleNoClip(state)
    end
})
MovementSection:Space()
MovementSection:Toggle({Flag = "WalkOnWaterToggle", Title = "Walk on Water", Default = Config.WalkOnWater, 
    Callback = function(state)
        Config.WalkOnWater = state
        Modules.Player.ToggleWalkOnWater(state)
    end
})

local FlySection = PlayerTab:Section({Title = "Fly", Opened = true})
FlySection:Toggle({Flag = "Fly", Title = "Toggle Fly", Default = Config.Fly, 
    Callback = function(state)
        Config.Fly = state
        Modules.Player.ToggleFly(state)
    end
})
FlySection:Space()
FlySection:Slider({Flag = "FlySlider", Title = "Set Fly Speed", Step = 1, Value = {Min = 50, Max = 300, Default = Config.FlySpeed}, 
    Callback = function(value)
        Config.FlySpeed = value
        Modules.Player.SetFlySpeed(value)
    end
})
FlySection:Space()
FlySection:Button({Flag = "FlyMobile", Title = "Fly Gui", Desc = "Fly gui work for all device", Callback = function() 
    Notify("Fly UI", "Opening Fly ui")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))() 
end})

-- ====================================================================
--                         //ANCHOR SETTINGS TAB
-- ==================================================================== //tab5

local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})

-- UI SETTINGS
local UISection = SettingsTab:Section({Title = "UI Settings", Opened = true})
UISection:Keybind({Flag = "UIKeybind", Title = "UI Toggle Key", Value = "RightShift", Callback = SetToggleKey})
UISection:Space()
UISection:Button({Title = "Destroy UI", Icon = "shield-off", Callback = DestroyUI})

-- GAME SETTINGS
local GameSection = SettingsTab:Section({Title = "Game Settings", Opened = true})
GameSection:Toggle({Flag = "FPSBoostToggle", Title = "FPS Boost", Default = Config.FPSBoost, Callback = ToggleFPSBoost})
GameSection:Space()
GameSection:Toggle({Flag = "LowGraphicToggle", Title = "Low Graphics", Default = Config.LowGraphics, Callback = ToggleLowGraphics})
GameSection:Space()
GameSection:Toggle({Flag = "Disable3DRendering", Title = "Disable 3D Rendering", Default = Config.Disable3DRendering, Callback = Toggle3DRenderingDisable})
GameSection:Space()
GameSection:Toggle({Flag = "AntiAFKToggle", Title = "Anti AFK", Default = Config.AntiAFK, Callback = ToggleAntiAFK})