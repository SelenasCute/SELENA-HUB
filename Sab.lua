for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)
