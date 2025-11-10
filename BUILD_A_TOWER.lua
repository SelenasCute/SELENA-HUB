-- ====================================================================
--                      Universal Script Template
--                      Customizable for Any Game
-- ====================================================================

local SCRIPT_NAME = "Selena HUB - Build A Tower"
local VERSION = 1.0
local DISCORD_LINK = "discord.gg/yourlink"
local ATTRIBUTE_NAME = "SelenaHUB" -- Konsisten untuk semua fitur

-- ====== CRITICAL DEPENDENCY VALIDATION ======
local success, errorMsg = pcall(function()
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
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
    error("[" .. SCRIPT_NAME .. "] Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Player = Players.LocalPlayer

-- ====================================================================
--                        MODULES
-- ====================================================================
local Modules = {
    Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Player.lua"))()
}

-- ====================================================================
--                        CONFIGURATION
-- ====================================================================
local DefaultConfig = {
    -- Main
    EzSteal = false,

    -- ESP 
    HideAllBillboards = false,
    BrainrotESP = false,
    LockBaseESP = false,
    PlayerESP = false,

    -- Player Settings
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    
    -- Graphics Settings
    FPSBoost = false,
    LowGraphics = false,
    Disable3DRendering = false,
    AntiAFK = false,
    
    -- UI Settings
    UIToggleKey = "RightShift"
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- ====================================================================
--                     UTILITY FUNCTIONS
-- ====================================================================
function Cleanup()
    for k, v in pairs(DefaultConfig) do
        Config[k] = typeof(v) == "table" and table.clone(v) or v
    end
    
    -- Cleanup semua connections
    if EzStealConnections then
        for _, conn in ipairs(EzStealConnections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        EzStealConnections = {}
    end
    
    if PlayerAddedConnection then
        PlayerAddedConnection:Disconnect()
        PlayerAddedConnection = nil
    end
    
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
    
    if ConfigManager then
        ConfigManager:Delete("default")
        ConfigManager:CreateConfig("default"):Save()
    end
    Notify("Cleanup", "All settings reset to default.", "trash")
end

local function Notify(title, content, icon, duration)
    duration = duration or 3
    icon = icon or "info"
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

-- ====================================================================
--                        GAME FUNCTIONS
-- ====================================================================

-- Player Functions
local function GetAllPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(names, plr.Name) end
    end
    return names
end

local function RefreshPlayersDropdown(dropdown)
    local newList = GetAllPlayerNames()
    dropdown:SetValues(newList)
    Notify("Refresh player list", "Successfully Refreshed player list", "refresh-ccw")
end

local function TeleportToPlayerByName(name)
    if not name then warn("No player selected!") return end
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local pchar = Player.Character
        if pchar and pchar:FindFirstChild("HumanoidRootPart") then
            pchar.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,5,0)
            Notify("Teleport to "..target.Name, "Successfully Teleported to selected player", "users")
        end
    end
end

-- Graphics Functions
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

            blackFrame = Instance.new("Frame")
            blackFrame.Size = UDim2.new(1, 0, 1, 0)
            blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
            blackFrame.BorderSizePixel = 0
            blackFrame.BackgroundTransparency = 0
            blackFrame.ZIndex = 0
            blackFrame.Parent = gui

            local v1 = Instance.new("TextLabel")
            v1.Size = UDim2.new(0.7, 0, 0.7, 0)
            v1.AnchorPoint = Vector2.new(0.5, 0.5)
            v1.Position = UDim2.new(0.5, 0, 0.5, 0)
            v1.BackgroundTransparency = 1
            v1.Text = SCRIPT_NAME
            v1.TextColor3 = Color3.fromRGB(255, 255, 255)
            v1.TextScaled = true
            v1.Font = Enum.Font.GothamBold
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
    Config.UIToggleKey = key
    Window:SetToggleKey(Enum.KeyCode[key])
    Notify("UI Toggle", "UI toggle key set to " .. key, "keyboard")
end

local function RejoinServer()
    Notify("Rejoining", "Rejoining current server...", "refresh-cw")
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local function ToggleBaseESP(state)
    Config.LockBaseESP = state

    if state == true then
        Notify("Lock Base ESP", "Enabled Lock Base ESP", "check")

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "Base" then
                local laser = obj:FindFirstChild("Lasers")
                if laser and laser:FindFirstChild("LockTimer") then
                    local u1 = laser.LockTimer
                    u1.Enabled = true
                    if u1:IsA("BillboardGui") then
                        u1.Size = UDim2.new(30, 0, 30, 0)
                        u1.AlwaysOnTop = true
                        u1.MaxDistance = math.huge
                        u1:SetAttribute(ATTRIBUTE_NAME, true)
                    elseif u1:IsA("Highlight") then
                        u1.FillTransparency = 0.3
                        u1.OutlineTransparency = 0
                        u1.FillColor = Color3.new(1, 0.4, 0.4)
                        u1.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                end
            end
        end

    else
        Notify("Lock Base ESP", "Disabled Lock Base ESP", "xmark")

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "Base" then
                local laser = obj:FindFirstChild("Lasers")
                if laser and laser:FindFirstChild("LockTimer") then
                    local u1 = laser.LockTimer
                    u1.Enabled = true

                    if u1:IsA("BillboardGui") then
                        u1.Size = UDim2.new(30, 0, 30, 0)
                        u1.AlwaysOnTop = false
                        u1.MaxDistance = 50
                        u1:SetAttribute(ATTRIBUTE_NAME, true)
                    elseif u1:IsA("Highlight") then
                        u1.FillTransparency = 0.6
                        u1.OutlineTransparency = 0.4
                        u1.DepthMode = Enum.HighlightDepthMode.Occluded
                    end
                end
            end
        end
    end
end

local ESPPlayers = {}
local PlayerAddedConnection

local function TogglePlayerESP(state)
    Config.PlayerESP = state

    if state then
        Notify("Player ESP", "Enabled Player ESP", "eye")

        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                local function addESP(char)
                    if char then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "PlayerESP"
                        highlight.Adornee = char
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.FillColor = Color3.fromRGB(100, 200, 255)
                        highlight.FillTransparency = 0.4
                        highlight.OutlineTransparency = 0
                        highlight.Parent = char

                        ESPPlayers[plr] = highlight
                    end
                end

                if plr.Character then
                    addESP(plr.Character)
                end
                
                plr.CharacterAdded:Connect(function(char)
                    if Config.PlayerESP then
                        addESP(char)
                    end
                end)
            end
        end

        PlayerAddedConnection = game.Players.PlayerAdded:Connect(function(plr)
            if Config.PlayerESP then
                plr.CharacterAdded:Connect(function(char)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP"
                    highlight.Adornee = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 0, 255)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                    
                    ESPPlayers[plr] = highlight
                end)
            end
        end)

    else
        Notify("Player ESP", "Disabled Player ESP", "xmark")

        if PlayerAddedConnection then
            PlayerAddedConnection:Disconnect()
            PlayerAddedConnection = nil
        end

        for plr, esp in pairs(ESPPlayers) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        ESPPlayers = {}
    end
end

local function HideAllBillboards(state)
    local count = 0
    
    if state == true then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                if not obj:GetAttribute(ATTRIBUTE_NAME) then
                    obj.Enabled = false
                    count = count + 1
                end           
            end
        end
        Notify("Hide Billboards", "Hidden " .. count .. " billboards", "eye-off")
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                if not obj:GetAttribute(ATTRIBUTE_NAME) then
                    obj.Enabled = true
                    count = count + 1
                end           
            end
        end
        Notify("Show Billboards", "Shown " .. count .. " billboards", "eye")
    end
end

local function InstantPrompt()
    local count = 0
    for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v.ClassName == "ProximityPrompt" then
            v.HoldDuration = 0
            count = count + 1
        end
    end
    return count
end

local function ToggleBrainrotESP(state)
    if state == true then
        Notify("Brainrot ESP", "Enabled Brainrot ESP", "eye")

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "RunwayBGUINew" then
                if obj:IsA("BillboardGui") and obj.Parent.Parent.Parent.Name == "BrainrotPlots" then
                    obj.Enabled = true
                    obj.ResetOnSpawn = false
                    obj.MaxDistance = math.huge
                    obj.Size = UDim2.new(60, 0, 60, 0)
                end
            end
        end

    else
        Notify("Brainrot ESP", "Disabled Brainrot ESP", "xmark")

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "RunwayBGUINew" then
                if obj:IsA("BillboardGui") and obj.Parent.Parent.Parent.Name == "BrainrotPlots" then
                    obj.Enabled = true
                    obj.ResetOnSpawn = false
                    obj.MaxDistance = 125
                    obj.Size = UDim2.new(6, 0, 4.5, 0)
                end
            end
        end
    end
end

-- ====================================================================
--                         EZ STEAL FEATURE
-- ====================================================================
local EzStealConnections = {}

local function FindPlayerBase()
    task.wait(0.5) -- Tunggu untuk memastikan workspace sudah loaded
    
    for _, base in ipairs(workspace:GetChildren()) do
        if base:GetAttribute("owner") and base:GetAttribute("owner") == Player.UserId then
            local btn = base:FindFirstChild("OwnerSpawn") 
            if btn then
                return btn.CFrame
            end
        end
    end
    return nil
end

local function ToggleEzSteal(state)
    Config.EzSteal = state

    if state then
        Notify("Ez Steal", "Finding your base...", "search")
        
        local plrBaseLock = FindPlayerBase()
        
        if not plrBaseLock then
            Notify("Ez Steal", "Could not find your base! Make sure you own a base.", "alert-triangle")
            return
        end

        Notify("Ez Steal", "Enabled Ez Steal - Base found!", "check")

        for _, prompt in ipairs(workspace:GetDescendants()) do
           if prompt:IsA("ProximityPrompt") and prompt.ObjectText and (prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Parent and prompt.Parent.Parent.Parent:GetAttribute("owner") ~= Player.UserId) then
                prompt.MaxActivationDistance = 999
                prompt.HoldDuration = 0

                local conn = prompt.Triggered:Connect(function(plr)
                    if plr == Player then
                        local char = Player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            -- Teleport ke item
                            local originalCFrame = hrp.CFrame
                            hrp.CFrame = prompt.Parent.CFrame
                            task.wait(5)
                            
                            -- Kembali ke base
                            if plrBaseLock then
                                hrp.CFrame = plrBaseLock * CFrame.new(0, 5, 0)
                            else
                                hrp.CFrame = originalCFrame
                            end
                        end
                    end
                end)

                table.insert(EzStealConnections, conn)
            end
        end

        -- Monitor untuk prompt baru yang muncul
        local newPromptConn = workspace.DescendantAdded:Connect(function(obj)
            if Config.EzSteal and obj:IsA("ProximityPrompt") and obj.ObjectText ~= nil then
                task.wait(0.1)
                obj.MaxActivationDistance = 999
                obj.HoldDuration = 0

                local conn = obj.Triggered:Connect(function(plr)
                    if plr == Player then
                        local char = Player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and obj.Parent and obj.Parent:IsA("BasePart") then
                            local originalCFrame = hrp.CFrame
                            hrp.CFrame = obj.Parent.CFrame
                        end
                    end
                end)

                table.insert(EzStealConnections, conn)
            end
        end)
        
        table.insert(EzStealConnections, newPromptConn)

    else
        Notify("Ez Steal", "Disabled Ez Steal", "xmark")

        for _, conn in ipairs(EzStealConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        EzStealConnections = {}
    end
end

-- ====================================================================
--                         MAIN UI INITIALIZATION
-- ====================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = SCRIPT_NAME,
    Icon = "rbxassetid://112969347193102",
    Author = "Your Name",
    Folder = "UniversalScript",
    NewElements = true,
    Size = UDim2.fromOffset(590, 350),
    MinSize = Vector2.new(560, 330),
    MaxSize = Vector2.new(620, 370),
    HideSearchBar = false,
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
})

Window:EditOpenButton({
    Title = SCRIPT_NAME,
    Icon = "rbxassetid://112969347193102",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("000000"), 
        Color3.fromHex("FFFFFF")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({Title = "v" .. VERSION, Icon = "github", Color = Color3.fromHex("#6b31ff")})

-- ====================================================================
--                         CONFIG MANAGER SETUP
-- ====================================================================
local ConfigManager = Window.ConfigManager
local ConfigName = "default"

task.spawn(function()
    task.wait(1)
    local AutoLoadConfig = ConfigManager:CreateConfig("default")
    local success, err = pcall(function()
        AutoLoadConfig:Load()
    end)
    
    if success then
        Notify("Auto Load", "Default configuration loaded successfully!", "check", 3)
    end
end)

-- ====================================================================
--                     ABOUT TAB
-- ====================================================================
local AboutTab = Window:Tab({Title = "About", Icon = "info"})
AboutTab:Select()

local aboutParagraph = AboutTab:Paragraph({
    Title = "Hello, " .. Player.Name .. " 👋",
    Desc = "Welcome to " .. SCRIPT_NAME .. "!<br/>Version: " .. VERSION,
    Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
    ImageSize = 70
})

AboutTab:Space()
AboutTab:Button({
    Title = "Copy Discord Link",
    Icon = "link",
    Callback = function()
        setclipboard(DISCORD_LINK)
        Notify("Discord Link", "Link copied to clipboard!", "link")
    end
})

-- ====================================================================
--                     MAIN TAB
-- ====================================================================
local MainTab = Window:Tab({Title = "Main", Icon = "house"})
local MainSection = MainTab:Section({Title = "Main Feature", Opened = true})

MainSection:Toggle({
    Flag = "EzStealToggle",
    Title = "Ez Steal",
    Desc = "Show brainrot prompt, and teleport to brainrot automatically when prompted",
    Icon = "hand",
    Default = false,
    Callback = function(state)
        ToggleEzSteal(state)
    end
})

-- ====================================================================
--                     VISUAL TAB
-- ====================================================================
local VisualTab = Window:Tab({Title = "Visual", Icon = "eye"})
local ESPSection = VisualTab:Section({Title = "ESP", Opened = true})

ESPSection:Toggle({
    Title = "Hide All GUIs",
    Desc = "Hide all billboard GUIs in the game, except Selena HUB's GUIs\nLock base GUI or brainrot GUI will not be hidden",
    Icon = "eye-off",
    Default = Config.HideAllBillboards,
    Callback = function(state)
        HideAllBillboards(state)
    end
})

ESPSection:Space()

ESPSection:Toggle({
    Flag = "LockBaseESP",
    Title = "Lock Base ESP",
    Desc = "Show lock timers for all bases with enhanced visibility",
    Icon = "lock",
    Default = Config.LockBaseESP,
    Callback = function(state)
        ToggleBaseESP(state)
    end
})

ESPSection:Space()

ESPSection:Toggle({
    Flag = "PlayerESP",
    Title = "Player ESP",
    Desc = "Highlight all players in the game",
    Icon = "users",
    Default = Config.PlayerESP,
    Callback = function(state)
        TogglePlayerESP(state)
    end
})

ESPSection:Space()

ESPSection:Toggle({
    Flag = "BrainrotESP",
    Title = "Brainrot ESP",
    Desc = "Enhanced visibility for Brainrot plots",
    Icon = "brain",
    Default = Config.BrainrotESP,
    Callback = function(state)
        ToggleBrainrotESP(state)
    end
})

-- ====================================================================
--                     PLAYER TAB
-- ====================================================================
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

local MovementSection = PlayerTab:Section({Title = "Movement", Opened = true})
MovementSection:Slider({
    Flag = "SpeedSlider",
    Title = "Walk Speed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = Config.WalkSpeed
    },
    Callback = function(value)
        Config.WalkSpeed = value
        Modules.Player.SetWalkSpeed(value)
    end
})

MovementSection:Space()

MovementSection:Slider({
    Flag = "JumpSlider",
    Title = "Jump Power",
    Step = 1,
    Value = {
        Min = 50,
        Max = 300,
        Default = Config.JumpPower
    },
    Callback = function(value)
        Config.JumpPower = value
        Modules.Player.SetJumpPower(value)
    end
})

MovementSection:Space()

MovementSection:Toggle({
    Flag = "InfiniteJumpToggle",
    Title = "Infinite Jump",
    Default = Config.InfiniteJump,
    Callback = function(state)
        Config.InfiniteJump = state
        Modules.Player.ToggleInfiniteJump(state)
    end
})

MovementSection:Space()

MovementSection:Toggle({
    Flag = "NoClipToggle",
    Title = "NoClip",
    Default = Config.NoClip,
    Callback = function(state)
        Config.NoClip = state
        Modules.Player.ToggleNoClip(state)
    end
})

local FlySection = PlayerTab:Section({Title = "Fly", Opened = true})
FlySection:Toggle({
    Flag = "Fly",
    Title = "Toggle Fly",
    Default = Config.Fly,
    Callback = function(state)
        Config.Fly = state
        Modules.Player.ToggleFly(state)
    end
})

FlySection:Space()

FlySection:Slider({
    Flag = "FlySlider",
    Title = "Set Fly Speed",
    Step = 1,
    Value = {
        Min = 50,
        Max = 300,
        Default = Config.FlySpeed
    },
    Callback = function(value)
        Config.FlySpeed = value
        Modules.Player.SetFlySpeed(value)
    end
})

FlySection:Space()

FlySection:Button({
    Flag = "FlyMobile",
    Title = "Fly GUI",
    Desc = "Fly GUI works for all devices",
    Callback = function()
        Notify("Fly UI", "Opening Fly UI", "plane")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))()
    end
})

