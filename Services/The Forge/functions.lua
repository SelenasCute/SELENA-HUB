local module = {}

local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Players = game.Players
local Player = Players.LocalPlayer

local Data = {
	OriginalTransparencyData = {},
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
			if obj and obj.Parent then
				obj.Transparency = value
			end
		end
		Data.OriginalTransparencyData = {}
	end
end

function module:ShowOreInside(state)
    local RockFolder = workspace:WaitForChild("Rocks")
    
    local function RemoveOreESP(rock)
        for _, ore in ipairs(rock:GetChildren()) do
            if ore:IsA("Model") and ore.Name == "Ore" then
                ore:FindFirstChild("OreBillboard")?.Destroy(ore:FindFirstChild("OreBillboard"))
                ore:FindFirstChild("OreHighlight")?.Destroy(ore:FindFirstChild("OreHighlight"))
            end
        end
    end

    local function CreateOreBillboard(rock)
        if not (rock:IsA("Model") and rock:FindFirstChild("Hitbox")) then return end
        if rock:GetAttribute("LastHitPlayer") ~= Player.Name then
            RemoveOreESP(rock)
            return
        end

        if not state then
            RemoveOreESP(rock)
            return
        end

        for _, ore in ipairs(rock:GetChildren()) do
            if ore:IsA("Model") and ore.Name == "Ore" and not ore:FindFirstChild("OreBillboard") then
                local bb = Instance.new("BillboardGui", ore)
                bb.Name = "OreBillboard"
                bb.Adornee = ore.PrimaryPart or ore
                bb.Size = UDim2.new(4, 0, 0.8, 0)
                bb.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
                bb.AlwaysOnTop = true
                bb.MaxDistance = 100

                local hl = Instance.new("Highlight", ore)
                hl.Name = "OreHighlight"
                hl.FillColor = Color3.fromRGB(0, 255, 0)

                local text = Instance.new("TextLabel", bb)
                text.Size = UDim2.fromScale(1, 1)
                text.BackgroundTransparency = 1
                text.Text = ore:GetAttribute("Ore") or "Unknown"
                text.TextColor3 = Color3.new(1,1,1)
                text.TextScaled = true
                text.Font = Enum.Font.SourceSansBold

                Instance.new("UIStroke", text).Thickness = 2
            end
        end
    end

    for _, rock in ipairs(RockFolder:GetDescendants()) do
        if rock:IsA("Model") and rock.Parent.Name == "SpawnLocation" then

            rock.ChildAdded:Connect(function(child)
                if child:IsA("Model") and child.Name == "Ore" then
                    CreateOreBillboard(rock)
                end
            end)

            rock.ChildRemoved:Connect(function(child)
                if child:IsA("Model") and child.Name == "Ore" then
                    CreateOreBillboard(rock)
                end
            end)

            CreateOreBillboard(rock)
        end
    end
end

function module:HighlightRock()
    local RockFolder = workspace
    local connection

    local function UpdateRock(rock)
        if not (rock:IsA("Model") and rock.Parent and rock.Parent.Name == "SpawnLocation") then
            return
        end

        local shouldHighlight = false
        for _, rn in ipairs(rnList) do
            if rock.Name == rn then
                shouldHighlight = true
                break
            end
        end

        if Configs["RockESPEnabled"] and shouldHighlight then
            if not rock:FindFirstChild("RockESP_Highlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "RockESP_Highlight"
                hl.Adornee = rock
                hl.FillColor = Color3.fromHex("#00ff00")
                hl.OutlineColor = Color3.fromHex("#ffffff")
                hl.Parent = rock
            end

            if not rock:FindFirstChild("RockESP_Label") then
                local bb = Instance.new("BillboardGui")
                bb.Name = "RockESP_Label"
                bb.Size = UDim2.new(0, 100, 0, 50)
                bb.Adornee = rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
                bb.AlwaysOnTop = true

                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = rock.Name
                text.TextColor3 = Color3.fromHex("#ffffff")
                text.TextScaled = true
                text.Parent = bb

                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromHex("#000000")
                stroke.Thickness = 3
                stroke.Parent = text

                bb.Parent = rock
            end
        else
            rock:FindFirstChild("RockESP_Highlight")?.Destroy()
            rock:FindFirstChild("RockESP_Label")?.Destroy()
        end
    end

    -- Update rock yang sudah ada
    for _, rock in ipairs(RockFolder:GetDescendants()) do
        UpdateRock(rock)
    end

    -- Listen rock baru (1x saja)
    if not self._rockConnection then
        self._rockConnection = RockFolder.DescendantAdded:Connect(function(desc)
            if desc:IsA("Model") then
                task.wait()
                UpdateRock(desc)
            end
        end)
    end
end

function module:FindNearestRock(rockname)
    local char = Player.Character
    if not char then return nil end

    local HRP = char:FindFirstChild("HumanoidRootPart")
    if not HRP or not RockFolder then return nil end

    local nearestRock
    local shortestDistance = math.huge
    local searchTypes = type(rockname) == "table" and rockname or {rockname}

    for _, rock in ipairs(RockFolder:GetDescendants()) do
        if rock:IsA("Model")
        and rock.Parent
        and rock.Parent.Name == "SpawnLocation"
        and rock:FindFirstChild("Hitbox") then
        --and not rock:GetAttribute("LastHitPlayer") ~= player.Name then

            for _, rockType in ipairs(searchTypes) do
                if rock.Name == rockType then
                    local dist = (rock.Hitbox.Position - HRP.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearestRock = rock
                    end
                    break
                end
            end
        end
    end

    return nearestRock
end

return module
