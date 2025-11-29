--// File: ToggleUI.lua
--[[===========================================
 Phoenix HUB UI Toggle Module
 @uniquadev - 2025
=============================================]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local gui = PlayerGui:FindFirstChild("PhoenixHUB")
if not gui then
	gui = Instance.new("ScreenGui")
end

local Module = {}

function Module.Init(window)
	assert(window, "ToggleUI.Create() membutuhkan window WindUI!")

	-- UI utama toggle button (selalu aktif)
	gui.Name = "PhoenixHUB"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	gui.Enabled = true

	-- Toggle Button
	local button = Instance.new("ImageButton")
	button.Name = "ToggleButton"
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.new(0.97, 0, 0.5, 0)
	button.Size = UDim2.new(0.031, 0, 0.056, 0)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	button.Image = "rbxassetid://140413750237602"
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = gui

	Instance.new("UIAspectRatioConstraint", button).AspectRatio = 1
	Instance.new("UICorner", button).CornerRadius = UDim.new(0.5, 0)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	-- Draggable
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

	game.UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			button.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	button.MouseButton1Click:Connect(function()
		window:Toggle()
	end)

	window:OnDestroy(function()
		gui:Destroy()
	end)

	window:OnClose(function()
		gui.Enabled = true
	end)

	window:OnOpen(function()
		gui.Enabled = false
	end)

	return gui
end


return Module