-- ====================================================================
--                       SETTINGS TAB
-- ====================================================================
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})

-- UI SETTINGS
local UISection = SettingsTab:Section({Title = "UI Settings", Opened = true})
UISection:Keybind({
    Flag = "UIKeybind",
    Title = "UI Toggle Key",
    Value = Config.UIToggleKey,
    Callback = SetToggleKey
})

UISection:Space()

UISection:Button({
    Title = "Destroy UI",
    Icon = "shield-off",
    Callback = function()
        Window:Destroy()
    end
})

-- GAME SETTINGS
local GameSection = SettingsTab:Section({Title = "Game Settings", Opened = true})
GameSection:Toggle({
    Flag = "FPSBoostToggle",
    Title = "FPS Boost",
    Desc = "Boost performance by reducing quality",
    Default = Config.FPSBoost,
    Callback = ToggleFPSBoost
})

GameSection:Space()

GameSection:Toggle({
    Flag = "LowGraphicToggle",
    Title = "Low Graphics",
    Desc = "Reduce graphics quality for better performance",
    Default = Config.LowGraphics,
    Callback = ToggleLowGraphics
})

GameSection:Space()

GameSection:Toggle({
    Flag = "Disable3DRendering",
    Title = "Disable 3D Rendering",
    Desc = "Show only black screen with script name (Best FPS)",
    Default = Config.Disable3DRendering,
    Callback = Toggle3DRenderingDisable
})

