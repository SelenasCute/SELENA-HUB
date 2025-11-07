-- ====================================================================
--                      Selena HUB | Fish it
--                      Last Update 11/4/2025
-- ====================================================================

local GAME = "Selena HUB | Fish It"
local VERSION = 1.1
local LATEST_UPDATE = "11/6/2025"
local DISCORD_LINK = "dsc.gg/selena-hub"

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
    error("circle-x [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
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
local VirtualInputManager = game:GetService("VirtualInputManager")
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
    Location = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Fish%20It/Location.lua"))()
}
-- ====================================================================
--                        CONFIGURATION
-- ====================================================================

local DefaultConfig = {
    AutoSell = false,
    AutoFish = false,
    AutoFishV2 = false,
    AutoFishV2Delay = 2,
    AutoSellDelay = 30,
    FishingRadar = false,
    DivingGear = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    WalkOnWater = false,
    Fly = false,
    FlySpeed = 50,
    FPSBoost = false,
    LowGraphics = false,
    Disable3DRendering = false,
    AntiAFK = false,
    MerchantOpen = false
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- ====================================================================
--                     MAIN FUNCTION
-- ====================================================================

local function parsePrice(text)
    local num, suffix = string.match(text, "%(([%d%.]+)([KkMm]?)%$")
    num = tonumber(num)
    if not num then return 0 end
    if suffix == "K" or suffix == "k" then
        num = num * 1000
    elseif suffix == "M" or suffix == "m" then
        num = num * 1000000
    end
    return num
end

local function Notify(title: string, content: string, icon: string, duration: number)
    icon = icon or "info"
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

local function getNetworkEvents()
    local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    return {
        buybait = net:WaitForChild("RF/PurchaseBait"),
        buyrod = net:WaitForChild("RF/PurchaseFishingRod"),
        buyweather = net:WaitForChild("RF/PurchaseWeatherEvent"),
        buyboat = net:WaitForChild("RF/PurchaseBoat"),
        fishing = net:WaitForChild("RE/FishingCompleted"),
        sell = net:WaitForChild("RF/SellAllItems"),
        charge = net:WaitForChild("RF/ChargeFishingRod"),
        minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
        cancel = net:WaitForChild("RF/CancelFishingInputs"),
        equip = net:WaitForChild("RE/EquipToolFromHotbar"),
        unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
        favorite = net:WaitForChild("RE/FavoriteItem"),
        equipOxygen = net:WaitForChild("RF/EquipOxygenTank"),
        unequipOxygen = net:WaitForChild("RF/UnequipOxygenTank"),
        redeemCode = net:WaitForChild("RF/RedeemCode"),
        updateFishingRadar = net:WaitForChild("RF/UpdateFishingRadar")
    }
end

local Events = getNetworkEvents()

--===== TELEPORT =====--
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
    WindUI:Notify({Title = "Refresh player list", Content = "Successfully Refreshed player list", Icon = "users", Duration = 3})
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
            WindUI:Notify({Title = "Teleport to "..target.Name, Content = "Successfully Teleported to selected player", Icon = "users", Duration = 3})
        end
    end
end

local islandNames = {}
for name in pairs(Modules.Location.LOCATIONS["Island"]) do
table.insert(islandNames, name)
end
table.sort(islandNames)
local selectedIsland = islandNames[1]

local eventNames = {}
for name in pairs(Modules.Location.LOCATIONS["GameEvent"]) do
    table.insert(eventNames, name)
end
table.sort(eventNames)
local selectedEvent = eventNames[1]

local npcNames = {}
for name in pairs(Modules.Location.LOCATIONS["NPC"]) do
    table.insert(npcNames, name)
end
table.sort(npcNames)
local selectedNPC = npcNames[1]

--===== NOTIFY =====--
local function Notify(title: string, content: string, icon: string, duration: number)
    duration = duration or 3
    icon = icon or "rbxassetid://76311199408449"
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

--===== MISC =====--
local function safeInvokeSpecialDialogue(npcName)
    pcall(function()
        local index = ReplicatedStorage:FindFirstChild("Packages")
        if index and index._Index and index._Index["sleitnick_net@0.2.0"] and index._Index["sleitnick_net@0.2.0"].net then
            index._Index["sleitnick_net@0.2.0"].net["RF/SpecialDialogueEvent"]:InvokeServer(npcName, "TrickOrTreat")
        end
    end)
end

local function AutoTrickOrTreat()
    for _, npc in ipairs(game.ReplicatedStorage:WaitForChild("NPC"):GetChildren()) do
        task.wait(0.25)
        if npc:IsA("Model") or npc:IsA("Folder") then
            safeInvokeSpecialDialogue(npc.Name)
        end
    end
    WindUI:Notify({Title = "Auto Trick or Treat", Content = "Auto Trick or Treat successfully completed", Icon = "check", Duration = 3})
end

local function RequestGear(name, state)

    if name == "Oxygen" then
        if state then
            Events.equipOxygen:InvokeServer(105)
        else
            Events.unequipOxygen:InvokeServer()
        end
    elseif name == "Radar" then
        Events.updateFishingRadar:InvokeServer(state)
    end

end

local function RedeemCode()
    local codes = { "CRYSTALS", "BLAMETALON", "SORRY" }

    for _, code in ipairs(codes) do
        Events.redeemCode:InvokeServer(code)
        task.wait(0.5)
        Notify("Redeem Code", "Successfully Redeem Code "..code, "")
    end
end

local function simpleSell()
    print("╔═══════════════════════════════════╗")
    print("[Auto Sell] 💰 Selling all non-favorited items...")
    
    local sellSuccess = pcall(function()
        return Events.sell:InvokeServer()
    end)
    
    if sellSuccess then
        print("[Auto Sell] ✅ SOLD! (Favorited fish kept safe)")
        print("╚═══════════════════════════════════╝")
    else
        warn("[Auto Sell] circle-x Sell failed")
        print("╚═══════════════════════════════════╝")
    end
end

task.spawn(function()
    while true do
        task.wait(Config.AutoSellDelay)
        if Config.AutoSell then
            simpleSell()
        end
    end
end)

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

--===== TASK =====--
task.spawn(function()
    while task.wait(0.15) do
        if Config.AutoFish then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)
task.spawn(function()
    while task.wait() do
        if Config.AutoFishV2 then
            pcall(function()
                -- Step 1: Equip rod
                Events.equip:FireServer(1)
                task.wait(0.05)

                -- Step 2: Cast
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.02)
                Events.minigame:InvokeServer(1.2854545116425, 1)

                -- Step 3: Wait for bite (delay)
                task.wait(Config.AutoFishV2Delay)

                -- Step 4: Reel in
                Events.fishing:FireServer()
                print("[AutoFish V2] 🎣 Caught fish (Delay = " .. Config.AutoFishV2Delay .. "s)")
            end)
        end
    end
end)

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

