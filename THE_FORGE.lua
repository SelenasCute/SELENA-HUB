-- ====================================================================
--                      Phoenix HUB | EXAMPLE                 
-- ====================================================================

local GAME = "Phoenix HUB | The Forge"
local VERSION = 1.2
local LATEST_UPDATE = "~"
local DISCORD_LINK = "dsc.gg/selena-hub"
local LOGO = "rbxassetid://140413750237602"
local CurrentIsland = ""

--[[<<===== DEPENDENCY CHECK & ISLAND CHECK =====]]

    -- Current Island Check
    if game.PlaceId == 76558904092080 then
        CurrentIsland = "Island 1"
    elseif game.PlaceId == 129009554587176 then
        CurrentIsland = "Island 2"
    else
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Unsupported game", Text = "This game is not supported by Phoenix HUB.", Duration = 5})
        return
    end
--

--[[<<===== SERVICES & VARIABLES & MODULES =====]]
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local MarketplaceService = game:GetService("MarketplaceService")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local leaderstats = Player:FindFirstChild("leaderstats")

    local Modules = {
        ["OpenButton"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Library/OpenButton.lua"))(),
        ["Player"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Player.lua"))(),
        ["Utils"] = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Modules/Utils.lua"))(),
    }

    local Configs = {
        ["SaveName"] = "default",
        ["ConfigFile"] = nil,
        ["SelectedNPC"] = nil,
        ["ActiveTween"] = nil,
        ["TweenSpeed"] = 30,
        ["RockESPEnabled"] = false,
        ["RockESPSelected"] = {},
        ["PlayerESP"] = false,
        ["Fly"] = false,
        ["FlySpeed"] = 100,
        ["NoClip"] = false,
        ["InfiniteJump"] = false,
        ["WalkOnWater"] = false,
        ["InsideRockESPEnabled"] = false,
        
        -- Auto
        ["AutoMining"] = false,
        ["AutoSwing"] = false,

        -- AUTO FARM
        ["AlreadyMiningCheck"] = false,       
        ["AutoFarmDistance"] = 3,
        ["AutoFarm"] = false,
        ["AutoFarming"] = false,
        ["AutoFarmingMode"] = "Off",
        ["AutoFarmSpeed"] = 30,
        ["AutoFarmRock"] = {},

        -- Tween 
        ["TweenSpeed"] = 30,
    }

    local PlayerData = {
        ["Gold"]    = PlayerGui:FindFirstChild("Main") and PlayerGui.Main.Screen.Hud.Gold.Text or "0",
        ["Level"]   = Player:GetAttribute("Level") or 0,
        ["Stash"]   = PlayerGui:FindFirstChild("Menu") and PlayerGui.Menu.Frame.Frame.Menus.Stash.Capacity.Text.Text:match(":%s*(.*)") or "0/0",
        ["Status"]  = "Idle",
    }

    local RockData = {
        ["Island 1"] = {
            ["Pebble"] = "rbxassetid://136169843910321",
            ["Rock"] = "rbxassetid://100566151564902",
            ["Boulder"] = "rbxassetid://100566151564902",
            ["Lucky Block"] = "rbxassetid://133961943237403",
        },
        ["Island 2"] = {
            ["Basalt Rock"] = "rbxassetid://136169843910321",
            ["Basalt Core"] = "rbxassetid://100566151564902",
            ["Basalt Vein"] = "rbxassetid://100566151564902",
            ["Volcanic Rock"] = "rbxassetid://133961943237403",
            ["Violet Crystal"] = "rbxassetid://136169843910321",
            ["Cyan Crystal"] = "rbxassetid://100566151564902",
            ["Earth Crystal"] = "rbxassetid://100566151564902",
            ["Light Crystal"] = "rbxassetid://133961943237403",
            ["Arcane Crystal"] = "rbxassetid://136169843910321",
            ["Magenta Crystal"] = "rbxassetid://100566151564902",
            ["Green Crystal"] = "rbxassetid://100566151564902",
            ["Orange Crystal"] = "rbxassetid://133961943237403",
            ["Blue Crystal"] = "rbxassetid://133961943237403",
            ["Rainbow Crystal"] = "rbxassetid://133961943237403",
        }
    }
--

--[[<<===== UTILITY FUNCTUON =====>>]]
    local function HideAllObject(state)
        -- SERVICES
        local Workspace = game:GetService("Workspace")
        local Lighting = game:GetService("Lighting")
        local Players = game:GetService("Players")

        local camera = Workspace.CurrentCamera

        -- STORAGE (static via _G)
        _G._lowG = _G._lowG or {
            transparency = {},
            material = {},
            lighting = {
                Brightness = Lighting.Brightness,
                GlobalShadows = Lighting.GlobalShadows,
                FogStart = Lighting.FogStart,
                FogEnd = Lighting.FogEnd,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                ExposureCompensation = Lighting.ExposureCompensation,
                EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
            },
            light = nil
        }

        local data = _G._lowG

        -- CAMERA LIGHT (GABUNG)
        if not data.light then
            local l = Instance.new("PointLight")
            l.Name = "LowGraphicLight"
            l.Brightness = 2
            l.Range = 60
            l.Shadows = false
            l.Enabled = false
            l.Parent = camera
            data.light = l
        end

        -- OBJECTS
        local folders = {
            Workspace:WaitForChild("Terrain & Foliage"),
            Workspace:WaitForChild("Debris"),
        }

        for _, folder in pairs(folders) do
            for _, obj in pairs(folder:GetDescendants()) do

                -- PART (LOWEST)
                if obj:IsA("BasePart") then
                    if state then
                        if data.transparency[obj] == nil then
                            data.transparency[obj] = obj.Transparency
                        end
                        if data.material[obj] == nil then
                            data.material[obj] = obj.Material
                        end

                        obj.Transparency = 1
                        obj.Material = Enum.Material.Plastic
                        obj.CastShadow = false
                    else
                        if data.transparency[obj] ~= nil then
                            obj.Transparency = data.transparency[obj]
                            data.transparency[obj] = nil
                        end
                        if data.material[obj] ~= nil then
                            obj.Material = data.material[obj]
                            data.material[obj] = nil
                        end
                        obj.CastShadow = true
                    end
                end


                -- EFFECT
                if obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Beam")
                or obj:IsA("Smoke")
                or obj:IsA("Fire") then
                    obj.Enabled = not state
                end

                -- DECAL / TEXTURE (FIX)
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    if state then
                        if data.transparency[obj] == nil then
                            data.transparency[obj] = obj.Transparency
                        end
                        obj.Transparency = 1
                    else
                        if data.transparency[obj] ~= nil then
                            obj.Transparency = data.transparency[obj]
                            data.transparency[obj] = nil
                        end
                    end
                end

            end
        end

        -- LIGHTING
        if state then
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.ExposureCompensation = 0.8
            Lighting.Ambient = Color3.fromRGB(170,170,170)
            Lighting.OutdoorAmbient = Color3.fromRGB(170,170,170)
            Lighting.FogStart = 0
            Lighting.FogEnd = 1e5
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0

            for _, e in pairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") then
                    e.Enabled = false
                end
            end

            data.light.Enabled = true
        else
            for p, v in pairs(data.lighting) do
                Lighting[p] = v
            end

            for _, e in pairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") then
                    e.Enabled = true
                end
            end

            data.light.Enabled = false
        end
    end

    _G._disabledGUIs = _G._disabledGUIs or {}
    local function Disable3dRendering(state)
        RunService:Set3dRenderingEnabled(not state)

        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                if state then
                    if gui.Enabled then
                        _G._disabledGUIs[gui] = true
                        gui.Enabled = false
                    end
                else
                    if _G._disabledGUIs[gui] then
                        gui.Enabled = true
                        _G._disabledGUIs[gui] = nil
                    end
                end
            end
        end
    end


    --[[ ORE ESP ]]
    local RockFolder = workspace:WaitForChild("Rocks")

    local function RemoveOreESP(rock)
        for _, ore in ipairs(rock:GetChildren()) do
            if ore:IsA("Model") and ore.Name == "Ore" then
                local bb = ore:FindFirstChild("OreBillboard")
                local hl = ore:FindFirstChild("OreHighlight")
                if bb then bb:Destroy() end
                if hl then hl:Destroy() end
            end
        end
    end

    local function CreateOreBillboard(rock)
        if not rock:IsA("Model") then return end
        if not rock:FindFirstChild("Hitbox") then return end
        if rock:GetAttribute("LastHitPlayer") ~= game.Players.LocalPlayer.Name then return end

        -- kalau ESP mati → hapus & stop
        if not Configs["InsideRockESPEnabled"] then
            RemoveOreESP(rock)
            return
        end

        if rock:GetAttribute("LastHitPlayer") ~= game.Players.LocalPlayer.Name then
            RemoveOreESP(rock)
            return
        end

        for _, ore in ipairs(rock:GetChildren()) do
            if ore:IsA("Model") and ore.Name == "Ore" then
                if ore:FindFirstChild("OreBillboard") then continue end

                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.Name = "OreBillboard"
                BillboardGui.Parent = ore
                BillboardGui.Adornee = ore.PrimaryPart or ore
                BillboardGui.Size = UDim2.new(4, 0, 0.8, 0)
                BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
                BillboardGui.AlwaysOnTop = true
                BillboardGui.MaxDistance = 100

                local Highlight = Instance.new("Highlight")
                Highlight.Name = "OreHighlight"
                Highlight.Parent = ore
                Highlight.FillColor = Color3.fromRGB(0, 255, 0)

                local DisplayName = Instance.new("TextLabel")
                DisplayName.Parent = BillboardGui
                DisplayName.Size = UDim2.fromScale(1, 1)
                DisplayName.BackgroundTransparency = 1
                DisplayName.Text = ore:GetAttribute("Ore") or "Unknown"
                DisplayName.TextColor3 = Color3.new(1,1,1)
                DisplayName.TextScaled = true
                DisplayName.Font = Enum.Font.SourceSansBold

                local Stroke = Instance.new("UIStroke")
                Stroke.Parent = DisplayName
                Stroke.Thickness = 2
            end
        end
    end

    for _, rock in ipairs(RockFolder:GetDescendants()) do
        if rock:IsA("Model") and rock.Parent.Name == "SpawnLocation" then
            rock.ChildAdded:Connect(function(child)
                if child:IsA("Model") and child.Name == "Ore" then
                    if Configs["InsideRockESPEnabled"] == true then
                        CreateOreBillboard(rock)
                    end
                end
            end)

            rock.ChildRemoved:Connect(function(child)
                if child:IsA("Model") and child.Name == "Ore" then
                    if Configs["InsideRockESPEnabled"] == false then
                        CreateOreBillboard(rock)
                    end
                end
            end)

            CreateOreBillboard(rock)
        end
    end

   --[[ ROCK ESP ]]
    local function HighlightAllSelectedRock(rnList)
        local countedRocks = 0
        for _, rock in ipairs(workspace:GetDescendants()) do
            if rock:IsA("Model") and rock.Parent.Name == "SpawnLocation" then
                -- cek apakah nama rock ada di rnList
                local shouldHighlight = false
                for _, rn in ipairs(rnList) do
                    if rock.Name == rn then
                        shouldHighlight = true
                        break
                    end
                end

                if Configs["RockESPEnabled"] and shouldHighlight then
                    -- Highlight
                    if not rock:FindFirstChild("RockESP_Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "RockESP_Highlight"
                        highlight.Adornee = rock
                        highlight.FillColor = Color3.fromHex("#00ff00")
                        highlight.OutlineColor = Color3.fromHex("#ffffff")
                        highlight.Parent = rock
                    end

                    -- TextLabel
                    if not rock:FindFirstChild("RockESP_Label") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "RockESP_Label"
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.Adornee = rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
                        billboard.AlwaysOnTop = true

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = rock.Name
                        textLabel.TextColor3 = Color3.fromHex("#ffffff")
                        textLabel.TextScaled = true
                        textLabel.Parent = billboard

                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Color3.fromHex("#000000")
                        stroke.Thickness = 3
                        stroke.Parent = textLabel

                        billboard.Parent = rock
                    end

                    countedRocks = countedRocks + 1
                else
                    -- Remove Highlight
                    local existingHighlight = rock:FindFirstChild("RockESP_Highlight")
                    if existingHighlight then
                        existingHighlight:Destroy()
                    end

                    -- Remove TextLabel
                    local existingLabel = rock:FindFirstChild("RockESP_Label")
                    if existingLabel then
                        existingLabel:Destroy()
                    end
                    
                    countedRocks = 0
                end
            end
        end
    end

    --[[workspace.DescendantAdded:Connect(function(rock)
        if rock:IsA("Model") and rock.Parent.Name == "SpawnLocation" then
            HighlightAllSelectedRock(Configs["RockESPSelected"])
        end
    end)]]


    local function GetProfilePic(player, typeEnum, sizeEnum)
        player = player or Players.LocalPlayer
        typeEnum = typeEnum or Enum.ThumbnailType.HeadShot
        sizeEnum = sizeEnum or Enum.ThumbnailSize.Size420x420

        local success, url = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, typeEnum, sizeEnum)
        end)

        if success and url then
            return url
        else
            warn("Failed to load picture", player.Name)
            return nil
        end
    end

    local function Notify(title, content, icon, duration)
        duration = duration or 3
        icon = icon or "info"
        if title == "Enable" then
            icon = "rbxassetid://115234285192864"
        end
        if title == "Disable" then
            icon = "rbxassetid://125177989737726"
        end

        return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
    end
    
    local function GetCharacter()
        return Player.Character or Player.CharacterAdded:Wait()
    end

    local function GetHumanoidRootPart()
        local char = GetCharacter()
        return char:WaitForChild("HumanoidRootPart")
    end

    local function TweenTo(TargetCFrame)
        local TweenService = game:GetService("TweenService")
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local HRP = char:WaitForChild("HumanoidRootPart")

        -- batas speed (studs per second)
        local MIN_SPEED = 10
        local MAX_SPEED = 50

        -- Target UP
        local TargetUp = CFrame.new(
            TargetCFrame.Position.X,
            TargetCFrame.Position.Y + 72,
            TargetCFrame.Position.Z
        ) * TargetCFrame.Rotation

        -- STEP 1: TP ke ketinggian TargetUp
        local hrpPos = HRP.Position
        HRP.CFrame = CFrame.new(
            hrpPos.X,
            TargetUp.Position.Y,
            hrpPos.Z
        ) * HRP.CFrame.Rotation

        -- hitung jarak tween
        local distance = (HRP.Position - TargetUp.Position).Magnitude

        -- hitung speed & clamp
        local speed = math.clamp(distance, MIN_SPEED, MAX_SPEED)

        -- time = distance / speed
        local tweenTime = distance / speed

        -- STEP 2: Tween ke TargetUp
        local tweenInfo = TweenInfo.new(
            tweenTime,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
        )

        local tween = TweenService:Create(
            HRP,
            tweenInfo,
            { CFrame = TargetUp }
        )

        tween:Play()
        tween.Completed:Wait()

        -- STEP 3: TP ke Target
        HRP.CFrame = TargetCFrame
    end

    local function TweenToRock(TargetCFrame)
        local char = Player.Character or Player.CharacterAdded:Wait()
        local HRP = char:WaitForChild("HumanoidRootPart")

        local MIN_SPEED = 10
        local MAX_SPEED = 50
        local speed = math.clamp(Configs["AutoFarmSpeed"] or 30, MIN_SPEED, MAX_SPEED)

        local targetPos = TargetCFrame.Position

        -- === TARGET UP (hadap ke batu) ===
        local TargetUp = CFrame.lookAt(
            Vector3.new(targetPos.X, targetPos.Y + 72, targetPos.Z),
            targetPos
        )

        -- teleport vertikal
        HRP.CFrame = CFrame.lookAt(
            Vector3.new(HRP.Position.X, TargetUp.Position.Y, HRP.Position.Z),
            targetPos
        )

        local distance = (HRP.Position - TargetUp.Position).Magnitude
        local tweenTime = distance / speed

        local tween = TweenService:Create(
            HRP,
            TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { CFrame = TargetUp }
        )

        tween:Play()
        tween.Completed:Wait()

        -- === POSISI FINAL + ARAH HADAP ===
        if Configs["AutoFarmingMode"] == "Above" then
            local pos = targetPos + Vector3.new(0, Configs["AutoFarmDistance"], 0)

            -- HADAP KE BAWAH
            HRP.CFrame = CFrame.lookAt(
                pos,
                pos - Vector3.new(0, 1, 0)
            )

        elseif Configs["AutoFarmingMode"] == "Under" then
            local pos = targetPos + Vector3.new(0, -Configs["AutoFarmDistance"], 0)

            -- HADAP KE ATAS
            HRP.CFrame = CFrame.lookAt(
                pos,
                pos + Vector3.new(0, 1, 0)
            )

        else -- SAFE
            HRP.CFrame = CFrame.lookAt(
                targetPos,
                Vector3.new(targetPos.X, HRP.Position.Y, targetPos.Z)
            )
        end
    end

    local function FindNearestRock(rockTypes)
        local char = Player.Character
        if not char then return nil end

        local HRP = char:FindFirstChild("HumanoidRootPart")
        if not HRP or not RockFolder then return nil end

        local nearestRock
        local shortestDistance = math.huge
        local searchTypes = type(rockTypes) == "table" and rockTypes or {rockTypes}

        for _, rock in ipairs(RockFolder:GetDescendants()) do
            if rock:IsA("Model")
            and rock.Parent
            and rock.Parent.Name == "SpawnLocation"
            and rock:FindFirstChild("Hitbox")
            and not rock:GetAttribute("LastHitPlayer") ~= player.Name then

                for _, rockType in ipairs(searchTypes) do
                    if rock.Name == rockType then
                        local dist = (rock.Hitbox.Position - HRP.Position).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            nearestRock = rock
                        end
                        break
                    end
                end
            end
        end

        return nearestRock
    end


    function AutoFarmRock(rockTypes, state)
        Configs["AutoFarm"] = state

        if not state then
            Configs["AutoMining"] = false
            return
        end

        task.spawn(function()
            while Configs["AutoFarm"] do
                local rock = FindNearestRock(rockTypes)

                if not rock then
                    Notify("Auto Farming", "Waiting for rock to spawn")
                    task.wait(2)
                    continue
                end

                local hitbox = rock:FindFirstChild("Hitbox")
                if not hitbox then
                    task.wait(0.2)
                    continue
                end

                -- tandai rock sedang ditambang
                rock:SetAttribute("BeingFarmed", true)
                Configs["AutoMining"] = true

                TweenToRock(hitbox.CFrame)

                -- tunggu batu benar-benar invalid
                local start = tick()
                while Configs["AutoFarm"] do
                    if not rock.Parent or not rock:FindFirstChild("Hitbox") then
                        break
                    end
                    if tick() - start > 25 then
                        break -- safety timeout
                    end
                    task.wait(0.1)
                end

                rock:SetAttribute("BeingFarmed", nil)
                task.wait(0.3)
            end

            Configs["AutoMining"] = false
        end)
    end


--

--[[<<===== TASK LOOP =====>>]]
    task.spawn(function()
        while true do
            -- Auto Mining
            if Configs["AutoMining"] then
                local success, err = pcall(function()
                    ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Pickaxe")
                end)
                if not success then
                    warn("Auto Mining Error:", err)
                end
            end

            -- Auto Swing
            if Configs["AutoSwing"] then
                local success, err = pcall(function()
                    ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated:InvokeServer("Weapon", true)
                end)
                if not success then
                    warn("Auto Swing Error:", err)
                end
            end

            task.wait(0.5)
        end
    end)

--

--[[<<===== MAIN UI INITIALIZATION =====>>]]

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    -- THEME
    WindUI:AddTheme({
        Name = "Default",
        Accent = Color3.fromHex("#ff7300"),
        Background = Color3.fromHex("#080808"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#ffffff"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#b8b8b8"),
        Button = Color3.fromHex("#ff7300"),

        Icon = Color3.fromHex("#ff7300"),
        WindowBackground = Color3.fromHex("#181818"), 
        WindowShadow = Color3.fromHex("#000000"),

        DialogBackground = Color3.fromHex("#1a1a1a"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#ffffff"),
        DialogContent = Color3.fromHex("#ffffff"),
        DialogIcon = Color3.fromHex("#ffa54d"),

        WindowTopbarButtonIcon = Color3.fromHex("#ff7300"),
        WindowTopbarTitle = Color3.fromHex("#ffffff"),
        WindowTopbarAuthor = Color3.fromHex("#ff7300"),
        WindowTopbarIcon = Color3.fromHex("#ffffff"),

        TabBackground = Color3.fromHex("#ff7300"),
        TabTitle = Color3.fromHex("#ffffff"),
        TabIcon = Color3.fromHex("#ff7300"),

        ElementTitle = Color3.fromHex("#ffffff"),
        ElementDesc = Color3.fromHex("#ffffff"),
        ElementIcon = Color3.fromHex("#ff7300"),
        PopupBackground = Color3.fromHex("#1a1a1a"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#ffffff"),
        PopupContent = Color3.fromHex("#ffffff"),
        PopupIcon = Color3.fromHex("#ff7300"),
        Toggle = Color3.fromHex("#ff7300"),
        ToggleBar = Color3.fromHex("#ffffff"),
        Checkbox = Color3.fromHex("#ff7300"),
        CheckboxIcon = Color3.fromHex("#ffffff"),
        Slider = Color3.fromHex("#ff7300"),
        SliderThumb = Color3.fromHex("#ffffff"),
    })

    WindUI:SetFont("rbxasset://fonts/families/Ubuntu.json")

    local Window = WindUI:CreateWindow({
        Title = GAME,
        Name = "PhoenixHUB_UI_Window",
        Author = "Version 1.3",
        Folder = "PhoenixHUB",
        NewElements = true,
        Size = UDim2.fromOffset(680, 430),
        MinSize = Vector2.new(560, 330),
        MaxSize = Vector2.new(680, 430),
        HideSearchBar = true,
        Transparent = false,
        Resizable = true,
        SideBarWidth = 150,
        Theme = "Default",
        Radius = 16,
        ElementsRadius = 10,
    })

    -- CONFIG 
    local ConfigManager = Window.ConfigManager
    ConfigManager:Init(Window)

    -- OPEN BUTTON
    Modules["OpenButton"].Create(Window)

    -- WINDOW SETTINGS
    Window:Tag({Title = "PREMIUM", Color = Color3.fromHex("#FFFF00"), Icon = "rbxassetid://11322089611"})
    Window:DisableTopbarButtons({"Close", "Minimize", "Fullscreen",})

    -- TOPBAR BUTTONS
    Window:CreateTopbarButton("", "x",    function() 
        Window:Dialog({ Icon = "rbxassetid://14446997892", Title = "Close Confirmation", Content = "Are you sure you want to close gui?",
            Buttons = {
                {
                    Title = "Close Window",
                    Variant = "Primary",
                    Callback = function()
                        Window:Destroy()
                        Modules.OpenButton.Destroy()
                    end,
                },
                {
                    Title = "Cancel",
                    Variant = "Secondary",
                    Callback = function()
                    end,
                },
            },
        })
    end,  990)

    Window:CreateTopbarButton("", "minus",    function() 
        Window:Toggle()
    end,  989)
    

--

-- >> 📌 INFORMATION TAB << 
    local InfoTab = Window:Tab({Title = "Information", Icon = "circle-alert"})
    InfoTab:Select()

    -- PLAYER INFO SECTION
    InfoTab:Section({Title = "Player Information"})
    local PlayerInfo = InfoTab:Paragraph({
        Title = "Welcome "..Player.Name.."!",
        Image = GetProfilePic(),
    })

    -- DISCORD SECTION
    InfoTab:Section({Title = "Join Discord Server Phoenix HUB"})
    InfoTab:Paragraph({
        Title = "Phoenix HUB Community",
        Desc = "Be part of our Community Discord—get new announcements, access support, and chat with other users!",
        Image = LOGO,        
        Buttons = {
            {
                Icon = "link",
                Title = "Copy Discord Link",
                Callback = function() setclipboard(DISCORD_LINK); Notify("Discord Link", "Link copied to clipboard!", "link") end,                
            }
        }
    })

    -- [[ Update Player Data ]]
    local function UpdatePlayerInfo()
        if not PlayerInfo then return end

        PlayerInfo:SetDesc((
            '• Gold: <font color="#ffcc00">%s</font><br/>' ..
            '• Level: <font color="#ffcc00">%s</font><br/>' ..
            '• Stash: <font color="#ffcc00">%s</font><br/>' ..
            '• Status: <font color="#ffcc00">%s</font>'
        ):format(
            PlayerData["Gold"],
            PlayerData["Level"],
            PlayerData["Stash"],
            PlayerData["Status"]
        ))
    end

    -- Pantau perubahan Gold
    PlayerGui.Main.Screen.Hud.Gold:GetPropertyChangedSignal("Text"):Connect(function()
        PlayerData["Gold"] = PlayerGui.Main.Screen.Hud.Gold.Text
        UpdatePlayerInfo()
    end)

    -- Pantau perubahan Level
    Player:GetAttributeChangedSignal("Level"):Connect(function()
        PlayerData["Level"] = Player:GetAttribute("Level") or 0
        UpdatePlayerInfo()
    end)

    -- Pantau perubahan Stash
    PlayerGui.Menu.Frame.Frame.Menus.Stash.Capacity.Text:GetPropertyChangedSignal("Text"):Connect(function()
        PlayerData["Stash"] = PlayerGui.Menu.Frame.Frame.Menus.Stash.Capacity.Text.Text:match(":%s*(.*)") or "0/0"
        UpdatePlayerInfo()
    end)

    -- Inisialisasi tampilan pertama kali
    UpdatePlayerInfo()



--

-- >> 📌 MAIN TAB <<
    local MainTAB = Window:Tab({Title = "Main", Icon = "landmark"})

    -- ESP ROCK SECTION
    MainTAB:Section({Title = "ESP Rock & Ore"})
    MainTAB:Dropdown({
        Title = "Select Rock Type",
        Multi = true,
        Value = Configs["RockESPSelected"] or {"Pebble"},
        Values = (function()
            local items = {}
            for rockName, icon in pairs(RockData[CurrentIsland]) do
                table.insert(items, {
                    Title = rockName,
                    Icon = icon
                })
            end
            return items
        end)(),
        Callback = function(optionList)
            Configs["RockESPSelected"] = {}
            for _, option in ipairs(optionList) do
                table.insert(Configs["RockESPSelected"], option.Title)
            end

            if Configs["RockESPEnabled"] then
                HighlightAllSelectedRock(Configs["RockESPSelected"])
            end
        end
    })
    MainTAB:Space()
    MainTAB:Toggle({
        Title = "ESP Rock",
        Icon = "smile",
        Value = Configs["RockESPEnabled"],
        Callback = function(state)
            Configs["RockESPEnabled"] = state
            HighlightAllSelectedRock(Configs["RockESPSelected"])
            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "ESP Rock has been enabled")
            else
                Notify("Disable", "ESP Rock has been disabled")
            end  
        end
    })
    MainTAB:Space()
    MainTAB:Toggle({
        Title = "Show Ore Inside Rock",
        Icon = "smile",
        Value = Configs["InsideRockESPEnabled"],
        Callback = function(state)
            Configs["InsideRockESPEnabled"] = state

            for _, rock in ipairs(RockFolder:GetDescendants()) do
                if rock:IsA("Model") and rock.Parent and rock.Parent.Name == "SpawnLocation" then
                    CreateOreBillboard(rock)
                end
            end
            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "Show Ore Inside Rock has been enabled")
            else
                Notify("Disable", "Show Ore Inside Rock has been disabled")
            end  
        end
    })


    -- MISC SECTION
        MainTAB:Section({Title = "Miscellaneous"})
        MainTAB:Toggle({
            Title = "Toggle ESP Player",
            Icon = "smile",
            Value = Configs["PlayerESP"],
            Callback = function(state)
                Configs["PlayerESP"] = state
                Modules["Player"].TogglePlayerESP(state)
                --==[[ Toggle Notification ]]==--
                if state then
                    Notify("Enable", "ESP Player has been enabled")
                else
                    Notify("Disable", "ESP Player has been disabled")
                end  
            end
        })
    --
--

-- >> 📌 AUTO FARMING TAB <<
    local AutoFarmingTAB = Window:Tab({Title = "Farming", Icon = "landmark"})
 
    local function RefreshAutoFarm()
        local SelectedRock = Configs["AutoFarmRock"]
        local SelectedMode = Configs["AutoFarmMode"]
        local NearestRock

        -- STEP 1: Find Nearest Selected Rock
        NearestRock = FindNearestRock(SelectedRock)
        print("Found: "..NearestRock)

        -- STEP 3: Tween To Nearest Rock
        local Highlight = Instance.new("Highlight")
        Highlight.Parent = NearestRock

        -- STEP 4: Wait for Rock Destroy
        NearestRock.AncestryChanged:Wait()
        task.wait(1)
    end

    AutoFarmingTAB:Section({Title = "Auto Farming"})
    AutoFarmingTAB:Dropdown({
        Title = "Auto Farm Mode",
        Value = "Off",
        Values = {"Off", "Above", "Under", "Safe"},
        Callback = function(options)
            if options == "Safe" then
                RefreshAutoFarm()
            end
        end
    })

    AutoFarmingTAB:Dropdown({
        Title = "Lava Safety Mode",
        Value = "Off",
        Values = {"Off", "Skip Rock"},
        Callback = function(options)
        end
    })

    AutoFarmingTAB:Dropdown({
        Title = "Choose rock to farm",
        Value = {},
        Values = (function()
            local items = {}
            for rockName, icon in pairs(RockData[CurrentIsland]) do
                table.insert(items, {
                    Title = rockName,
                    Icon = icon
                })
            end
            return items
        end)(),        
        Multi = true,
        AllowNone = true,
        Callback = function(options)
            table.clear(Configs["AutoFarmRock"])
            for _, option in pairs(options) do
                table.insert(Configs["AutoFarmRock"], option.Title)
            end
        end
    })

    AutoFarmingTAB:Dropdown({
        Title = "Apply Filter To",
        Value = {},
        Values = (function()
            local items = {}
            for rockName, icon in pairs(RockData[CurrentIsland]) do
                table.insert(items, {
                    Title = rockName,
                    Icon = icon
                })
            end
            return items
        end)(),        
        Multi = true,
        AllowNone = true,
        Callback = function(options)
        end
    })
    
    AutoFarmingTAB:Dropdown({
        Title = "Ignore Rock If No",
        Value = {},
        Values = (function()
            local items = {}
            for rockName, icon in pairs(RockData[CurrentIsland]) do
                table.insert(items, {
                    Title = rockName,
                    Icon = icon
                })
            end
            return items
        end)(),        
        Multi = true,
        AllowNone = true,
        Callback = function(options)
        end
    })     
    
    AutoFarmingTAB:Slider({
        Title = "Farm Distance",
        Step = 1,
        Value = {
            Min = 1,
            Max = 5,
            Default = 3,
        },
        Callback = function(value)
            Configs["AutoFarmDistance"] = value
        end
    }) 
    
    AutoFarmingTAB:Slider({
        Title = "Tween Speed",
        Step = 1,
        Value = {
            Min = 10,
            Max = 50,
            Default = 30,
        },
        Callback = function(value)
            Configs["TweenSpeed"] = value
            Configs["AutoFarmSpeed"] = value
        end
    })
    
    AutoFarmingTAB:Toggle({
        Title = "Already Mining Check",
        Icon = "smile",
        Value = Configs["AlreadyMiningCheck"],
        Callback = function(state)
            Configs["AlreadyMiningCheck"] = state
            if state then
                Notify("Enable", "Already Mining Check has been enabled")
            else
                Notify("Disable", "Already Mining Check has been disabled")
            end  
        end
    })   
--

-- >> 📌 PLAYER TAB <<
    local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

    -- ABILITY
    PlayerTab:Toggle({
        Flag = "InfiniteJumpToggle",
        Title = "Infinite Jump",
        Icon = "smile",
        Default = Configs["InfiniteJump"],
        Callback = function(state)
            Configs["InfiniteJump"] = state
            Modules["Player"].ToggleInfiniteJump(state)

            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "Infinite Jump has been enabled")
            else
                Notify("Disable", "Infinite Jump has been disabled")
            end                   
        end
    })
    PlayerTab:Space()

    -- NO CLIP
    PlayerTab:Toggle({
        Flag = "NoClipToggle",
        Icon = "smile",
        Title = "NoClip",
        Default = Configs["NoClip"],
        Callback = function(state)
            Configs["NoClip"] = state
            Modules["Player"].ToggleNoClip(state)

            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "No Clip has been enabled")
            else
                Notify("Disable", "No Clip has been disabled")
            end 
        end
    })
    PlayerTab:Space()

    -- FLY
    PlayerTab:Slider({
        Flag = "FlySlider",
        Title = "Set Fly Speed",
        Step = 1,
        Value = {
            Min = 50,
            Max = 300,
            Default = Configs["FlySpeed"]
        },
        Callback = function(value)
            Configs["FlySpeed"] = value
            Modules["Player"].SetFlySpeed(value)
        end
    })
    PlayerTab:Space()
    PlayerTab:Toggle({
        Title = "Toggle Fly",
        Value = Configs["Fly"],
        Icon = "smile",
        Callback = function(state)
            Modules["Player"].ToggleFly(state)
            Configs["Fly"] = state

            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "Fly Mode has been enabled")
            else
                Notify("Disable", "Fly Mode Rendering has been disabled")
            end 
        end
    })
    PlayerTab:Space()
    PlayerTab:Button({
        Flag = "FlyMobile",
        Title = "Fly Gui (mobile)",
        Icon = "rbxassetid://12804017021",        
        Callback = function()
            Notify("Fly UI", "Opening Fly ui", "plane")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))()
        end
    })