GameSection:Space()

GameSection:Toggle({
    Flag = "AntiAFKToggle",
    Title = "Anti AFK",
    Desc = "Prevents being kicked for inactivity",
    Default = Config.AntiAFK,
    Callback = ToggleAntiAFK
})

-- SERVER HOPPING
local ServerHoppingSection = SettingsTab:Section({Title = "Server Hopping", Opened = true})
ServerHoppingSection:Button({
    Title = "Rejoin Server",
    Icon = "refresh-cw",
    Desc = "Rejoin the current server",
    Callback = RejoinServer
})

-- CONFIG MANAGER
local ConfigTab = SettingsTab:Section({Title = "Config Manager", Opened = true})
ConfigTab:Input({
    Flag = "ConfigNameInput",
    Title = "Config Name",
    Icon = "file-cog",
    Placeholder = "Enter config name...",
    Value = ConfigName,
    Callback = function(value)
        ConfigName = value
    end
})

ConfigTab:Space()

local AllConfigs = ConfigManager:AllConfigs()
local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil

local ConfigDropdown = ConfigTab:Dropdown({
    Flag = "AllConfigsDropdown",
    Title = "All Configs",
    Desc = "Select existing configs",
    Values = AllConfigs,
    Value = DefaultValue,
    Callback = function(value)
        ConfigName = value
    end
})

