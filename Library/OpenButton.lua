local ToggleUI = {}

function ToggleUI.Create(window)
    assert(window, "ToggleUI.Create() membutuhkan window WindUI!")
	local UIS = game:GetService("UserInputService")
	local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Hapus gui lama jika ada
    for _, obj in ipairs(playerGui:GetChildren()) do
        if obj.Name == "PhoenixHUB" and obj:IsA("ScreenGui") then
            obj:Destroy()
        end
    end

    -- Buat UI utama toggle button (selalu aktif)
    local gui = Instance.new("ScreenGui")
    gui.Name = "PhoenixHUB"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    gui.Enabled = true

    -- Toggle Button
    local button = Instance.new("ImageButton")
    button.Name = "ToggleButton"
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = UDim2.new(0.95, 0, 0.5, 0)
    button.Size = UDim2.new(0.055, 0, 0.12, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.Image = "rbxassetid://140413750237602"
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = gui

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.Parent = button
    aspect.AspectRatio = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button

    -- Dragging
    local dragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Toggle action
    button.MouseButton1Click:Connect(function()
		task.wait(0.5)
        window:Toggle()
    end)

    return gui
end

return ToggleUI