--

-- >> 📌 TELEPORT TAB <<
    local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"})

    local NPC = {
        ["Island 1"] = {
            ["Sensei Moro"] = {
                Location = CFrame.new(-198.788757, 29.473972, 157.877533, -0.847692, 0.000000, 0.530489, 0.000000, 1.000000, 0.000000, -0.530489, 0.000000, -0.847692),
                Desc = "Tutorial Quest",
                Icon = "rbxassetid://128013715479789",
            },
            ["Marbles"] = {
                Location = CFrame.new(-180.20831298828125, 28.70624542236328, 13.264348983764648),
                Desc = "Armor/Weapon Buyer",
                Icon = "rbxassetid://123127339153910",
            },
            ["Miner Fred"] = {
                Location = CFrame.new(-88.347595, 28.706255, 93.379341),
                Desc = "Pickaxe Seller",
                Icon = "rbxassetid://84615699390985",
            },
            ["Maria"] = {
                Location = CFrame.new(-151.726944, 27.992077, 119.461601),
                Desc = "Potions Seller",
                Icon = "rbxassetid://123091650558171",
            },
            ["Runemaker"] = {
                Location = CFrame.new(-272.820465, 20.315145, 147.446304),
                Desc = "Craft Runes.",
                Icon = "rbxassetid://98328287317747",
            },
            ["Greedy Cey"] = {
                Location = CFrame.new(-112.05010223388672, 37.50103759765625, -39.199710845947266),
                Desc = "Players can sell their Runes, Essences, and Ores here.",
                Icon = "rbxassetid://72584880421242",
            },
            ["Enhancer"] = {
                Location = CFrame.new(-259.992737, 20.320139, 24.618673),
                Desc = "Enhances Weapons and Armor.",
                Icon = "rbxassetid://86896638282741",
            },
            ["Bard"] = {
                Location = CFrame.new(-130.603561, 27.748547, 111.635788),
                Desc = "Gives a quest to find his lost guitar. He will reward you with a key used to open the Fallen Angel's Cave.",
                Icon = "rbxassetid://84071850129356",
            },
            ["Tomo the Explorist"] = {
                Location = CFrame.new(-103.52460479736328, 49.85659408569336, -108.68446350097656),
                Desc = "Gives a quest to find his lost cat in the Forgotten Kingdom",
                Icon = "rbxassetid://123400029364138",
            },
            ["Wizard"] = {
                Location = CFrame.new(-23.64644432067871, 80.88408660888672, -359.69305419921875),
                Desc = "After Completing the Main Quest, the player can access the Wizard who will allow give you portals",
                Icon = "rbxassetid://92515946292735",
            },
            ["Umut The Brave"] = {
                Location = CFrame.new(13.821953, -5.915269, -120.203094),
                Desc = "He will continuously give you the “Rotten Depths Quest” so you can farm EXP by killing Zombies.",
                Icon = "rbxassetid://89432191892257",
            },
            ["Nord"] = {
                Location = CFrame.new(41.306236, -5.319871, -104.740639),
                Desc = "He will continuously give you the “The Basics of Mining Quest” so you can farm EXP by mining.",
                Icon = "rbxassetid://109752697154696",
            },
        }
    }

    local AdvancedNPCValues = {}

    for islandName, islandData in pairs(NPC) do
        for npcName, npcData in pairs(islandData) do
            table.insert(AdvancedNPCValues, {
                Title = npcName,
                Desc = npcData.Desc,
                Icon = npcData.Icon,
                Callback = function()
                    Configs["SelectedNPC"] = npcName
                    Notify("Teleporting", "Teleporting to "..npcName, "rbxassetid://99338769758505")
                    TweenTo(npcData.Location, Configs["TweenSpeed"])
                    Notify("Teleporting", "Successfully Teleporting to "..npcName, "rbxassetid://99338769758505")
                end
            })
        end
    end

    table.sort(AdvancedNPCValues, function(a, b)
        return a.Title < b.Title
    end)


    TeleportTab:Section({Title = "Teleport To NPC"})
        
    TeleportTab:Dropdown({
        Title = "Select NPC",
        Values = AdvancedNPCValues
    })
