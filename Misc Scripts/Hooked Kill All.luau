-- made by @kylosilly if you use this in lobby you wont earn kills/coins off it
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local TEvent = require(ReplicatedStorage.Shared.Core.TEvent)

local function ClosestTargets()
    local ClosestTargets, ClosestRange = {}, 9e9

    for _, Player in (Players:GetPlayers()) do
        local PlayerTeam = Player.Team
        if (Player == LocalPlayer) or (PlayerTeam == LocalPlayer.Team) or (PlayerTeam.Name == "Lobby") then
            continue
        end

        local Character = Player.Character

        if (not Character) or (Character:FindFirstChildWhichIsA("ForceField")) then
            continue
        end

        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        local Head = Character:FindFirstChild("Head")

        if (not Head) or (not Humanoid) or (Humanoid.Health <= 0) then
            continue
        end

        local Distance = (Head.Position - LocalPlayer.Character.Head.Position).Magnitude

        if (Distance < ClosestRange) then
            table.insert(ClosestTargets, {
                ["Head"] = Head
            })
        end
    end

    for _, Bot in (Workspace:GetChildren()) do
        if (not Bot:GetAttribute("IsBot")) or (Bot:FindFirstChildWhichIsA("ForceField")) then
            continue
        end

        local Humanoid = Bot:FindFirstChildWhichIsA("Humanoid")
        local Head = Bot:FindFirstChild("Head")

        if (not Head) or (not Humanoid) or (Humanoid.Health <= 0) then
            continue
        end

        local Distance = (Head.Position - LocalPlayer.Character.Head.Position).Magnitude

        if (Distance < ClosestRange) then
            table.insert(ClosestTargets, {
                ["IsBot"] = true,
                ["Head"] = Head
            })
        end
    end

    return ClosestTargets
end

while (task.wait()) do
    local ClosestTargets = ClosestTargets()
    if (#ClosestTargets > 0) then
        for _, Target in (ClosestTargets) do
            local Player

            if (Target.IsBot) then
                Player = Target.Head.Parent
            else
                Player = Players:GetPlayerFromCharacter(Target.Head.Parent)
            end

            TEvent.FireRemote("HookFire", {
                ["hookId"] = 67,
                ["startPosition"] = nil,
                ["direction"] = (Target.Head.Position - LocalPlayer.Character.Head.Position).Unit,
                ["distance"] = 9e9,
                ["hookFlyTime"] = 0,
                ["hookBackSpeed"] = 9e9,
                ["fireTime"] = 0
            })

            TEvent.FireRemote("HookHit", { -- changing it to FireRemote bypasses all checks
                ["hookId"] = 67,
                ["targetPlayer"] = Player,
                ["targetPartName"] = Target.Head.Name,
                ["hookBackSpeed"] = 9e9
            })

            TEvent.FireRemote("HookRelease", {
                ["hookId"] = 67,
                ["targetPlayer"] = Player,
                ["reason"] = "was a faggot"
            })
        end
    end
end
