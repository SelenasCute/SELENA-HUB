-- ====================================================================
--                      Selena HUB | Fish it
--                      Last Update 11/8/2025
--                      Enhanced Config Manager
-- ====================================================================

local GAME = "Selena HUB | Fish It"
local VERSION = 1.2
local LATEST_UPDATE = "11/8/2025"
local DISCORD_LINK = "dsc.gg/selena-hub"

--[[===== DEPENDENCY CHECKS =====]]
    local existingWindow = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("SelenaHUB_UI_Window")
    if existingWindow then
        existingWindow:Destroy()
    end

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
--

--[[===== SERVICES & VARIABLES =====]]
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = Players.LocalPlayer
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local leaderstats = Player:FindFirstChild("leaderstats")

--

--[[===== MODULES =====]]
    local Modules = {
        Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Player.lua"))(),
        Location = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Fish%20It/Location.lua"))()
    }
--

--[[===== CONFIGURATION =====]]
    local DefaultConfig = {
        -- Main Features
        AutoFish = false,
        AutoFishV2 = false,
        AutoFishV2Delay = 2,
        AutoSell = false,
        AutoSellDelay = 30,
        FishingRadar = false,
        DivingGear = false,
        
        -- Player Settings
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        NoClip = false,
        WalkOnWater = false,
        Fly = false,
        FlySpeed = 50,
        
        -- Graphics Settings
        AntiAFKConnection = nil,
        DisabledEffects = {},
        HiddenDecals = {},

        FPSBoost = false,
        LowGraphics = false,
        Disable3DRendering = false,
        AntiAFK = false,
        
        -- Shop Settings
        SelectedRod = nil,
        SelectedBait = nil,
        SelectedWeather = nil,
        SelectedBoat = nil,
        MerchantOpen = false,
        
        -- Teleport Settings
        AutoTPPosition = false,
        AutoTPIsland
        SelectedPosition = nil,
        SelectedIsland = nil,
        SelectedEvent = nil,
        SelectedNPC = nil,
        SelectedPlayer = nil,
        SavedPositions = {},
        
        -- UI Settings
        UIToggleKey = "RightShift"
    }

    local Config = {}
    for k, v in pairs(DefaultConfig) do Config[k] = v end

    -- Location Lists
    local islandNames = {}
    for name in pairs(Modules.Location.LOCATIONS["Island"]) do
        table.insert(islandNames, name)
    end
    table.sort(islandNames)

    local eventNames = {}
    for name in pairs(Modules.Location.LOCATIONS["GameEvent"]) do
        table.insert(eventNames, name)
    end
    table.sort(eventNames)

    local npcNames = {}
    for name in pairs(Modules.Location.LOCATIONS["NPC"]) do
        table.insert(npcNames, name)
    end
    table.sort(npcNames)