--

-- >> 📌 SETTINGS TAB << 
    local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})
    -- Game Settings
    SettingsTab:Section({Title = "Game Settigs"})
    SettingsTab:Toggle({
        Flag = "DisableAllObject",
        Title = "Disable All Object",
        Callback = function(state)
            HideAllObject(state)

            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "Disable All Object has been enabled")
            else
                Notify("Disable", "Disable All Object has been disabled")
            end
        end
        
    })
    SettingsTab:Space()

    SettingsTab:Toggle({
        Flag = "Hide3dRendering",
        Title = "Disable 3D Rendering",
        Callback = function(state)
            Disable3dRendering(state)
            --==[[ Toggle Notification ]]==--
            if state then
                Notify("Enable", "Disable 3D Rendering has been enabled")
            else
                Notify("Disable", "Disable 3D Rendering has been disabled")
            end            
        end
        
    })


    -- Save Manager
    SettingsTab:Section({Title = "Save Manager"})

    local configInput = SettingsTab:Input({
        Title = "Config Name",
        Value = configName,
        Callback = function(value)
            configName = value or "default"
        end
    })

    SettingsTab:Dropdown({
        Title = "Select Config",
        Values = ConfigManager:AllConfigs(),
        Value = Configs["SaveName"],
        AllowNone = false,
        Callback = function(value)
            Configs["SaveName"] = value or "default"
            configInput:Set(Configs["SaveName"])
        end
    })

    SettingsTab:Button({
        Title = "SAVE CONFIG",
        Icon = "save",
        IconAlign = "Left",
        Justify = "Center",
        Callback = function()
            Configs["ConfigFile"] = ConfigManager:CreateConfig(Configs["SaveName"])
            Configs["ConfigFile"]:Set("playerData", MyPlayerData)
            Configs["ConfigFile"]:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            
            if Configs["ConfigFile"]:Save() then
                WindUI:Notify({ 
                    Title = "SAVE CONFIG", 
                    Content = "Saved as: "..Configs["SaveName"],
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to save config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })

    SettingsTab:Button({
        Title = "LOAD CONFIG",
        IconAlign = "Left",
        Justify = "Center",
        Icon = "folder",
        Callback = function()
            Configs["ConfigFile"] = ConfigManager:CreateConfig(Configs["SaveName"])
            local loadedData = Configs["ConfigFile"]:Load()
            
            if loadedData then
                if loadedData.playerData then
                    MyPlayerData = loadedData.playerData
                end
                
                local lastSave = loadedData.lastSave or "Unknown"
                WindUI:Notify({ 
                    Title = "LOAD CONFIG", 
                    Content = "Loaded: "..Configs["SaveName"].."\nLast save: "..lastSave,
                    Icon = "refresh-cw",
                    Duration = 5
                })
            else
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Failed to load config",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
--


--[[<<===== END =====>>]]
    -- ON DESTROY
    Window:OnDestroy(function()
        for _, v in ipairs(PlayerGui:GetChildren()) do
            if v.Name == "PhoenixHUB" then
                v:Destroy()
            end
        end
    end)

    -- ON CLOSE
    Window:OnClose(function()
        if ConfigManager and Configs["ConfigFile"] then
            Configs["ConfigFile"]:Set("playerData", MyPlayerData)
            Configs["ConfigFile"]:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            Configs["ConfigFile"]:Save()
            Notify("Auto-Save", "Your configuration has been auto-saved.", "save")
        end
    end)

    Notify("Phoenix HUB", "Phoenix HUB loaded successfully!", LOGO)
--