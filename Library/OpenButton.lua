--// File: ToggleUI.lua
--[[===========================================
 Phoenix HUB UI Toggle Module
 @uniquadev - 2025
=============================================]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ToggleUI = {}
local gui
function ToggleUI.Create(window)
	assert(window, "ToggleUI.Create() membutuhkan window WindUI!")

	--[[ UI ]]--
	gui = Instance.new("ScreenGui")
	gui.Name = "PhoenixHUB"
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
	button.Image = "rbxassetid://140413750237602"
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = gui

	local uiAspect = Instance.new("UIAspectRatioConstraint")
	uiAspect.AspectRatio = 1
	uiAspect.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

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
		end)
	end
	
	if window.OnClose then
		window:OnClose(function()
			gui.Enabled = true
		end)
	end
	
	if window.OnDestroy then
		window:OnDestroy(function()
			gui:Destroy()
		end)
	end

	return gui
end

function ToggleUI.Destroy()
	gui:Destroy()
end

return ToggleUI