--
--[[===== UTILITY FUNCTIONS =====]]
    function Cleanup()
        for k, v in pairs(DefaultConfig) do
            Config[k] = typeof(v) == "table" and table.clone(v) or v
        end

        if ConfigManager then
            ConfigManager:Delete("default")
            ConfigManager:CreateConfig("default"):Save()
        end
        Notify("Cleanup", "All settings reset to default.", "trash")
    end


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

    local function Notify(title, content, icon, duration)
        duration = duration or 3
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

    local function GetAllPlayerNames()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then table.insert(names, plr.Name) end
        end
        return names
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

    local function GetGameName(placeId)
        local success, info = pcall(function()
            return MarketplaceService:GetProductInfo(placeId)
        end)
        if success and info then
            return info.Name
        else
            return "Unknown Game"
        end
    end

    -- ====================================================================
    --                        GAME FUNCTIONS
    -- ====================================================================

    -- SINGLE FUNCTION
    local function RedeemCode()
        local codes = { "CRYSTALS", "BLAMETALON", "SORRY" }
        for _, code in ipairs(codes) do
            Events.redeemCode:InvokeServer(code)
            task.wait(0.5)
            Notify("Redeem Code", "Successfully Redeem Code "..code, "ticket")
        end
    end

    local function RefreshPlayersDropdown(dropdown)
        local newList = GetAllPlayerNames()
        dropdown:SetValues(newList)
        Notify("Refresh player list", "Successfully Refreshed player list", "refresh-ccw")
    end

    local function SetToggleKey(key)
        Config.UIToggleKey = key
        Window:SetToggleKey(Enum.KeyCode[key])
        Notify("UI Toggle", "UI toggle key set to " .. key, "keyboard")
    end

    local function OpenMerchant(state)
        Config.MerchantOpen = state
        pcall(function()
            game:GetService("Players").LocalPlayer.PlayerGui.Merchant.Enabled = state
        end)
    end

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

    -- TASK FUNCTIONS
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

    local function RejoinServer()
        Notify("Rejoining", "Rejoining current server...", "refresh-cw")
        task.wait(0.5)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end

    local function AutoIslandTeleport(state)
        if Config.AlreadyInIsland == true then return end
        if state then
            Config.AlreadyInIsland = true
            Modules.Location.TeleportTo("Island", Config.SelectedIsland)
        else 
            Config.AlreadyInIsland = false
        end
    end

    local function ToggleAntiAFK(state)
        Config.AntiAFK = state
        local vu = game:GetService("VirtualUser")
        local player = game.Players.LocalPlayer

        if state == true then
            Config.AntiAFKConnection = player.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        elseif state == false then
            if Config.AntiAFKConnection then
                Config.AntiAFKConnection:Disconnect()
                Config.AntiAFKConnection = nil
            end
        end
    end

    local function ToggleFPSBoost(state)
        Config.FPSBoost = state
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if state == true then
            -- FPS Boost ON
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter")
                or v:IsA("Trail")
                or v:IsA("Smoke")
                or v:IsA("Fire")
                or v:IsA("Beam")
                or v:IsA("Sparkles")
                or v:IsA("Explosion") then

                    if v.Enabled ~= false then
                        table.insert(Config.DisabledEffects, v)
                        pcall(function() v.Enabled = false end)
                    end
                end
            end

            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end

        elseif state == false then
            -- FPS Boost OFF (restore)
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)

            for i, v in ipairs(Config.DisabledEffects) do
                if v and v.Parent then
                    pcall(function() v.Enabled = true end)
                end
            end
            table.clear(Config.DisabledEffects)

            if Terrain then
                Terrain.WaterWaveSize = 0.05
                Terrain.WaterWaveSpeed = 8
                Terrain.WaterReflectance = 1
                Terrain.WaterTransparency = 0.3
            end
        end
    end

    local function ToggleLowGraphics(state)
        Config.LowGraphics = state

        if state == true then
            -- Aktifkan mode low graphics
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    pcall(function()
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    end)
                end

                if v:IsA("Decal") or v:IsA("Texture") then
                    if v.Transparency < 1 then
                        table.insert(Config.HiddenDecals, v)
                        pcall(function()
                            v.Transparency = 1
                        end)
                    end
                end
            end
        elseif state == false then
            -- Nonaktifkan mode low graphics (restore decal)
            for i, v in ipairs(Config.HiddenDecals) do
                if v and v.Parent then
                    pcall(function()
                        v.Transparency = 0
                    end)
                end
            end

            -- Hapus data lama biar gak numpuk
            table.clear(Config.HiddenDecals)
        end
    end

    local blackFrame
    local function Toggle3DRenderingDisable(state)
        Config.Disable3DRendering = state
        if state == true then
            RunService:Set3dRenderingEnabled(false)
            if not blackFrame then
                local gui = Player:WaitForChild("PlayerGui"):FindFirstChild("BlackoutGui") or Instance.new("ScreenGui")
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
                v1.Text = "SELENA HUB"
                v1.TextColor3 = Color3.fromRGB(255, 255, 255)
                v1.TextScaled = true
                v1.Font = Enum.Font.GothamBold
                v1.ZIndex = 1
                v1.Parent = blackFrame
            else
                blackFrame.Visible = true
            end
        elseif state == false then
            RunService:Set3dRenderingEnabled(true)
            if blackFrame then blackFrame.Visible = false end
        end
    end

--

