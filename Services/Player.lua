--[[
    Player Utility Module
    Provides core movement & ability functions for the Player tab UI.
    Author: xeAtheo
    Last Update: 2025-11-04
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- STATE
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local WalkOnWaterEnabled = false

-- ✅ WALK SPEED
local function SetWalkSpeed(value)
	if Humanoid then
		Humanoid.WalkSpeed = value
	end
end

-- ✅ JUMP POWER
local function SetJumpPower(value)
	if Humanoid then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = value
	end
end

-- ✅ FLY SPEED
local FlyConnection
local function SetFlySpeed(value)
	if not Player or not Player.Character then return end
	local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	
	if FlyConnection then FlyConnection:Disconnect() end
	FlyConnection = RunService.RenderStepped:Connect(function()
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			HRP.Velocity = Vector3.new(HRP.Velocity.X, value, HRP.Velocity.Z)
		end
	end)
end

-- ✅ FLY GUI (MOBILE)
local function OpenFlyGuiMobile()
	-- Placeholder - bisa ganti dengan gui khusus mobile
	game.StarterGui:SetCore("SendNotification", {
		Title = "Fly GUI",
		Text = "Mobile fly control will open soon.",
		Duration = 3
	})
end

-- ✅ INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
	if InfiniteJumpEnabled and Humanoid then
		Humanoid:ChangeState("Jumping")
	end
end)

local function ToggleInfiniteJump(state)
	InfiniteJumpEnabled = state
end

-- ✅ NOCLIP
RunService.Stepped:Connect(function()
	if NoClipEnabled and Character then
		for _, part in pairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

local function ToggleNoClip(state)
	NoClipEnabled = state
end

-- ✅ WALK ON WATER
RunService.Heartbeat:Connect(function()
	if WalkOnWaterEnabled and Character then
		local hrp = Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local waterLevel = workspace.Terrain:ReadVoxels(
				Region3.new(hrp.Position - Vector3.new(3, 3, 3), hrp.Position + Vector3.new(3, 3, 3)),
				4
			)
			-- Simulasi "mengapung" di atas air
			if waterLevel then
				hrp.Velocity = Vector3.new(hrp.Velocity.X, math.max(hrp.Velocity.Y, 2), hrp.Velocity.Z)
			end
		end
	end
end)

local function ToggleWalkOnWater(state)
	WalkOnWaterEnabled = state
end

-- ✅ RETURN MODULE
return {
	SetWalkSpeed = SetWalkSpeed,
	SetJumpPower = SetJumpPower,
	SetFlySpeed = SetFlySpeed,
	OpenFlyGuiMobile = OpenFlyGuiMobile,
	ToggleInfiniteJump = ToggleInfiniteJump,
	ToggleNoClip = ToggleNoClip,
	ToggleWalkOnWater = ToggleWalkOnWater,
}