-- ====== OPEN BUTTON SYSTEM ======
OpenButton.Create(Window)

-- ====== TAG SYSTEM ======
Window:Tag({Title = "v" .. VERSION, Icon = "github", Color = Color3.fromHex("#6b31ff")})

-- ====== CONFIG MANAGER ======
local ConfigManager = Window.ConfigManager
local ConfigName = "default"

-- ====================================================================
--                         //ANCHOR ABOUT TAB
-- ====================================================================

local AboutTab = Window:Tab({Title = "About", Icon = "info"})
AboutTab:Select()

local function stat(name)
	local s = leaderstats:FindFirstChild(name)
	return s and s.Value or "N/A"
end

local function getLevel()
	local ok, label = pcall(function()
		return workspace.Characters[Player.Name].HumanoidRootPart.Overhead.LevelContainer.Label
	end)
	if not ok or not label or not label.Text then return 0 end
	return tonumber(label.Text:match("%d+")) or 0
end

local aboutParagraph = AboutTab:Paragraph({
    Title = "Hello, " .. Player.Name .. " 👋",
    Desc = (('<font color="#ffcc00">Level:</font> %s<br/><font color="#ffcc00">Caught:</font> %s<br/><font color="#ffcc00">Rarest Fish:</font> %s>'):format(getLevel(),stat("Caught"),stat("Rarest Fish"))),
    Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
    ImageSize = 70
})

