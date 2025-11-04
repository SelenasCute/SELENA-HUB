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

--// Walk On Water System
-- Author: xeAtheo
-- Auto-creates transparent platforms over water near player (radius 50)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain
local Player = Players.LocalPlayer

local WalkOnWaterEnabled = false
local Radius = 50
local PlatformFolder = workspace:FindFirstChild("WaterPlatforms") or Instance.new("Folder", workspace)
PlatformFolder.Name = "WaterPlatforms"

-- Fungsi buat spawn platform di posisi tertentu
local function CreateWaterPlatform(posY, posX, posZ)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = true
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(135, 206, 235)
	part.Transparency = 0.6
	part.Size = Vector3.new(6, 0.3, 6)
	part.CFrame = CFrame.new(posX, posY, posZ)
	part.Parent = PlatformFolder
	game.Debris:AddItem(part, 1)
end

-- Loop utama: cek area sekitar player
local function WalkOnWaterLoop()
	while WalkOnWaterEnabled do
		task.wait(1)

		local character = Player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local center = hrp.Position
		local step = 6 -- jarak antar scan grid
		for x = -Radius, Radius, step do
			for z = -Radius, Radius, step do
				local checkPos = Vector3.new(center.X + x, center.Y - 5, center.Z + z)
				local voxelRegion = Region3.new(checkPos - Vector3.new(2, 4, 2), checkPos + Vector3.new(2, 0, 2))
				local materials = Terrain:ReadVoxels(voxelRegion, 4)
				local hasWater = false

				for i = 1, materials.Size.X do
					for j = 1, materials.Size.Y do
						for k = 1, materials.Size.Z do
							if materials[i][j][k] == Enum.Material.Water then
								hasWater = true
								break
							end
						end
					end
				end

				if hasWater then
					CreateWaterPlatform(checkPos.Y + 6, checkPos.X, checkPos.Z)
				end
			end
		end
	end
end

-- ✅ Fungsi Toggle
local function ToggleWalkOnWater(state)
	WalkOnWaterEnabled = state

	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	if state then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		task.spawn(WalkOnWaterLoop)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
		for _, v in ipairs(PlatformFolder:GetChildren()) do
			if v:IsA("BasePart") then v:Destroy() end
		end
	end
end

-- Return biar bisa dipanggil dari WindUI
return {
	ToggleWalkOnWater = ToggleWalkOnWater
}


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