ConfigTab:Space()

ConfigTab:Button({
    Title = "Save Config",
    Icon = "save",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        if Window.CurrentConfig:Save() then
            Notify("Config Saved", "Config '" .. ConfigName .. "' saved successfully!", "check")
            local newConfigs = ConfigManager:AllConfigs()
            ConfigDropdown:SetValues(newConfigs)
        else
            Notify("Save Failed", "Failed to save config '" .. ConfigName .. "'", "x")
        end
    end
})

ConfigTab:Space()

ConfigTab:Button({
    Title = "Load Config",
    Icon = "folder",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        local success, err = pcall(function()
            Window.CurrentConfig:Load()
        end)
        
        if success then
            Notify("Config Loaded", "Config '" .. ConfigName .. "' loaded successfully!", "refresh-cw")
        else
            Notify("Load Failed", tostring(err), "x")
        end
    end
})

ConfigTab:Space()

ConfigTab:Button({
    Title = "Delete Config",
    Icon = "trash",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        if Window.CurrentConfig:Delete() then
            Notify("Config Deleted", "Config '" .. ConfigName .. "' deleted successfully!", "trash")
            local newConfigs = ConfigManager:AllConfigs()
            ConfigDropdown:SetValues(newConfigs)
            Cleanup()
        else
            Notify("Delete Failed", "No file found for: " .. ConfigName, "x")
        end
    end
})

ConfigTab:Space()

ConfigTab:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        local newConfigs = ConfigManager:AllConfigs()
        ConfigDropdown:SetValues(newConfigs)
        Notify("Refreshed", "Config list refreshed successfully!", "refresh-cw")
    end
})

-- ====================================================================
--                       CLEANUP ON DESTROY
-- ====================================================================
Window.OnDestroy(function()
    Cleanup()
end)

-- ====================================================================
--                       FINAL NOTIFICATION
-- ====================================================================
Notify("Script Loaded", SCRIPT_NAME .. " v" .. VERSION .. " loaded successfully!", "check")