--[[===== MAIN TASKS =====]]
    -- AUTO SYNC CONFIG TASK
    task.spawn(function()
        while task.wait(0.5) do
        --[[ GEAR SYNC ]]
            if not Config.Oxygen then
                if Config._OxygenActive then
                    Config._OxygenActive = false
                    RequestGear("Oxygen", false)
                end
            else
                if not Config._OxygenActive then
                    Config._OxygenActive = true
                    RequestGear("Oxygen", true)
                end
            end

            if not Config.Radar then
                if Config._RadarActive then
                    Config._RadarActive = false
                    RequestGear("Radar", false)
                end
            else
                if not Config._RadarActive then
                    Config._RadarActive = true
                    RequestGear("Radar", true)
                end
            end
        -- [[ GRAPHICS SETTINGS SYNC ]]
            if not Config.FPSBoost then
                if Config._FPSBoostActive then
                    Config._FPSBoostActive = false
                    ToggleFPSBoost(false)
                end
            else
                if not Config._FPSBoostActive then
                    Config._FPSBoostActive = true
                    ToggleFPSBoost(true)
                end
            end

            if not Config.LowGraphics then
                if Config._LowGraphicsActive then
                    Config._LowGraphicsActive = false
                    ToggleLowGraphics(false)
                end
            else
                if not Config._LowGraphicsActive then
                    Config._LowGraphicsActive = true
                    ToggleLowGraphics(true)
                end
            end

            if not Config.AntiAFK then
                if Config._AntiAFKActive then
                    Config._AntiAFKActive = false
                    ToggleAntiAFK(false)
                end
            else
                if not Config._AntiAFKActive then
                    Config._AntiAFKActive = true
                    ToggleAntiAFK(true)
                end
            end

            if not Config.Disable3DRendering then
                if Config._Disable3DRenderingActive then
                    Config._Disable3DRenderingActive = false
                    Toggle3DRenderingDisable(false)
                end
            else
                if not Config._Disable3DRenderingActive then
                    Config._Disable3DRenderingActive = true
                    Toggle3DRenderingDisable(true)
                end
            end
        end
    end)


    --// AUTO SELL LOOP
    task.spawn(function()
        while true do
            task.wait(Config.AutoSellDelay)
            if Config.AutoSell == true then
                Events.sell:InvokeServer()
            end
        end
    end)


    --// AUTO FISH V1 LOOPS
    task.spawn(function()
        while task.wait(0.15) do
            if Config.AutoFish then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end)

    --// AUTO FISH V2 LOOP
    task.spawn(function()
        while task.wait() do
            if Config.AutoFishV2 then
                pcall(function()
                    Events.equip:FireServer(1)
                    task.wait(0.05)
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.02)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                    task.wait(Config.AutoFishV2Delay)
                    Events.fishing:FireServer()
                end)
            end
        end
    end)

    --// AUTO TELEPORT TO SAVED Position
    task.spawn(function()
        while task.wait(1) do
            if Config.AutoTPPosition then
                if HumanoidRootPart and HumanoidRootPart.CFrame ~= Config.SelectedPosition then
                    HumanoidRootPart.CFrame = Config.SelectedPosition
                end
            end

            if Config.AutoTPIsland then
                if HumanoidRootPart and HumanoidRootPart.CFrame ~= Config.SelectedPosition then
                    HumanoidRootPart.CFrame = Config.selectedIsland
                end
            end
        end
    end)

    --// AUTO SYNC PLAYER MOVEMENT SETTINGS
    task.spawn(function()
        while task.wait(1) do

            if not (Character and Humanoid) then
                continue -- tunggu respawn
            end

            -- 🏃 Walk Speed
            if Humanoid.WalkSpeed ~= Config.WalkSpeed then
                pcall(function()
                    Modules.Player.SetWalkSpeed(Config.WalkSpeed)
                end)
            end

            -- 🦘 Jump Power
            if Humanoid.UseJumpPower and Humanoid.JumpPower ~= Config.JumpPower then
                pcall(function()
                    Modules.Player.SetJumpPower(Config.JumpPower)
                end)
            end

            -- 🔁 Infinite Jump
            if Config.InfiniteJump then
                pcall(function()
                    Modules.Player.ToggleInfiniteJump(true)
                end)
            end

            -- 🚫 NoClip
            if Config.NoClip then
                pcall(function()
                    Modules.Player.ToggleNoClip(true)
                end)
            end

            -- 🌊 Walk on Water
            if Config.WalkOnWater then
                pcall(function()
                    Modules.Player.ToggleWalkOnWater(true)
                end)
            end
        end
    end)
--

--[[===== MAIN UI INITIALIZATION =====]]

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    WindUI:AddTheme({
        Name = "Theme_1",
        Button = Color3.fromHex("#ff7b00"),      
    })


    local Window = WindUI:CreateWindow({
        Title = GAME,
        Icon = "rbxassetid://112969347193102",
        Name = "SelenaHUB_UI_Window",
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
        BackgroundImageTransparency = 0.95,
        Theme = "Theme_1",
    })

    Window:EditOpenButton({
        Title = "SELENA HUB",
        Icon = "rbxassetid://112969347193102",
        CornerRadius = UDim.new(0,16),
        StrokeThickness = 2,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),     -- Merah
            ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),   -- Oranye
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),   -- Kuning
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 0)),     -- Hijau
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),     -- Biru
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),    -- Indigo
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(148, 0, 211)),   -- Ungu
        }),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    })

    Window:OnDestroy(function()
        Cleanup()
    end)

    Window:Tag({Title = "v" .. VERSION, Icon = "github", Color = Color3.fromHex("#6b31ff")})
