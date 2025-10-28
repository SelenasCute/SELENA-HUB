--// File: ToggleUI.lua
--[[===========================================
 Selena HUB UI Toggle Module
 @uniquadev - 2025
=============================================]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ToggleUI = {}

function ToggleUI.Create(window)
	assert(window, "ToggleUI.Create() membutuhkan window WindUI!")

	--[[ UI ]]--
	local gui = Instance.new("ScreenGui")
	gui.Name = "SelenaHub_Toggle"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	gui.Enabled = false -- ⬅️ Tambahkan ini

	local button = Instance.new("ImageButton")
	button.Name = "ToggleButton"
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.new(0.975, 0, 0.5, 0)
	button.Size = UDim2.new(0.031, 0, 0.056, 0)
	button.BackgroundColor3 = Color3.fromRGB(255, 115, 230)
	button.Image = "rbxassetid://112969347193102"
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	local hover = Instance.new("TextLabel")
	hover.Name = "Hover"
	hover.AnchorPoint = Vector2.new(0, 0.5)
	hover.Position = UDim2.new(-1.775, 0,-0.497, 0)
	hover.Size = UDim2.new(2.775, 0,0.619, 0)
	hover.BackgroundTransparency = 1
	hover.Text = "Open Selena HUB"
	hover.TextScaled = true
	hover.TextXAlignment = Enum.TextXAlignment.Right
	hover.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	hover.TextColor3 = Color3.new(1, 1, 1)
	hover.Visible = false
	hover.Parent = button

	local hover_stroke = Instance.new("UIStroke")
	hover_stroke.Thickness = 2
	hover_stroke.Color = Color3.fromRGB(0, 0, 0)
	hover_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	hover_stroke.Parent = hover

	-- Hover effect
	local defaultSize = button.Size
	button.MouseEnter:Connect(function()
		hover.Visible = true
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(defaultSize.X.Scale * 1.1, 0, defaultSize.Y.Scale * 1.1, 0)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		hover.Visible = false
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = defaultSize
		}):Play()
	end)

	-- Draggable stabil
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

	-- Klik toggle UI
	button.MouseButton1Click:Connect(function()
		window:Toggle()
	end)

	-- Hubungkan dengan event window
	if window.OnOpen then
		window:OnOpen(function()
			gui.Enabled = false
			hover.Visible = false
		end)
	end
	
	if window.OnClose then
		window:OnClose(function()
			gui.Enabled = true
			hover.Visible = false
		end)
	end
	
	if window.OnDestroy then
		window:OnDestroy(function()
			gui:Destroy()
		end)
	end

	return gui
end

return ToggleUI
