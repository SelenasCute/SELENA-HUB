-- ====================================================================
--                      Phoenix HUB | EXAMPLE                 
-- ====================================================================

local GAME = "Developer Mode"
local VERSION = 1.2
local LATEST_UPDATE = "~"
local DISCORD_LINK = "dsc.gg/selena-hub"
local LOGO = "rbxassetid://140413750237602"

--[[===== SERVICES & VARIABLES =====]]
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local VirtualUser = game:GetService("VirtualUser")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = Players.LocalPlayer
    local Player = Players.LocalPlayer
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local leaderstats = Player:FindFirstChild("leaderstats")

    -- TAMBAHKAN FUNCTION BARU INI:
    local function GetCharacter()
        if not Player.Character then
            Player.CharacterAdded:Wait()
        end
        return Player.Character
    end

    local function GetHumanoidRootPart()
        local char = GetCharacter()
        if not char then return nil end
        return char:WaitForChild("HumanoidRootPart")
    end

    Player.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = newCharacter:WaitForChild("Humanoid")
        HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    end)
--

--[[===== MODULES =====]]
    local Modules = {
        OpenButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Library/OpenButton.lua"))(),
        Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/SelenasCute/SELENA-HUB/refs/heads/main/Services/Player.lua"))(),
    }
--

--[[<<===== MAIN UI INITIALIZATION =====>>]]

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    WindUI:AddTheme({
        Name = "test",

        Accent = Color3.fromHex("#ff8800"),
        Background = Color3.fromHex("#1a1a1a"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#ffffff"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#b8b8b8"),
        Button = Color3.fromHex("#ff7300"),
        Icon = Color3.fromHex("#ffa54d"),
        
        Hover = Color3.fromHex("#ffb267"),

        WindowBackground = Color3.fromHex("#181818"),
        WindowShadow = Color3.fromHex("#000000"),

        DialogBackground = Color3.fromHex("#1a1a1a"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#ffffff"),
        DialogContent = Color3.fromHex("#ffffff"),
        DialogIcon = Color3.fromHex("#ffa54d"),

        WindowTopbarButtonIcon = Color3.fromHex("#ffa54d"),
        WindowTopbarTitle = Color3.fromHex("#ffffff"),
        WindowTopbarAuthor = Color3.fromHex("#ff8800"),
        WindowTopbarIcon = Color3.fromHex("#ffffff"),

        TabBackground = Color3.fromHex("#1a1a1a"),
        TabTitle = Color3.fromHex("#ffffff"),
        TabIcon = Color3.fromHex("#ffa54d"),

        ElementTitle = Color3.fromHex("#ffffff"),
        ElementDesc = Color3.fromHex("#ffffff"),
        ElementIcon = Color3.fromHex("#ffa54d"),

        PopupBackground = Color3.fromHex("#1a1a1a"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#ffffff"),
        PopupContent = Color3.fromHex("#ffffff"),
        PopupIcon = Color3.fromHex("#ffa54d"),

        Toggle = Color3.fromHex("#ff8800"),
        ToggleBar = Color3.fromHex("#ffffff"),

        Checkbox = Color3.fromHex("#ff8800"),
        CheckboxIcon = Color3.fromHex("#ffffff"),

        Slider = Color3.fromHex("#ff8800"),
        SliderThumb = Color3.fromHex("#ffffff"),
    })

    local Window = WindUI:CreateWindow({
        Title = GAME,
        Name = "PhoenixHUB_UI_Window",
        Author = "Version 1.3",
        Folder = "PhoenixHUB",
        NewElements = true,
        Size = UDim2.fromOffset(590, 350),
        MinSize = Vector2.new(560, 330),
        MaxSize = Vector2.new(620, 370),
        HideSearchBar = true,
        Transparent = false,
        Resizable = true,
        SideBarWidth = 150,
        Theme = "test",
    })

    Modules.OpenButton.Create(Window)
    Window:Tag({Title = "PREMIUM", Color = Color3.fromHex("#FFFF00")})
    Window:DisableTopbarButtons({"Close", "Minimize", "Fullscreen",})
    Window:OnDestroy(function()
        for _, v in ipairs(PlayerGui:GetChildren()) do
            if v.Name == "PhoenixHUB" then
                v:Destroy()
            end
        end
    end)

    Window:CreateTopbarButton("", "x",    function() 
        Window:Dialog({ Icon = "rbxassetid://14446997892", Title = "Close Confirmation", Content = "Are you sure you want to close gui?",
            Buttons = {
                {
                    Title = "Close Window",
                    Variant = "Primary",
                    Callback = function()
                        Window:Destroy()
                        myConfig:Save()
                        Cleanup()
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

-- INFORMATION TAB
    local InfoTab = Window:Tab({Title = "Information", Icon = "circle-alert"})
    InfoTab:Select()

    local JoinDiscordSection = InfoTab:Section({Title = "Join Discord Server Phoenix HUB"})
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

    InfoTab:Section({Title = "Example"})
    InfoTab:Toggle({Flag = "Test", Title = "Test", Value = false, Callback = function (args)
        print("Test1")
    end})
--