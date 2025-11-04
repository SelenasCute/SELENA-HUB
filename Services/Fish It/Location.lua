-- LocationModule.lua
-- Module berisi data lokasi dan fungsi teleportasi

local LocationModule = {}

LocationModule.LOCATIONS = {
    ["Island"] = {
        ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
        ["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744),
        ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295),
        ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727),
        ["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295),
        ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
        ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
        ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
        ["Mount Hallow"] = CFrame.new(2136.62305, 78.9163895, 3272.50439),
        ["Treasure Room"] = CFrame.new(-3599.586914, -266.573730, -1579.458374),
        ["Enchant Room"] = CFrame.new(3242.089111, -1300.549805, 1396.246948),
        ["Admin Spot"] = CFrame.new(-1952.032471, -440.000366, 7388.525879),
        ["Arrow Artifact"] = CFrame.new(883.135437, 6.625000, -350.100250),
        ["Diamond Artifact"] = CFrame.new(1836.316040, 6.342771, -298.546265),
        ["Hourglass Artifact"] = CFrame.new(1480.986450, 6.275698, -847.142029),
        ["Crescent Artifact"] = CFrame.new(1409.407471, 6.625000, 115.430603),
        ["Second Enchant"] = CFrame.new(1478.971313, 127.624985, -593.211487),
        ["Sacred Temple"] = CFrame.new(1466.92151, -21.8750591, -622.835693),
    },

    ["GameEvent"] = {
        ["Shark Hunt #1"] = CFrame.new(1.618872, -2.657876, 2095.760986),
        ["Shark Hunt #2"] = CFrame.new(1369.921387, -2.509888, 930.124329),
        ["Shark Hunt #3"] = CFrame.new(-1585.528076, -2.506555, 1242.876343),
        ["Shark Hunt #4"] = CFrame.new(-1896.818604, -3.018769, 2634.364990),
        ["Ghost Shark Hunt #1"] = CFrame.new(489.527069, -2.674266, 25.438305),
        ["Ghost Shark Hunt #2"] = CFrame.new(-1358.253296, -2.790521, 4100.588379),
        ["Work Hunt #1"] = CFrame.new(2190.818359, -2.574958, 97.584175),
        ["Work Hunt #2"] = CFrame.new(-2450.721924, -2.998081, 139.783768),
        ["Megalodon Hunt #1"] = CFrame.new(-1076.335205, -2.575847, 1676.218384),
        ["Admin - Black Hole"] = CFrame.new(882.970825, -2.641524, 2542.000000),
    },

    ["NPC"] = {
        ["Alex"] = CFrame.new(49.000000, 17.408613, 2880.000000),
        ["Alient Merchant"] = CFrame.new(-134.000000, 1.561833, 2762.000000),
        ["Aura Kid"] = CFrame.new(71.000000, 17.333540, 2830.000000),
        ["Billy Bob"] = CFrame.new(80.000000, 17.409086, 2876.000000),
        ["Boat Expert"] = CFrame.new(33.000000, 9.633092, 2783.000000),
        ["Joe"] = CFrame.new(144.000000, 20.408552, 2862.000000),
        ["Lava Fisherman"] = CFrame.new(-594.840027, 59.000057, 133.179993),
        ["Ron"] = CFrame.new(-52.000000, 17.283503, 2859.000000),
        ["Scientist"] = CFrame.new(-7.000000, 17.658651, 2886.000000),
        ["Scott"] = CFrame.new(-16.999994, 9.531570, 2703.045410),
        ["Seth"] = CFrame.new(111.000000, 17.408613, 2877.000000),
        ["Silly Fisherman"] = CFrame.new(102.000000, 9.649474, 2690.000000),
    }
}

function LocationModule.TeleportTo(typeName, locationName)
    local typeTable = LocationModule.LOCATIONS[typeName]
    if not typeTable then
        warn("❌ Invalid location type:", typeName)
        return false, "Invalid location type"
    end
    
    local cframe = typeTable[locationName]
    if not cframe then
        warn("❌ Location not found:", locationName)
        return false, "Location not found"
    end
    
    local player = game.Players.LocalPlayer
    if not player then
        warn("❌ LocalPlayer not found")
        return false, "LocalPlayer not found"
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = cframe
        print("✅ Teleported to", typeName, "-", locationName)
        return true
    else
        warn("❌ HumanoidRootPart not found")
        return false, "HumanoidRootPart not found"
    end
end

return LocationModule
