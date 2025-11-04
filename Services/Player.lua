--[[
    Player Utility Module
    Provides movement & ability functions for Player tab.
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
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyGyro, FlyBodyVelocity

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

-- ✅ TRUE FLY SYSTEM
local function SetFlySpeed(value)
	FlySpeed = value
end

local function ToggleFly(state)
	FlyEnabled = state
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	if state then
		Humanoid.PlatformStand = true

		FlyBodyGyro = Instance.new("BodyGyro")
		FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		FlyBodyGyro.P = 9e4
		FlyBodyGyro.CFrame = HRP.CFrame
		FlyBodyGyro.Parent = HRP

		FlyBodyVelocity = Instance.new("BodyVelocity")
		FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		FlyBodyVelocity.Velocity = Vector3.zero
		FlyBodyVelocity.Parent = HRP

		RunService.RenderStepped:Connect(function()
			if not FlyEnabled or not HRP or not Character or not Character.Parent then return end

			local camCF = workspace.CurrentCamera.CFrame
			local moveDir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDir += camCF.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDir -= camCF.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDir -= camCF.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDir += camCF.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveDir += Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveDir -= Vector3.new(0, 1, 0)
			end

			FlyBodyGyro.CFrame = camCF
			FlyBodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * FlySpeed or Vector3.zero
		end)
	else
		Humanoid.PlatformStand = false
		if FlyBodyGyro then FlyBodyGyro:Destroy() end
		if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
	end
end

-- ✅ FLY GUI (MOBILE)
local function OpenFlyGuiMobile()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Fly GUI",
		Text = "Mobile fly control coming soon.",
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

-- ✅ WALK ON WATER (BUAT PLATFORM DI BAWAH KAKI)
local WaterPart
RunService.Heartbeat:Connect(function()
	if WalkOnWaterEnabled then
		local HRP = Character:FindFirstChild("HumanoidRootPart")
		if not HRP then return end

		local ray = Ray.new(HRP.Position, Vector3.new(0, -5, 0))
		local part, pos = workspace:FindPartOnRay(ray, Character)

		if part and part.Material == Enum.Material.Water then
			if not WaterPart then
				WaterPart = Instance.new("Part")
				WaterPart.Anchored = true
				WaterPart.Size = Vector3.new(6, 1, 6)
				WaterPart.Transparency = 1
				WaterPart.CanCollide = true
				WaterPart.Parent = workspace
			end
			WaterPart.Position = Vector3.new(HRP.Position.X, pos.Y + 1, HRP.Position.Z)
		elseif WaterPart then
			WaterPart:Destroy()
			WaterPart = nil
		end
	elseif WaterPart then
		WaterPart:Destroy()
		WaterPart = nil
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
	ToggleFly = ToggleFly,
	OpenFlyGuiMobile = OpenFlyGuiMobile,
	ToggleInfiniteJump = ToggleInfiniteJump,
	ToggleNoClip = ToggleNoClip,
	ToggleWalkOnWater = ToggleWalkOnWater,
}
