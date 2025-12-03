local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "PHOENIX HUB | DEVELOPER MODE",
    Folder = "PhoenixHUB",
    NewElements = true,
    Size = UDim2.fromOffset(590, 350),
    MinSize = Vector2.new(560, 330),
    MaxSize = Vector2.new(620, 370),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
})

--[[ VARIABLE ]]
local Players = game.Players
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

--[[ FUNCTION ]]
local function Notify(title, content, icon, duration)
    duration = duration or 3
    icon = icon or "info"
    return WindUI:Notify({Title = title, Content = content, Icon = icon, Duration = duration})
end

local MainTAB = Window:Tab({Title = "Main", Icon = "landmark"})
MainTAB:Select()
local Paragraph_CopyPOS = MainTAB:Paragraph({
    Title = "Player Position or CFrame",
    Buttons = {
        {
            Title = "Copy Position",
            Color = Color3.fromHex("#ffffff"),
            Callback = function()
                setclipboard(tostring(HumanoidRootPart.Position))
                Notify("Success", "Successfully copied player position to clipboard")
            end,
        },
        {
            Title = "Copy CFrame",
            Color = Color3.fromHex("#ffffff"),
            Callback = function()
                setclipboard(tostring(HumanoidRootPart.CFrame))
                Notify("Success", "Successfully copied player position to clipboard")
            end,
        }
    }
})
