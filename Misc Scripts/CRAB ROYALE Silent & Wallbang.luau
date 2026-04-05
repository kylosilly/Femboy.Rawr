local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Modules = ReplicatedStorage.Modules

local BulletConstructor = require(Modules.BulletConstructor)
local MyCameraModule = require(Modules.MyCameraModule)

local Map = Workspace:FindFirstChild("Map")

local FovSize, Target = 1000, nil

local SnaplineOutline = Drawing.new("Line")
local FovOutline = Drawing.new("Circle")
local Snapline = Drawing.new("Line")
local Fov = Drawing.new("Circle")

FovOutline.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FovOutline.Color = Color3.new(0, 0, 0)
FovOutline.Radius = FovSize
FovOutline.Visible = true
FovOutline.Thickness = 3

Fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
Fov.Color = Color3.new(1, 1, 1)
Fov.Radius = FovSize
Fov.Visible = true
Fov.Thickness = 1

SnaplineOutline.Color = Color3.new(0, 0, 0)
SnaplineOutline.Thickness = 3

Snapline.Color = Color3.new(1, 1, 1)
Snapline.Thickness = 1

if (Map) then
    Map.Parent = Workspace.Bulletholes
end

local function Closest(Range: number)
    local ClosestPart, ClosestRange = nil, Range

    for _, Player in (Players:GetPlayers()) do
        local PlayerTeam = Player.Team

        if (Player == LocalPlayer) or (PlayerTeam.Name ~= "NO TEAM" and PlayerTeam == LocalPlayer.Team) or (Player:GetAttribute("Forcefield")) or (not Player:GetAttribute("IsInMatch")) or (Player:GetAttribute("IsDead")) then
            continue
        end

        local Character = Player.Character

        if (not Character) then
            continue
        end

        local Head = Character:FindFirstChild("Head")

        if (not Head) then
            continue
        end

        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Head.Position)

        if (not OnScreen) then
            continue
        end

        local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Camera.ViewportSize / 2).Magnitude

        if (Distance < ClosestRange) then
            ClosestPart = Head
            ClosestRange = Distance
        end
    end

    return ClosestPart
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FovOutline.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Fov.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

RunService.RenderStepped:Connect(function()
    Target = Closest(FovSize)

    if (Target) then
        local ScreenPosition = Camera:WorldToViewportPoint(Target.Position)

        SnaplineOutline.Visible = true
        Snapline.Visible = true

        SnaplineOutline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        SnaplineOutline.To = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

        Snapline.From = SnaplineOutline.From
        Snapline.To = SnaplineOutline.To
    else
        SnaplineOutline.Visible = false
        Snapline.Visible = false
    end
end)


local _New; _New = hookfunction(BulletConstructor.new, function(Data)
    if (Target) and (Data.Player == LocalPlayer) then
        Data.Direction = (Target.Position - Data.OriginCFrame.Position).Unit
        Data.ProjectileSpeed = 9e9
    end

    return _New(Data)
end)

hookfunction(MyCameraModule.Recoil, function()
    return
end)

hookfunction(MyCameraModule.ScreenFlash, function()
    return
end)

hookfunction(MyCameraModule.CameraShakeOnLand, function()
    return
end)

hookfunction(MyCameraModule.CameraJerk, function()
    return
end)

hookfunction(MyCameraModule.CameraShake, function()
    return
end)