--

-- ABOUT TAB
    local AboutTab = Window:Tab({Title = "About", Icon = "info"})
    AboutTab:Select()

    local aboutParagraph = AboutTab:Paragraph({
        Title = "Hello, " .. Player.Name .. " 👋",
        Desc = (('<font color="#ffcc00">Level:</font> %s<br/><font color="#ffcc00">Caught:</font> %s<br/><font color="#ffcc00">Rarest Fish:</font> %s'):format(getLevel(),stat("Caught"),stat("Rarest Fish"))),
        Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
        ImageSize = 70
    })

    for _, name in ipairs({"Caught", "Rarest Fish"}) do
        local s = leaderstats:FindFirstChild(name)
        if s then
            s:GetPropertyChangedSignal("Value"):Connect(function()
                aboutParagraph:SetDesc(('<font color="#ffcc00">Level:</font> %s<br/><font color="#ffcc00">Caught:</font> %s<br/><font color="#ffcc00">Rarest Fish:</font> %s'):format(getLevel(),stat("Caught"),stat("Rarest Fish")))
            end)
        end
    end

    AboutTab:Space()
    AboutTab:Button({
        Title = "Copy Discord Link",
        Icon = "link",
        Callback = function()
            setclipboard(DISCORD_LINK)
            Notify("Discord Link", "Link copied to clipboard!", "link")
        end
    })

--

-- MAIN TAB 
    local MainTab = Window:Tab({Title = "Main", Icon = "house"})

    -- AUTO FISH SECTION
    local AutoFishSection = MainTab:Section({Title = "Auto Fish", Opened = true})
    AutoFishSection:Toggle({
        Flag = "AutoFishv1",
        Title = "Auto Fish V1",
        Desc = "Automatically farms fishing while enable",
        Default = Config.AutoFish,
        Callback = function(state)
            Config.AutoFish = state
            if state then
                Events.equip:FireServer(1)
                Notify("Auto Fish V1", "Auto Fish V1 is now enabled.", "fish")
            else
                Notify("Auto Fish V1", "Auto Fish V1 is now disabled.", "fish")
            end
        end
    })
    AutoFishSection:Space()
    AutoFishSection:Toggle({
        Flag = "AutoFishv2",
        Title = "Auto Fish V2",
        Desc = "Better Auto Fish, Delay Suggestion:\nAstral: 2",
        Default = Config.AutoFishV2,
        Callback = function(state)
            Config.AutoFishV2 = state
            if state then
                Notify("Auto Fish V2", "Auto Fish V2 is now enabled.", "fish")
            else
                Notify("Auto Fish V2", "Auto Fish V2 is now disabled.", "fish")
            end
        end
    })
    AutoFishSection:Space()
    AutoFishSection:Slider({
        Flag = "AutoFishV2DelaySlider",
        Title = "Auto Fish V2 Delay",
        Step = 0.1,
        Value = {
            Min = 0.1,
            Max = 10,
            Default = Config.AutoFishV2Delay
        },
        Callback = function(value)
            Config.AutoFishV2Delay = value
        end
    })

    -- AUTO SELL SECTION
    local AutoSellSection = MainTab:Section({Title = "Auto Sell", Opened = true})
    AutoSellSection:Toggle({
        Flag = "AutoSellInventory",
        Title = "Auto Sell Inventory",
        Desc = "Automatically sell your inventory while enable",
        Default = Config.AutoSell,
        Callback = function(state)
            Config.AutoSell = state
            if state then
                Notify("Auto Sell", "Auto Sell is now enabled.", "rbxassetid://9341850470")
            else
                Notify("Auto Sell", "Auto Sell is now disabled.", "rbxassetid://9341850470")
            end
        end
    })
    AutoSellSection:Space()
    AutoSellSection:Slider({
        Flag = "SellDelay",
        Title = "Sell Delay",
        Step = 1,
        Value = {
            Min = 1,
            Max = 200,
            Default = Config.AutoSellDelay
        },
        Callback = function(value)
            Config.AutoSellDelay = value
        end
    })
    AutoSellSection:Space()
    AutoSellSection:Button({
        Title = "Auto Sell Once",
        Callback = function()
            Events.sell:InvokeServer()
        end
    })
    AutoSellSection:Space()

    -- EVENT SECTION
    local EventSection = MainTab:Section({Title = "Event", Opened = true})

    -- MISC SECTION
    local MiscSection = MainTab:Section({Title = "Misc", Opened = true})
    MiscSection:Toggle({
        Flag = "FishingRadar",
        Title = "Fishing Radar",
        Desc = "Turns the fishing radar ON or OFF",
        Default = Config.FishingRadar,
        Callback = function(state)
            Config.FishingRadar = state
            RequestGear("Radar", state)
            if state then
                Notify("Fishing Radar", "Fishing Radar is now enabled.", "rbxassetid://11903551487")
            else
                Notify("Fishing Radar", "Fishing Radar is now disabled.", "rbxassetid://11903551487")
            end
        end
    })
    MiscSection:Space()
    MiscSection:Toggle({
        Flag = "DivingGear",
        Title = "Diving Gear",
        Desc = "Equip or Unequips Diving Gear",
        Default = Config.DivingGear,
        Callback = function(state)
            Config.DivingGear = state
            RequestGear("Oxygen", state)
            if state then
                Notify("Diving Gear", "Diving Gear is now equipped.", "rbxassetid://16419190627")
            else
                Notify("Diving Gear", "Diving Gear is now unequipped.", "rbxassetid://16419190627")
            end
        end
    })
    MiscSection:Space()
    MiscSection:Button({
        Title = "Redeem All Codes",
        Icon = "ticket-check",
        Callback = RedeemCode
    })
