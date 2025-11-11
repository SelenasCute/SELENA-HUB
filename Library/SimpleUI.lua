-- SimpleDarkUI.lua
-- Minimal, lightweight UI library for Roblox
-- Supports: Window, Tabs, Button, Toggle, Dropdown, Input, Slider
-- Theme: Dark grey, topbar with minimize & close

local SimpleDarkUI = {}
SimpleDarkUI.__index = SimpleDarkUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- default theme
local Theme = {
    Background = Color3.fromRGB(40, 40, 45),
    Panel = Color3.fromRGB(30, 30, 34),
    Accent = Color3.fromRGB(100, 100, 110),
    Text = Color3.fromRGB(230, 230, 230),
    SubText = Color3.fromRGB(180, 180, 185),
}

local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    return inst
end

-- helper: make text button
local function makeTextButton(parent, text)
    local btn = new("TextButton", {
        Parent = parent,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 14,
        Size = UDim2.new(1, -8, 0, 28),
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0, 4, 0, 4)
    })
    return btn
end

-- create window
function SimpleDarkUI.newWindow(title, opts)
    opts = opts or {}
    local screenGui = new("ScreenGui", {Name = opts.Name or "SimpleDarkUI"})
    screenGui.Parent = opts.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local main = new("Frame", {
        Parent = screenGui,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 420, 0, 300),
        Position = opts.Position or UDim2.new(0.5, -210, 0.5, -150),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0
    })

    local uiCorner = new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 6)})

    -- topbar
    local topbar = new("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    new("UICorner", {Parent = topbar, CornerRadius = UDim.new(0,6)})

    local titleLabel = new("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Text = title or "Window",
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local btnClose = new("TextButton", {
        Parent = topbar,
        Text = "✕",
        Size = UDim2.new(0, 28, 0, 20),
        Position = UDim2.new(1, -34, 0, 4),
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
    })

    local btnMin = new("TextButton", {
        Parent = topbar,
        Text = "—",
        Size = UDim2.new(0, 28, 0, 20),
        Position = UDim2.new(1, -68, 0, 4),
        BackgroundTransparency = 1,
        TextColor3 = Theme.SubText,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
    })

    -- content area
    local content = new("Frame", {
        Parent = main,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        BorderSizePixel = 0
    })

    local leftPane = new("Frame", {
        Parent = content,
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    new("UICorner", {Parent = leftPane, CornerRadius = UDim.new(0,4)})

    local rightPane = new("Frame", {
        Parent = content,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 120, 0, 0),
        BorderSizePixel = 0
    })

    -- tabs list
    local tabsList = new("UIListLayout", {Parent = leftPane, Padding = UDim.new(0,6)})

    local tabs = {}
    local currentTab = nil

    local window = setmetatable({}, SimpleDarkUI)
    window.ScreenGui = screenGui
    window.Main = main
    window.Content = content
    window.Left = leftPane
    window.Right = rightPane
    window.Tabs = tabs

    -- drag support
    do
        local dragging = false
        local dragOffset = Vector2.new()
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local mouse = UserInputService:GetMouseLocation()
                local guiPos = main.AbsolutePosition
                dragOffset = Vector2.new(mouse.X - guiPos.X, mouse.Y - guiPos.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                main.Position = UDim2.new(0, mouse.X - dragOffset.X, 0, mouse.Y - dragOffset.Y)
            end
        end)
    end

    -- close & minimize
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        if minimized then
            main.Size = UDim2.new(0, 420, 0, 28)
        else
            main.Size = UDim2.new(0, 420, 0, 300)
        end
    end)

    -- create tab function
    function window:CreateTab(text)
        local btn = new("TextButton", {
            Parent = self.Left,
            Text = text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0,4,0,4),
            Font = Enum.Font.SourceSans,
            TextColor3 = Theme.SubText,
            TextSize = 14
        })
        local page = new("Frame", {Parent = self.Right, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0, 6, 0, 6)})
        page.Visible = false

        btn.MouseButton1Click:Connect(function()
            if currentTab then currentTab.Page.Visible = false end
            page.Visible = true
            currentTab = {Button = btn, Page = page}
            -- visual
            for _,v in ipairs(self.Left:GetChildren()) do
                if v:IsA("TextButton") then v.TextColor3 = Theme.SubText end
            end
            btn.TextColor3 = Theme.Text
        end)

        table.insert(self.Tabs, {Button = btn, Page = page})
        if #self.Tabs == 1 then btn.MouseButton1Click:Fire() end

        -- expose simple element creation
        local section = {}
        function section:Button(text, callback)
            local b = makeTextButton(page, text)
            b.Parent = page
            b.MouseButton1Click:Connect(function() pcall(callback) end)
            return b
        end
        function section:Toggle(text, default, callback)
            local frame = new("Frame", {Parent = page, Size = UDim2.new(1, -12, 0, 28), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1})
            local label = new("TextLabel", {Parent = frame, Text = text, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.SourceSans, TextSize = 14, Size = UDim2.new(0.7,0,1,0), TextXAlignment = Enum.TextXAlignment.Left})
            local tbtn = new("TextButton", {Parent = frame, Size = UDim2.new(0,44,0,20), Position = UDim2.new(1, -50, 0,4), BackgroundColor3 = default and Theme.Accent or Theme.Panel, Text = "", BorderSizePixel = 0})
            new("UICorner", {Parent = tbtn, CornerRadius = UDim.new(0,6)})
            local state = default or false
            tbtn.MouseButton1Click:Connect(function()
                state = not state
                tbtn.BackgroundColor3 = state and Theme.Accent or Theme.Panel
                pcall(callback, state)
            end)
            return {Frame = frame, Get = function() return state end}
        end
        function section:Input(placeholder, callback)
            local frame = new("Frame", {Parent = page, Size = UDim2.new(1, -12, 0, 28), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1})
            local box = new("TextBox", {Parent = frame, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 1, 0), Text = "", PlaceholderText = placeholder or "", TextColor3 = Theme.Text, Font = Enum.Font.SourceSans, TextSize = 14, BorderSizePixel = 0})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            box.FocusLost:Connect(function(enter)
                pcall(callback, box.Text)
            end)
            return box
        end
        function section:Dropdown(text, options, callback)
            local label = new("TextLabel", {Parent = page, Text = text, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.SourceSans, TextSize = 14, Size = UDim2.new(1, -12, 0, 18), Position = UDim2.new(0,6,0,6), TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("Frame", {Parent = page, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, -12, 0, 26), Position = UDim2.new(0,6,0,30), BorderSizePixel = 0})
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
            local open = false
            local list = new("Frame", {Parent = page, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, -12, 0, 0), Position = UDim2.new(0,6,0,56), ClipsDescendants = true, BorderSizePixel = 0})
            new("UICorner", {Parent = list, CornerRadius = UDim.new(0,6)})
            local selected = nil
            local layout = new("UIListLayout", {Parent = list, Padding = UDim.new(0,4)})

            local function refreshList()
                for i,v in ipairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for i,opt in ipairs(options or {}) do
                    local b = new("TextButton", {Parent = list, Text = tostring(opt), BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 26), Position = UDim2.new(0,4,0,4), TextColor3 = Theme.Text, Font = Enum.Font.SourceSans, TextSize = 14})
                    b.MouseButton1Click:Connect(function()
                        selected = opt
                        pcall(callback, opt)
                        list:TweenSize(UDim2.new(1, -12, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                        open = false
                    end)
                end
            end

            refreshList()
            box.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local h = #options * 30
                    list:TweenSize(UDim2.new(1, -12, 0, h), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                else
                    list:TweenSize(UDim2.new(1, -12, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                end
            end)
            return {Get = function() return selected end, Refresh = refreshList}
        end
        function section:Slider(text, min, max, default, callback)
            min = min or 0; max = max or 100; default = default or min
            local label = new("TextLabel", {Parent = page, Text = text.." "..tostring(default), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.SourceSans, TextSize = 14, Size = UDim2.new(1, -12, 0, 18), Position = UDim2.new(0,6,0,6), TextXAlignment = Enum.TextXAlignment.Left})
            local bar = new("Frame", {Parent = page, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0,6,0,30), BorderSizePixel = 0})
            new("UICorner", {Parent = bar, CornerRadius = UDim.new(0,6)})
            local fill = new("Frame", {Parent = bar, BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, default/(max-min), 1, 0), Position = UDim2.new(0,0,0,0), BorderSizePixel = 0})
            local knob = new("ImageButton", {Parent = bar, BackgroundTransparency = 1, Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(fill.Size.X.Scale - 0.03, 0, 0, 0), AutoButtonColor = false})

            local dragging = false
            local function setValueFromX(x)
                local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel - 0.03, 0, 0, 0)
                local val = min + rel * (max - min)
                label.Text = text.." "..math.floor(val)
                pcall(callback, val)
            end
            knob.MouseButton1Down:Connect(function(x, y)
                dragging = true
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    setValueFromX(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            -- allow click on bar
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setValueFromX(input.Position.X)
                end
            end)
            return {Get = function()
                return min + fill.Size.X.Scale * (max-min)
            end}
        end

        return section
    end

    return window
end

return SimpleDarkUI
