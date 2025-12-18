local Modules = {}
function Modules.LoadTheme(register, themeName)
    local Theme = themeName or "Default"
    if Theme == "Default" then
        WindUI:AddTheme({
            Name = "Default",
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
    end
end