for _, name in ipairs({"Caught", "Rarest Fish"}) do
    local s = leaderstats:FindFirstChild(name)
    if s then
        s:GetPropertyChangedSignal("Value"):Connect(function()
        aboutParagraph:SetDesc(('<font color="#ffcc00">Level:</font> %s<br/>' ..'<font color="#ffcc00">Caught:</font> %s<br/>' ..'<font color="#ffcc00">Rarest Fish:</font> %s'):format(getLevel(),stat("Caught"),stat("Rarest Fish")))

        end)
    end
end

AboutTab:Space()
AboutTab:Button({
	Title = "Copy Discord Link",
	Icon = "link",
	Callback = function()
		setclipboard(DISCORD_LINK)
		Notify("Discord Link", "Link copied to clipboard!", "rbxassetid://18505728201")
	end
})



-- ====================================================================
--                         //ANCHOR MAIN TAB
-- ==================================================================== //tab2
local MainTab = Window:Tab({Title = "Main", Icon = "house"})

-- AUTO FISH
local AutoFishSection = MainTab:Section({Title = "Auto Fish", Opened = true})
AutoFishSection:Toggle({Flag = "AutoFishv1", Title = "Auto Fish V1", Desc = "Automatically farms fishing while enable", Default = Config.AutoFish,
    Callback = function(state) 
        Config.AutoFish = state
        if state then
            Events.equip:FireServer(1)
        end
    end
})
AutoFishSection:Space()
AutoFishSection:Toggle({ Flag = "AutoFishv2", Title = "Auto Fish V2", Desc = "Better Auto Fish, Delay Suggestion:\nAstral: 2", Default = Config.AutoFishV2,
    Callback = function(state)
        Config.AutoFishV2 = state
    end
})
AutoFishSection:Space()
AutoFishSection:Input({ Title = "Auto Fish V2 Delay (seconds)", Placeholder = "Enter Delay (0.1 - 10)", Value = Config.AutoFishV2Delay,  InputIcon = "fish",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 10 then
            Config.AutoFishV2Delay = num
        else
            Notify("ERROR", "Delay amount must between 0.1 - 10")
        end
    end
})

-- AUTO SELL
local AutoSellSection = MainTab:Section({Title = "Auto Sell", Opened = true})
AutoSellSection:Toggle({Flag = "AutoSellInventory", Title = "Auto Sell Inventory", Desc = "Automatically sell your inventory while enable", Default = Config.AutoSell,
    Callback = function(state) 
        Config.AutoSell = state
    end
})
AutoSellSection:Space()
AutoSellSection:Slider({Flag = "SellDelay", Title = "Sell Delay", Step = 1, Value = {Min = 1, Max = 200, Default = Config.AutoSellDelay}, 
    Callback = function(value) 
        Config.AutoSellDelay = value
    end
})
AutoSellSection:Space()
AutoSellSection:Button({Title = "Auto Sell Once", 
    Callback = function()
        simpleSell()
    end
})

-- EVENT
local EventSection = MainTab:Section({Title = "Event", Opened = true})
EventSection:Button({Flag = "TrickOrTreat", Title = "Auto Trick or Treat", Desc = "Automatically trick or treats", Callback = function() task.spawn(AutoTrickOrTreat) end})

