--[[<<===== MAIN UI INITIALIZATION =====>>]]

    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    WindUI:AddTheme({
        Name = "Theme_1",
        Button = Color3.fromHex("#6b31ff"),      
    })


    local Window = WindUI:CreateWindow({
        Title = GAME,
        Icon = LOGO,
        Name = "PhoenixHUB_UI_Window",
        Author = "Version 1.3",
        Folder = "PhoenixHUB",
        NewElements = true,
        Size = UDim2.fromOffset(590, 350),
        MinSize = Vector2.new(560, 330),
        MaxSize = Vector2.new(620, 370),
        HideSearchBar = false,
        Transparent = false,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 200,
        --BackgroundTransparency = 0.,
        --Background = "rbxassetid://138742999874945",
        --BackgroundImageTransparency = 0.95,
        Theme = "Theme_1",
    })

    Modules.OpenButton.Create(Window)
    Window:Tag({Title = "PREMIUM", Color = Color3.fromHex("#FFFF00")})
    Window:DisableTopbarButtons({"Close", "Minimize", "Fullscreen",})
    Window:OnDestroy(function()  end)

    local ConfigManager = Window.ConfigManager
    local myConfig = ConfigManager:CreateConfig("Default") -- will be saved as config1.json

    Window:CreateTopbarButton("", "x",    function() 
        Window:Dialog({ Icon = "rbxassetid://14446997892", Title = "Close Confirmation", Content = "Are you sure you want to close gui?",
            Buttons = {
                {
                    Title = "Confirm",
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
    
    myConfig:Load()

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
--