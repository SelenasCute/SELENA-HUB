local module = {}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Data = {
	OriginalTransparencyData = {}
}

function module:HideAllObject(state)
	if state then
		for _, obj in ipairs(Workspace.Assets:GetDescendants()) do
			if (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) and obj.Transparency < 1 then
				Data.OriginalTransparencyData[obj] = Data.OriginalTransparencyData[obj] or obj.Transparency
				obj.Transparency = 1
			end
		end
	else
		for obj, value in pairs(Data.OriginalTransparencyData) do
			if obj and obj.Parent then obj.Transparency = value end
		end
		Data.OriginalTransparencyData = {}
	end
end

function module:ShowOreInside(state)

	local function RemoveOreESP(rock)
		for _, ore in ipairs(rock:GetChildren()) do
			if ore:IsA("Model") and ore.Name == "Ore" then
				ore:FindFirstChild("OreBillboard")?.Destroy()
				ore:FindFirstChild("OreHighlight")?.Destroy()
			end
		end
	end

	local function CreateOreBillboard(rock)
		if not (rock:IsA("Model") and rock:FindFirstChild("Hitbox")) then return end
		if rock:GetAttribute("LastHitPlayer") ~= Player.Name or not state then
			return RemoveOreESP(rock)
		end

		for _, ore in ipairs(rock:GetChildren()) do
			if ore:IsA("Model") and ore.Name == "Ore" and not ore:FindFirstChild("OreBillboard") then
				local bb = Instance.new("BillboardGui", ore)
				bb.Name, bb.Adornee, bb.Size = "OreBillboard", ore.PrimaryPart or ore, UDim2.new(4,0,0.8,0)
				bb.StudsOffsetWorldSpace, bb.AlwaysOnTop, bb.MaxDistance = Vector3.new(0,1.5,0), true, 100

				local hl = Instance.new("Highlight", ore)
				hl.Name, hl.FillColor = "OreHighlight", Color3.fromRGB(0,255,0)

				local text = Instance.new("TextLabel", bb)
				text.Size, text.BackgroundTransparency = UDim2.fromScale(1,1), 1
				text.Text, text.TextScaled, text.Font = ore:GetAttribute("Ore") or "Unknown", true, Enum.Font.SourceSansBold
				text.TextColor3 = Color3.new(1,1,1)

				Instance.new("UIStroke", text).Thickness = 2
			end
		end
	end

	for _, rock in ipairs(workspace.Rocks:GetDescendants()) do
		if rock:IsA("Model") and rock.Parent.Name == "SpawnLocation" then
			rock.ChildAdded:Connect(function(c) if c.Name == "Ore" then CreateOreBillboard(rock) end end)
			rock.ChildRemoved:Connect(function(c) if c.Name == "Ore" then CreateOreBillboard(rock) end end)
			CreateOreBillboard(rock)
		end
	end
end

function module:FindNearestRock(rockname)
	local char = Player.Character
	local HRP = char and char:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local nearest, dist = nil, math.huge
	local types = type(rockname) == "table" and rockname or { rockname }

	for _, rock in ipairs(workspace.Rocks:GetDescendants()) do
		if rock:IsA("Model") and rock.Parent?.Name == "SpawnLocation" and rock:FindFirstChild("Hitbox") then
			for _, t in ipairs(types) do
				if rock.Name == t then
					local d = (rock.Hitbox.Position - HRP.Position).Magnitude
					if d < dist then dist, nearest = d, rock end
				end
			end
		end
	end
	return nearest
end

function module:UpdatePlayerInfo_PG(info, gold, level, stash, status)
	if not info then return end
	info:SetDesc((
		'• Gold: <font color="#ffcc00">%s</font><br/>' ..
		'• Level: <font color="#ffcc00">%s</font><br/>' ..
		'• Stash: <font color="#ffcc00">%s</font><br/>' ..
		'• Status: <font color="#ffcc00">%s</font>'
	):format(gold, level, stash, status))
end

return module