--

-- PLAYER TAB
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
    MovementSection:Space()
    MovementSection:Toggle({
        Flag = "WalkOnWaterToggle",
        Title = "Walk on Water",
        Default = Config.WalkOnWater,
        Callback = function(state)
            Config.WalkOnWater = state
            Modules.Player.ToggleWalkOnWater(state)
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
        Title = "Fly Gui",
        Desc = "Fly gui work for all device",
        Callback = function()
            Notify("Fly UI", "Opening Fly ui", "plane")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))()
        end
    })
--

-- SHOP TAB

    local ShopTab = Window:Tab({Title = "Shop", Icon = "store"})

    local Shop = {
        ["Bait"] = {
            ["Topwater Bait (100$)"] = {Id = 10, Icon = "rbxassetid://78313664669418"},
            ["Luck Bait (1K$)"] = {Id = 2, Icon = "rbxassetid://106827914793722"},
            ["Midnight Bait (3K$)"] = {Id = 3, Icon = "rbxassetid://82435085190109"},
            ["Nature Bait (83.5K$)"] = {Id = 17, Icon = "rbxassetid://115616199958924"},
            ["Chroma Bait (290K$)"] = {Id = 6, Icon = "rbxassetid://123495869001051"},
            ["Dark Matter Bait (630K$)"] = {Id = 8, Icon = "rbxassetid://77040147828550"},
            ["Corrupt Bait (1.15M$)"] = {Id = 15, Icon = "rbxassetid://115453224698341"},
            ["Aether Bait (3.7M$)"] = {Id = 16, Icon = "rbxassetid://91317933862702"},
            ["Floral Bait (4.00M$)"] = {Id = 20, Icon = "rbxassetid://80119465171442"},
            ["Singularity Bait (8.2M$)"] = {Id = 18, Icon = "rbxassetid://139381330729877"},
        },
        ["Rods"] = {
            ["Luck Rod (350$)"] = {Id = 79, Icon = "rbxassetid://127110979437680"},
            ["Carbon Rod (900$)"] = {Id = 76, Icon = "rbxassetid://124099699625912"},
            ["Grass Rod (1,5K$)"] = {Id = 85, Icon = "rbxassetid://130802650199282"},
            ["Demascus Rod (3K$)"] = {Id = 77, Icon = "rbxassetid://92202353564703"},
            ["Ice Rod (5K$)"] = {Id = 78, Icon = "rbxassetid://92630142441112"},
            ["Lucky Rod (15K$)"] = {Id = 4, Icon = "rbxassetid://85174841193446"},
            ["Midnight Rod (50K$)"] = {Id = 80, Icon = "rbxassetid://130162999569066"},
            ["SteamPunk Rod (215K$)"] = {Id = 6, Icon = "rbxassetid://0109211472277743"},
            ["Chrome Rod (437K$)"] = {Id = 7, Icon = "rbxassetid://83222944871842"},
            ["Fluorescent Rod (715K$)"] = {Id = 255, Icon = "rbxassetid://83998636831250"},
            ["Astral Rod (1M$)"] = {Id = 5, Icon = "rbxassetid://123734625865292"},
            ["Ares Rod (3M$)"] = {Id = 126, Icon = "rbxassetid://74424529377774"},
            ["Angler Rod (8M$)"] = {Id = 168, Icon = "rbxassetid://76924330674942"},
            ["Bambo Rod (12M$)"] = {Id = 258, Icon = "rbxassetid://95236691549566"},
        },
        ["Weather"] = {
            ["Wind (10K$)"] = {Id = "Wind", Icon = "rbxassetid://83206005633160"},
            ["Snow (15K$)"] = {Id = "Snow", Icon = "rbxassetid://102119250093406"},
            ["Cloudy (20K$)"] = {Id = "Cloudy", Icon = "rbxassetid://72258943070104"},
            ["Strom (35K$)"] = {Id = "Strom", Icon = "rbxassetid://111709787385701"},
            ["Radiant (50K$)"] = {Id = "Radiant", Icon = "rbxassetid://9940992285"},
            ["Shark Hunt (300K$)"] = {Id = "Shark Hunt", Icon = "rbxassetid://74938397479780"},
        },
        ["Boat"] = {
            ["Small Boat (300$)"] = {Id = 1, Icon = "rbxassetid://73604149951518"},
            ["Kayak (1,1K$)"] = {Id = 2, Icon = "rbxassetid://98871646506689"},
            ["Jetski (7,5K$)"] = {Id = 3, Icon = "rbxassetid://91216671973985"},
            ["Highfield Boat (35K$)"] = {Id = 4, Icon = "rbxassetid://75395154459652"},
            ["Speed Boat (70K$)"] = {Id = 5, Icon = "rbxassetid://140091900313483"},
            ["Fishing Boat (180K$)"] = {Id = 6, Icon = "rbxassetid://117568546918502"},
            ["Mini Yacht (1,2M$)"] = {Id = 14, Icon = "rbxassetid://74219886115935"},
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
    table.sort(rodList, function(a, b) return a.PriceValue < b.PriceValue end)

    local BuyRodSection = ShopTab:Section({Title = "Buy Rods", Opened = true})
    BuyRodSection:Dropdown({
        Flag = "SelectedRodDropdown",
        Title = "Select Rod",
        Values = rodList,
        Value = rodList[1],
        Callback = function(option)
            Config.SelectedRod = option
        end
    })
    BuyRodSection:Space()
    BuyRodSection:Button({
        Title = "Buy Selected Rod",
        Callback = function()
            if not Config.SelectedRod then return end
            Events.buyrod:InvokeServer(Config.SelectedRod.Id)
            Notify("Purchase Rod", "Purchased " .. Config.SelectedRod.Title, "shopping-cart")
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
    table.sort(baitList, function(a, b) return a.PriceValue < b.PriceValue end)

    local BuyBaitSection = ShopTab:Section({Title = "Buy Bait", Opened = true})
    BuyBaitSection:Dropdown({
        Flag = "SelectedBaitDropdown",
        Title = "Select Bait",
        Values = baitList,
        Value = baitList[1],
        Callback = function(option)
            Config.SelectedBait = option
        end
    })
    BuyBaitSection:Space()
    BuyBaitSection:Button({
        Title = "Buy Selected Bait",
        Callback = function()
            if not Config.SelectedBait then return end
            Events.buybait:InvokeServer(Config.SelectedBait.Id)
            Notify("Purchase Bait", "Purchased " .. Config.SelectedBait.Title, "shopping-cart")
        end
    })

    -- BUY WEATHER
    local weatherlist = {}
    for name, data in pairs(Shop["Weather"]) do
        table.insert(weatherlist, {
            Title = name,
            Icon = data.Icon,
            Id = data.Id,
            PriceValue = parsePrice(name)
        })
    end
    table.sort(weatherlist, function(a, b) return a.PriceValue < b.PriceValue end)

    local BuyWeatherSection = ShopTab:Section({Title = "Buy Weather", Opened = true})
    BuyWeatherSection:Dropdown({
        Flag = "SelectedWeatherDropdown",
        Title = "Select Weather",
        Values = weatherlist,
        Value = weatherlist[1],
        Callback = function(option)
            Config.SelectedWeather = option
        end
    })
    BuyWeatherSection:Space()
    BuyWeatherSection:Button({
        Title = "Buy Selected Weather",
        Callback = function()
            if not Config.SelectedWeather then return end
            Events.buyweather:InvokeServer(Config.SelectedWeather.Id)
            Notify("Purchase Weather", "Purchased " .. Config.SelectedWeather.Title, "shopping-cart")
        end
    })

    -- BUY BOAT
    local boatlist = {}
    for name, data in pairs(Shop["Boat"]) do
        table.insert(boatlist, {
            Title = name,
            Icon = data.Icon,
            Id = data.Id,
            PriceValue = parsePrice(name)
        })
    end
    table.sort(boatlist, function(a, b) return a.PriceValue < b.PriceValue end)

    local BuyBoatSection = ShopTab:Section({Title = "Buy Boat", Opened = true})
    BuyBoatSection:Dropdown({
        Flag = "SelectedBoatDropdown",
        Title = "Select Boat",
        Values = boatlist,
        Value = boatlist[1],
        Callback = function(option)
            Config.SelectedBoat = option
        end
    })
    BuyBoatSection:Space()
    BuyBoatSection:Button({
        Title = "Buy Selected Boat",
        Callback = function()
            if not Config.SelectedBoat then return end
            Events.buyboat:InvokeServer(Config.SelectedBoat.Id)
            Notify("Purchase Boat", "Purchased " .. Config.SelectedBoat.Title, "shopping-cart")
        end
    })

    -- MERCHANT
    local MerchantSection = ShopTab:Section({Title = "Merchant Shop", Opened = true})
    MerchantSection:Toggle({
        Flag = "OpenMerchantShop",
        Title = "Open Merchant Shop",
        Default = Config.MerchantOpen,
        Callback = function(state)
            OpenMerchant(state)
        end
    })
--

-- TELEPORT TAB
    local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"})

    -- FISHING ZONE
    local FishingZoneSection = TeleportTab:Section({Title = "Island Teleport", Opened = true})
    FishingZoneSection:Dropdown({ Flag = "SelectedIslandDropdown",
        Title = "Select Fishing zone",
        Desc = "Select Fishing zone to Teleport to",
        Values = islandNames,
        Value = islandNames[1],
        Callback = function(opt)
            Config.SelectedIsland = opt
        end
    })
    FishingZoneSection:Button({
        Title = "Teleport to Selected Zone",
        Icon = "",
        Justify = "Center",
        Callback = function()
            local success, err = Modules.Location.TeleportTo("Island", Config.SelectedIsland)
            if success then
                Notify("Teleport", "Teleported to " .. Config.SelectedIsland .. " (Island)", "map-pin")
            else
                Notify("Teleport Failed", err, "x")
            end
        end
    })
    FishingZoneSection:Button({
        Title = "Save Current Position",
        Icon = "save",
        Justify = "Center",
        Callback = function()
            Notify("Position Saved", "Current position saved for island teleport.", "check")
            print("Saved Position:", HumanoidRootPart.CFrame)
            Config.SelectedPosition = HumanoidRootPart.CFrame   
        end
    })
    FishingZoneSection:Button({
        Title = "Teleport to Saved Position",
        Icon = "mouse-pointer-click",
        Justify = "Center",
        Callback = function()
            if not Config.SelectedPosition then
                Notify("Teleport Failed", "No saved position found. Please save a position first.", "x")
                return
            end
            HumanoidRootPart.CFrame = Config.SelectedPosition
            Notify("Teleport", "Teleported to saved position.", "map-pin")
        end
    })
    FishingZoneSection:Space()
    FishingZoneSection:Toggle({
        Flag = "Teleport & Freeze at Selected Zone",
        Title = "Teleport & Freeze at Selected Zone",
        Default = Config.SelectedIsland,
        Callback = function(state)
            Config.AutoTPIsland = state
            if state then
                Notify("Teleport", "Auto Teleport to Saved Position is now enabled.", "map-pin")
            else
                Notify("Teleport", "Auto Teleport to Saved Position is now disabled.", "map-pin")
            end
        end
    })
    FishingZoneSection:Space()
    FishingZoneSection:Toggle({
        Flag = "Teleport & Freeze at Saved Position",
        Title = "Auto Teleport to Saved Position",
        Default = Config.AutoTPPosition,
        Callback = function(state)
            Config.AutoTPPosition = state
            if state then
                Notify("Teleport", "Auto Teleport to Saved Position is now enabled.", "map-pin")
            else
                Notify("Teleport", "Auto Teleport to Saved Position is now disabled.", "map-pin")
            end
        end
    })

    -- GAME EVENT TELEPORT
    local GameEventSection = TeleportTab:Section({Title = "Game Event Teleport", Opened = true})
    GameEventSection:Dropdown({
        Flag = "SelectedEventDropdown",
        Title = "Select Game Event",
        Values = eventNames,
        Value = eventNames[1],
        Callback = function(opt)
            Config.SelectedEvent = opt
        end
    })
    GameEventSection:Space()
    GameEventSection:Button({
        Title = "Teleport",
        Callback = function()
            local success, err = Modules.Location.TeleportTo("GameEvent", Config.SelectedEvent)
            if success then
                Notify("Teleport", "Teleported to " .. Config.SelectedEvent .. " (Game Event)", "map-pin")
            else
                Notify("Teleport Failed", err, "x")
            end
        end
    })

    -- NPC TELEPORT
    local NPCSection = TeleportTab:Section({Title = "NPC Teleport", Opened = true})
    NPCSection:Dropdown({
        Flag = "SelectedNPCDropdown",
        Title = "Select NPC",
        Values = npcNames,
        Value = "None",
        Callback = function(opt)
            Config.SelectedNPC = opt
        end
    })
    NPCSection:Space()
    NPCSection:Button({
        Title = "Teleport",
        Callback = function()
            local success, err = Modules.Location.TeleportTo("NPC", Config.SelectedNPC)
            if success then
                Notify("Teleport", "Teleported to " .. Config.SelectedNPC .. " (NPC)", "map-pin")
            else
                Notify("Teleport Failed", err, "x")
            end
        end
    })

    -- PLAYER TELEPORT
    local PlayerTeleportSection = TeleportTab:Section({Title = "Player Teleport", Opened = true})
    local PlayerTeleport_1 = PlayerTeleportSection:Dropdown({
        Flag = "SelectedPlayerDropdown",
        Title = "Select Player",
        Values = GetAllPlayerNames(),
        Value = "None",
        Callback = function(option)
            Config.SelectedPlayer = option
        end
    })
    PlayerTeleportSection:Space()
    PlayerTeleportSection:Button({
        Flag = "Go_player",
        Title = "Teleport to Selected Player",
        Callback = function()
            TeleportToPlayerByName(Config.SelectedPlayer)
        end
    })
--

-- SETTINGS TAB 
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
        Default = Config.FPSBoost,
        Callback = ToggleFPSBoost
    })
    GameSection:Space()
    GameSection:Toggle({
        Flag = "LowGraphicToggle",
        Title = "Low Graphics",
        Default = Config.LowGraphics,
        Callback = ToggleLowGraphics
    })
    GameSection:Space()
    GameSection:Toggle({
        Flag = "Disable3DRendering",
        Title = "Disable 3D Rendering",
        Default = Config.Disable3DRendering,
        Callback = Toggle3DRenderingDisable
    })
    GameSection:Space()
    GameSection:Toggle({
        Flag = "AntiAFKToggle",
        Title = "Anti AFK",
        Default = Config.AntiAFK,
        Callback = ToggleAntiAFK
    })

    -- SERVER HOPPING
    local ServerHoppingSection = SettingsTab:Section({Title = "Server Hopping", Opened = true})
    ServerHoppingSection:Button({
        Title = "Rejoin Server",
        Callback = RejoinServer
    })

    ServerHoppingSection:Space()
    ServerHoppingSection:Button({
        Title = "Hop to New Server",
        Icon = "arrow-right-circle",
        Callback = function()
            Notify("Server Hop", "Hopping to new server...", "arrow-right-circle")
            local u1 = loadstring(game:HttpGet"https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua")()
            u1:Teleport(game.PlaceId)
        end
    })

--

--[[===== FINALIZE =====]]
Players.PlayerAdded:Connect(function()
    RefreshPlayersDropdown(PlayerTeleport_1)
end)
Players.PlayerRemoving:Connect(function()
    RefreshPlayersDropdown(PlayerTeleport_1)
end)

print("────────────────────────────")
print("💉 Selena HUB Executed Successfully")
print("Game: "..GetGameName(game.PlaceId).." | Version: "..VERSION)
print("Status: Modules Loaded, UI Initialized ✅")
print("────────────────────────────")
