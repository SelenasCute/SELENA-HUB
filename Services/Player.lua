--[[ SERVICES & VARIABLES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Config = {
	-- VISUAL
	PlayerESPEnabled = false,

	InfiniteJumpEnabled = false,
	NoClipEnabled = false,
	FlyEnabled = false,
	FlySpeed = 50,
	FlyBodyGyro = nil,
	FlyBodyVelocity = nil,

	ESPObjects = {} -- tempat penyimpanan highlight dan tag
}

--[[ CONNECTIONS ]]
UserInputService.JumpRequest:Connect(function()
	if Config.InfiniteJumpEnabled and Humanoid then
		Humanoid:ChangeState("Jumping")
	end
end)

RunService.Stepped:Connect(function()
	if Config.NoClipEnabled and Character then
		for _, part in pairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = not Config.NoClipEnabled
			end
		end
	end
end)

--[[ ALL FUNCTION ]]
local function CreateESPForPlayer(target)
	if target == Player then return end
	local character = target.Character
	if not character or Config.ESPObjects[target] then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character

	local head = character:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESPTag"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = target.Name
		label.TextColor3 = Color3.fromRGB(255, 0, 0)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextScaled = true
		label.Parent = billboard

		Config.ESPObjects[target] = {highlight, billboard}
	end
end

local function RemoveESPForPlayer(target)
	if Config.ESPObjects[target] then
		for _, obj in ipairs(Config.ESPObjects[target]) do
			if obj and obj.Parent then
				obj:Destroy()
			end
		end
		Config.ESPObjects[target] = nil
	end
end

function TogglePlayerESP(state)
	Config.PlayerESPEnabled = state

	if state then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Player then
				CreateESPForPlayer(p)
			end
		end

		Players.PlayerAdded:Connect(function(p)
			p.CharacterAdded:Connect(function()
				if Config.PlayerESPEnabled then
					task.wait(1)
					CreateESPForPlayer(p)
				end
			end)
		end)

		Players.PlayerRemoving:Connect(function(p)
			RemoveESPForPlayer(p)
		end)
	else
		for _, objs in pairs(Config.ESPObjects) do
			for _, obj in ipairs(objs) do
				if obj and obj.Parent then
					obj:Destroy()
				end
			end
		end
		Config.ESPObjects = {}
	end
end

function SetWalkSpeed(value)
	if Humanoid then Humanoid.WalkSpeed = value end
end

function SetJumpPower(value)
	if Humanoid then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = value
	end
end

function SetFlySpeed(value)
	Config.FlySpeed = value
end

function ToggleFly(state)
	Config.FlyEnabled = state
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	if state then
		Humanoid.PlatformStand = true

		Config.FlyBodyGyro = Instance.new("BodyGyro")
		Config.FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		Config.FlyBodyGyro.P = 9e4
		Config.FlyBodyGyro.CFrame = HRP.CFrame
		Config.FlyBodyGyro.Parent = HRP

		Config.FlyBodyVelocity = Instance.new("BodyVelocity")
		Config.FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		Config.FlyBodyVelocity.Velocity = Vector3.zero
		Config.FlyBodyVelocity.Parent = HRP

		RunService.RenderStepped:Connect(function()
			if not Config.FlyEnabled or not HRP then return end

			local camCF = workspace.CurrentCamera.CFrame
			local moveDir = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

			Config.FlyBodyGyro.CFrame = camCF
			Config.FlyBodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * Config.FlySpeed or Vector3.zero
		end)
	else
		Humanoid.PlatformStand = false
		if Config.FlyBodyGyro then Config.FlyBodyGyro:Destroy() Config.FlyBodyGyro = nil end
		if Config.FlyBodyVelocity then Config.FlyBodyVelocity:Destroy() Config.FlyBodyVelocity = nil end
	end
end

function OpenFlyGuiMobile()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Fly GUI",
		Text = "Fly GUI Successfully Open.",
		Duration = 3
	})
	loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/FlyGUI_v7.lua", true))()
end

function ToggleInfiniteJump(state)
	Config.InfiniteJumpEnabled = state
end

function ToggleNoClip(state)
	Config.NoClipEnabled = state
end

Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")

	if Config.InfiniteJumpEnabled then ToggleInfiniteJump(true) end
	if Config.NoClipEnabled then ToggleNoClip(true) end
	if Config.FlyEnabled then
		task.wait(1)
		ToggleFly(true)
	end
	if Config.PlayerESPEnabled then
		task.wait(1)
		TogglePlayerESP(true)
	end
end)

return {
	SetWalkSpeed = SetWalkSpeed,
	SetJumpPower = SetJumpPower,
	SetFlySpeed = SetFlySpeed,
	ToggleFly = ToggleFly,
	OpenFlyGuiMobile = OpenFlyGuiMobile,
	ToggleInfiniteJump = ToggleInfiniteJump,
	ToggleNoClip = ToggleNoClip,
	TogglePlayerESP = TogglePlayerESP
}
