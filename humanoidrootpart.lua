-- Cambiar la configuración del aimbot para apuntar al torso
local AimbotSettings = {
    Enabled = true,
    Hitpart = "HumanoidRootPart", -- Cambiado de "Head" a "HumanoidRootPart" para el torso
    MaxDistance = 250,
    TeamCheck = false,
    FOV = 100,
    PredictionFactor = 0.03,
    SnapSpeed = 1
}

-- El resto del código permanece igual, solo actualizo la referencia en GetClosestPlayer
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local LocalCharacter = LocalPlayer.Character
    if not LocalCharacter or not LocalCharacter:FindFirstChild("HumanoidRootPart") then return nil end
    local LocalRoot = LocalCharacter.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local Character = player.Character
            if Character and Character:FindFirstChild(AimbotSettings.Hitpart) and Character:FindFirstChild("Humanoid") then
                local Humanoid = Character.Humanoid
                if Humanoid.Health <= 0 then continue end
                
                local TargetPart = Character[AimbotSettings.Hitpart] -- Ahora usa HumanoidRootPart
                local Distance = (LocalRoot.Position - TargetPart.Position).Magnitude
                
                if Distance <= AimbotSettings.MaxDistance then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    if OnScreen then
                        local MouseDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                        if MouseDistance < AimbotSettings.FOV and MouseDistance < ShortestDistance then
                            ShortestDistance = MouseDistance
                            ClosestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

-- El resto del código (InputBegan, InputEnded, RenderStepped) sigue funcionando igual