-- MISC
local MiscSection = MainTab:Section({Title = "Misc", Opened = true})
MiscSection:Toggle({Flag = "FishingRadar", Title = "Fishing Radar", Desc = "Turns te fishing radar ON or OFF", Default = Config.FishingRadar, 
    Callback = function(state) 
        Config.FishingRadar = state
        RequestGear("Radar", state)
    end
})
MiscSection:Space()
MiscSection:Toggle({Flag = "DivingGear", Title = "Diving Gear", Desc = "Equip or Unequips Diving Gear", Default = Config.DivingGear, 
    Callback = function(state) 
        Config.DivingGear = state
        RequestGear("Oxygen", state)
    end
})
MiscSection:Space()
MiscSection:Button({Title = "Redeem All Codes",
    Callback = RedeemCode
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
--                         //ANCHOR SHOP TAB
-- ==================================================================== //tab3
local ShopTab = Window:Tab({Title = "Shop", Icon = "store"})
local Shop = {
    ["Bait"] = {
        ["Topwater Bait (100$)"] = {
            Id = 10,
            Icon = "rbxassetid://78313664669418"
        },
        ["Luck Bait (1K$)"] = {
            Id = 2,
            Icon = "rbxassetid://106827914793722"
        },
        ["Midnight Bait (3K$)"] = {
            Id = 3,
            Icon = "rbxassetid://82435085190109"
        },
        ["Nature Bait (83.5K$)"] = {
            Id = 17,
            Icon = "rbxassetid://115616199958924"
        },
        ["Chroma Bait (290K$)"] = {
            Id = 6,
            Icon = "rbxassetid://123495869001051"
        },
        ["Dark Matter Bait (630K$)"] = {
            Id = 8,
            Icon = "rbxassetid://77040147828550"
        },
        ["Corrupt Bait (1.15M$)"] = {
            Id = 15,
            Icon = "rbxassetid://115453224698341"
        },
        ["Aether Bait (3.7M$)"] = {
            Id = 16,
            Icon = "rbxassetid://91317933862702"
        },
        ["Floral Bait (4.00M$)"] = {
            Id = 20,
            Icon = "rbxassetid://80119465171442"
        },
        ["Singularity Bait (8.2M$)"] = {
            Id = 18,
            Icon = "rbxassetid://139381330729877"
        },
    },
    ["Rods"] = {
        ["Luck Rod (350$)"] = {
            Id = 79,
            Icon = "rbxassetid://127110979437680"
        },
        ["Carbon Rod (900$)"] = {
            Id = 76,
            Icon = "rbxassetid://124099699625912"
        },
        ["Grass Rod (1,5K$)"] = {
            Id = 85,
            Icon = "rbxassetid://130802650199282"
        },
        ["Demascus Rod (3K$)"] = {
            Id = 77,
            Icon = "rbxassetid://92202353564703"
        },
        ["Ice Rod (5K$)"] = {
            Id = 78,
            Icon = "rbxassetid://92630142441112"
        },
        ["Lucky Rod (15K$)"] = {
            Id = 4,
            Icon = "rbxassetid://85174841193446"
        },
        ["Midnight Rod (50K$)"] = {
            Id = 80,
            Icon = "rbxassetid://130162999569066"
        },
        ["SteamPunk Rod (215K$)"] = {
            Id = 6,
            Icon = "rbxassetid://0109211472277743"
        },
        ["Chrome Rod (437K$)"] = {
            Id = 7,
            Icon = "rbxassetid://83222944871842"
        },
        ["Fluorescent Rod (715K$)"] = {
            Id = 255,
            Icon = "rbxassetid://83998636831250"
        },
        ["Astral Rod (1M$)"] = {
            Id = 5,
            Icon = "rbxassetid://123734625865292"
        },
        ["Ares Rod (3M$)"] = {
            Id = 126,
            Icon = "rbxassetid://74424529377774"
        },
        ["Angler Rod (8M$)"] = {
            Id = 168,
            Icon = "rbxassetid://76924330674942"
        },
        ["Bambo Rod (12M$)"] = {
            Id = 258,
            Icon = "rbxassetid://95236691549566"
        },
    },
    ["Weather"] = {
        ["Wind (10K$)"] = {
            Id = "Wind",
            Icon = "rbxassetid://83206005633160"
        },
        ["Snow (15K$)"] = {
            Id = "Snow",
            Icon = "rbxassetid://102119250093406"
        },
        ["Cloudy (20K$)"] = {
            Id = "Cloudy",
            Icon = "rbxassetid://72258943070104"
        },
        ["Strom (35K$)"] = {
            Id = "Strom",
            Icon = "rbxassetid://111709787385701"
        },
        ["Radiant (50K$)"] = {
            Id = "Radiant",
            Icon = "rbxassetid://9940992285"
        },
        ["Shark Hunt (300K$)"] = {
            Id = "Shark Hunt",
            Icon = "rbxassetid://74938397479780"
        },                
    },
    ["Boat"] = {
        ["Small Boat (300$)"] = {
            Id = 1,
            Icon = "rbxassetid://73604149951518"
        },
        ["Kayak (1,1K$)"] = {
            Id = 2,
            Icon = "rbxassetid://98871646506689"
        },
        ["Jetski (7,5K$)"] = {
            Id = 3,
            Icon = "rbxassetid://91216671973985"
        },
        ["Highfield Boat (35K$)"] = {
            Id = 4,
            Icon = "rbxassetid://75395154459652"
        },
        ["Speed Boat (70K$)"] = {
            Id = 5,
            Icon = "rbxassetid://140091900313483"
        },
        ["Fishing Boat (180K$)"] = {
            Id = 6,
            Icon = "rbxassetid://117568546918502"
        },
        ["Mini Yacht (1,2M$)"] = {
            Id = 14,
            Icon = "rbxassetid://74219886115935"
        },              
    }
}

-- BUY RODS
local rodList = {}
for name, data in pairs(Shop["Rods"]) do
    table.insert(rodList, {
        Title = name,
        Icon = data.Icon,
        Id = data.Id,
        PriceValue = parsePrice(name)
    })
end

table.sort(rodList, function(a, b)
    return a.PriceValue < b.PriceValue
end)

local selectedRod
local BuyRodSection = ShopTab:Section({ Title = "Buy Rods", Opened = true })
BuyRodSection:Dropdown({ Title = "Select Rod", Values = rodList, Value = rodList[1],
    Callback = function(option)
        selectedRod = option
    end
})
BuyRodSection:Space()
BuyRodSection:Button({ Title = "Buy Selected Rod",
    Callback = function()
        if not selectedRod then
            return
        end
        Events.buyrod:InvokeServer(selectedRod.Id)
        --Notify("Purchase Rod", "Successfully purchased "..selectedRod.Title, selectedRod.Icon)
    end
})


-- BUY BAIT
local baitList = {}
for name, data in pairs(Shop["Bait"]) do
    table.insert(baitList, {
        Title = name,
        Icon = data.Icon,
        Id = data.Id,
        PriceValue = parsePrice(name)
    })
end

table.sort(baitList, function(a, b)
    return a.PriceValue < b.PriceValue
end)

local selectedBait
local BuyBaitSection = ShopTab:Section({ Title = "Buy Bait", Opened = true })
BuyBaitSection:Dropdown({ Title = "Select Bait", Values = baitList, Value = baitList[1],
    Callback = function(option)
        selectedBait = option
    end
})
BuyBaitSection:Space()
BuyBaitSection:Button({ Title = "Buy Selected Bait",
    Callback = function()
        if not selectedBait then
           return 
        end
        Events.buybait:InvokeServer(selectedBait.Id)
        --Notify("Purchase Bait", "Successfully purchased "..selected.Title, selected.Icon)
    end
})

-- BUY Weather
local weatherlist = {}
for name, data in pairs(Shop["Weather"]) do
    table.insert(weatherlist, {
        Title = name,
        Icon = data.Icon,
        Id = data.Id,
        PriceValue = parsePrice(name)
    })
end

table.sort(weatherlist, function(a, b)
    return a.PriceValue < b.PriceValue
end)

local selectedWeather
local BuyWeatherSection = ShopTab:Section({ Title = "Buy Weather", Opened = true })
BuyWeatherSection:Dropdown({ Title = "Select Weather", Values = weatherlist, Value = weatherlist[1],
    Callback = function(option)
        selectedWeather = option
    end
})
BuyWeatherSection:Space()
BuyWeatherSection:Button({ Title = "Buy Selected Weather",
    Callback = function()
        if not selectedWeather then
           return 
        end
        Events.buyweather:InvokeServer(selectedWeather.Id)
        --Notify("Purchase Bait", "Successfully purchased "..selected.Title, selected.Icon)
    end
})

-- BUY Boat
local boatlist = {}
for name, data in pairs(Shop["Boat"]) do
    table.insert(boatlist, {
        Title = name,
        Icon = data.Icon,
        Id = data.Id,
        PriceValue = parsePrice(name)
    })
end

table.sort(boatlist, function(a, b)
    return a.PriceValue < b.PriceValue
end)

local selectedBoat
local BuyBoatSection = ShopTab:Section({ Title = "Buy Boat", Opened = true })
BuyBoatSection:Dropdown({ Title = "Select Boat", Values = boatlist, Value = boatlist[1],
    Callback = function(option)
        selectedBoat = option
    end
})
BuyBoatSection:Space()
BuyBoatSection:Button({ Title = "Buy Selected Boat",
    Callback = function()
        if not selectedBoat then
           return 
        end
        Events.buyboat:InvokeServer(selectedBoat.Id)
    end
})

-- MERCHANT
local function OpenMerchant(state)
    Config.MerchantOpen = state
    pcall(function()
        game:GetService("Players").LocalPlayer.PlayerGui.Merchant.Enabled = state
    end)
end


local MerchantSection = ShopTab:Section({ Title = "Merchant Shop", Opened = true })
MerchantSection:Toggle({ Flag = "OpenMerchantShop", Title = "Open Merchant Shop", Default = Config.MerchantOpen,
    Callback = function(state)
        OpenMerchant(state)
    end
})

-- ====================================================================
--                         //ANCHOR TELEPORT TAB
-- ==================================================================== //tab4
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"})

-- ISLAND TELEPORT
local IslandSection = TeleportTab:Section({ Title = "Island Teleport", Opened = true })
IslandSection:Dropdown({ Title = "Select Island Teleport", Values = islandNames, Value = selectedIsland,
    Callback = function(opt)
        selectedIsland = opt
    end
})
IslandSection:Space()
IslandSection:Button({ Title = "Teleport",
    Callback = function()
        local success, err = Modules.Location.TeleportTo("Island", selectedIsland)
        if success then
            Notify("Teleport", "Teleported to " .. selectedIsland .. " (Island)", "map-pin")
        else
            Notify("Teleport Failed", err, "cancel")
        end
    end
})

-- GAME EVENT TELEPORT
local GameEventSection = TeleportTab:Section({ Title = "Game Event Teleport", Opened = true })
GameEventSection:Dropdown({ Title = "Select Game Event", Values = eventNames, Value = selectedEvent, Callback = function(opt) selectedEvent = opt end })
GameEventSection:Space()
GameEventSection:Button({ Title = "Teleport",
    Callback = function()
        local success, err = Modules.Location.TeleportTo("GameEvent", selectedEvent)
        if success then
            Notify("Teleport", "Teleported to " .. selectedEvent .. " (Game Event)", "map-pin")
        else
            Notify("Teleport Failed", err, "cancel")
        end
    end
})

-- NPC TELEPORT
local NPCSection = TeleportTab:Section({ Title = "NPC Teleport", Opened = true })
NPCSection:Dropdown({ Title = "Select NPC", Values = npcNames, Value = selectedNPC, Callback = function(opt) selectedNPC = opt end})
NPCSection:Space()
NPCSection:Button({ Title = "Teleport",
    Callback = function()
        local success, err = Modules.Location.TeleportTo("NPC", selectedNPC)
        if success then
            Notify("Teleport", "Teleport" .. selectedNPC .. " (NPC)", "map-pin")
        else
            Notify("Teleport Failed", err, "cancel")
        end
    end
})

-- PLAYER TELEPORT
local selectedPlayer = nil
local PlayerTeleportSection = TeleportTab:Section({Title = "Player Teleport", Opened = true})
local PlayerTeleport_1 = PlayerTeleportSection:Dropdown({Title = "Select Player", Values = GetAllPlayerNames(), Value = GetAllPlayerNames()[1] or "None", Callback = function(option) selectedPlayer = option end})
PlayerTeleportSection:Space()
PlayerTeleportSection:Button({Flag = "Refresh_player", Title = "Refresh", Callback = function() RefreshPlayersDropdown(PlayerTeleport_1) end})
PlayerTeleportSection:Space()
PlayerTeleportSection:Button({Flag = "Go_player", Title = "Teleport to Selected Player", Callback = function() TeleportToPlayerByName(selectedPlayer) end})

-- POSITION MANAGEMENT
PositionManagementSection= TeleportTab:Section({Title = "Position Management", Opened = true})
local locationName = ""
local savedPositions = {}

PositionManagementSection:Input({Title = "Location Name", Placeholder = "Input location name...", Value = locationName, 
    Callback = function(input)
        locationName = input
    end
})
PositionManagementSection:Space()
PositionManagementSection:Button({Title = "Save Location", Flag = "FRTYSRHHH",
    Callback = function()
        if locationName == "" or locationName == nil then
            Notify("Error", "Nama lokasi harus diisi terlebih dahulu!", "circle-x")
            return
        end
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            savedPositions[locationName] = root.CFrame
            Notify("Success", "Posisi '"..locationName.."' Successfully saved.", "check")
        else
            Notify("Error", "Invalid player.", "circle-x")
        end
    end
})
PositionManagementSection:Space()
PositionManagementSection:Button({Flag = "FTHRT5SSD", Title = "Load Location",
    Callback = function()
        if locationName == "" or locationName == nil then
            Notify("Error", "Masukkan nama lokasi yang ingin dimuat!", "circle-x")
            return
        end
        local pos = savedPositions[locationName]
        if not pos then
            Notify("Error", "Lokasi '"..locationName.."' belum disimpan.", "circle-x")
            return
        end
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = pos
            Notify("Success", "Berhasil teleport ke lokasi '"..locationName.."'.", "location")
        else
            Notify("Error", "HumanoidRootPart tidak ditemukan.", "circle-x")
        end
    end
})


-- ====================================================================
--                         //ANCHOR EXPLORER TAB
-- ==================================================================== //tab4
local ExplorerTab = Window:Tab({Title = "Explorer", Icon = "server"})
local ExplorerBtn = ExplorerTab:Button({
    Title = "Dex Explorer",
    Desc = "A powerful game explorer GUI. Shows every instance of the game and all their properties. Useful for developers.",
    Callback = function() 
        Notify("Dex Explorer", "Opening Dex Explorer ui", "check")
        --loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
    end
    
})


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

-- SAVE MANAGER
local SaveManagerSection = SettingsTab:Section({Title = "Save Manager", Opened = true})
SaveManagerSection:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        local SaveConfig = ConfigManager:CreateConfig(ConfigName)
        if SaveConfig:Save() then
            WindUI:Notify({
                Title = "Config Saved",
                Content = "Config '" .. ConfigName .. "' saved!"
            })
        end
    end
})
SaveManagerSection:Space()
SaveManagerSection:Button({
    Title = "Load Config",
    Icon = "folder",
    Callback = function()
        local LoadConfig = ConfigManager:CreateConfig("default")
        local success, err = pcall(function()
            LoadConfig:Load()
        end)

        if success then
            WindUI:Notify({
                Title = "✅ Config Loaded",
                Content = "Configuration applied successfully.",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "❌ Load Failed",
                Content = tostring(err),
                Duration = 4
            })
        end
    end
})
SaveManagerSection:Space()
SaveManagerSection:Button({
    Title = "Delete Config",
    Icon = "trash",
    Callback = function()
        local DeleteConfig = ConfigManager:CreateConfig(ConfigName)
        if DeleteConfig:Delete() then
            WindUI:Notify({
                Title = "Config Deleted",
                Content = "Deleted config: " .. ConfigName
            })
        else
            WindUI:Notify({
                Title = "Failed to Delete",
                Content = "No file found for: " .. ConfigName
            })
        end
    end
})

-- DANGER / SERVER HOPPING
local Endgame = SettingsTab:Section({Title = "Server Hopping", Opened = true})
Endgame:Button({Title = "Rejoin Server", Icon = "refresh-cw", Callback = RejoinServer})
