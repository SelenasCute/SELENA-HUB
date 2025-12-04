local ToggleUI = {}

function ToggleUI.Create(window)
    assert(window, "ToggleUI.Create() membutuhkan window WindUI!")
	local UIS = game:GetService("UserInputService")
	local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
	local Camera = workspace.CurrentCamera

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
	gui.IgnoreGuiInset = true

    -- Toggle Button
    local button = Instance.new("ImageButton")
    button.Name = "ToggleButton"
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = UDim2.new(0.95, 0, 0.5, 0)
    button.Size = UDim2.new(0, 60, 0, 60) -- Base size in pixels
    button.BackgroundColor3 = Color3.fromRGB(255, 25, 25)
    button.Image = "rbxassetid://140413750237602"
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = gui

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.Parent = button
    aspect.AspectRatio = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = button

    -- UIGradient untuk stroke (rotasi orange)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),   -- Dark orange
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)), -- Light orange
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))    -- Dark orange
	}
	gradient.Rotation = 0
	gradient.Parent = stroke
	
	-- Animasi rotasi gradient
	task.spawn(function()
		while button and button.Parent do
			for i = 0, 360, 2 do
				if not button or not button.Parent then break end
				gradient.Rotation = i
				task.wait(0.016) -- ~60 FPS
			end
		end
	end)

	-- Base size untuk referensi (PC standard)
	local BASE_WIDTH = 1920
	local BASE_BUTTON_SIZE = 60
	
	-- Function to resize & reposition button sesuai viewport
    local function updateButtonSize()
        local vp = Camera.ViewportSize
		
		-- Hitung scale factor berdasarkan lebar viewport
		local scaleFactor = vp.X / BASE_WIDTH
		
		-- Clamp scale factor agar tidak terlalu kecil atau besar
		scaleFactor = math.clamp(scaleFactor, 0.5, 1.5)
		
		-- Terapkan scale ke button
		local newSize = BASE_BUTTON_SIZE * scaleFactor
        button.Size = UDim2.new(0, newSize, 0, newSize)
		
		-- Update stroke thickness juga
		stroke.Thickness = math.max(2, 3 * scaleFactor)
    end

    updateButtonSize()
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateButtonSize)

    -- Dragging
    local dragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
		                 input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Toggle Window
	local db = false
	local db_time = 0.5
    button.MouseButton1Click:Connect(function()
		if db == true then return end
		db = true
        window:Toggle()
		task.wait(db_time)
		db = false
    end)

    return gui
end

return ToggleUI