local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Holding = false
local LockedTarget = nil -- Variable para bloquear al objetivo

-- Configuración del aimbot (blatant para Da Hood)
local AimbotSettings = {
    Enabled = true,
    Hitpart = "UpperTorso", -- Cambiado de "Head" a "UpperTorso"
    MaxDistance = 250, -- Rango amplio para combates lejanos
    TeamCheck = false, -- Todos son enemigos, sin excepciones
    FOV = 100, -- Campo de visión grande para lockear fácil
    PredictionFactor = 0.03, -- Predicción ligera para no pasarse
    SnapSpeed = 1 -- Snap instantáneo, sin suavizado
}

-- Esperar a que el personaje del jugador local se cargue
local function WaitForCharacter()
    LocalPlayer.CharacterAppearanceLoaded:Wait()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
end

-- Función de predicción (mínima para Da Hood)
local function PredictPosition(TargetPart)
    if not TargetPart then return nil end
    local Velocity = TargetPart.Velocity or Vector3.new(0, 0, 0)
    return TargetPart.Position + (Velocity * AimbotSettings.PredictionFactor)
end

-- Función para encontrar al jugador más cercano
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
                
                local TargetPart = Character[AimbotSettings.Hitpart]
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

-- Detectar clic derecho (activación blatant)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
        if not LockedTarget then -- Solo busca un nuevo objetivo si no hay uno bloqueado
            LockedTarget = GetClosestPlayer()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
        LockedTarget = nil -- Libera el objetivo al soltar el botón
    end
end)

-- Lógica del aimbot (snap directo, estilo Da Hood)
RunService.RenderStepped:Connect(function()
    if not AimbotSettings.Enabled or not Holding then return end
    
    -- Si hay un objetivo bloqueado, úsalo; si no, busca uno nuevo
    local Target = LockedTarget or GetClosestPlayer()
    if not Target or not Target.Character then
        LockedTarget = nil -- Si el objetivo muere o desaparece, desbloquea
        return
    end
    
    local Hitpart = Target.Character:FindFirstChild(AimbotSettings.Hitpart)
    if not Hitpart then
        LockedTarget = nil -- Si la parte objetivo no existe, desbloquea
        return
    end
    
    -- Verificar si el objetivo sigue vivo
    local Humanoid = Target.Character:FindFirstChild("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then
        LockedTarget = nil -- Desbloquea si el objetivo muere
        return
    end
    
    local TargetPosition = PredictPosition(Hitpart)
    if not TargetPosition then return end
    
    -- Snap instantáneo al torso
    local NewCFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
    Camera.CFrame = NewCFrame -- Sin Lerp, puro snap blatant
end)

-- Ejecutar después de que el personaje se cargue
coroutine.wrap(function()
    WaitForCharacter()
end)()
