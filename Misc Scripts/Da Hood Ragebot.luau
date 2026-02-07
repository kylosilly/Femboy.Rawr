--[[
        Made by @kylosilly on discord
    Game: https://www.roblox.com/games/2788229376/Da-Hood
]]
local replicated_storage = game:GetService("ReplicatedStorage");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;

local main_event = replicated_storage.MainEvent;

local gun_handler = require(replicated_storage.Modules.GunHandler);
local main_module = require(replicated_storage.MainModule);

local vehicles = workspace.Vehicles;

table.insert(main_module.Ignored, vehicles);

local ragebot_delay, last_ran = 0, 0;

local function is_visible(part: BasePart, handle: BasePart)
    local raycast_params = RaycastParams.new();
    raycast_params.FilterType = Enum.RaycastFilterType.Exclude;
    raycast_params.IgnoreWater = true;
    raycast_params.FilterDescendantsInstances = { local_player.Character, workspace.Bush, workspace.Ignored, vehicles };
    local origin = handle.Position;
    local direction = part.Position - origin;
    local result = workspace:Raycast(origin, direction, raycast_params);

    if (not result) then
        return (false);
    end

    return (result.Instance:IsDescendantOf(part.Parent));
end

local function closest_larps(max_range: number, handle: BasePart, max_targets: number)
    local larps = {};

    for _, player in (players:GetPlayers()) do
        if (player == local_player) then
            continue;
        end
        local character = player.Character;
        if (not character) or (character:FindFirstChild("BodyEffects") and character.BodyEffects["K.O"].Value) or (character:FindFirstChildOfClass("ForceField")) then
            continue;
        end
        local head = character:FindFirstChild("Head");
        if (not head) then
            continue;
        end
        if (head.Position - handle.Position).Magnitude > max_range then
            continue;
        end
        if (not is_visible(head, handle)) then
            continue;
        end
        table.insert(larps, head);
        if (#larps == max_targets) then
            break;
        end
    end

    return (larps);
end

run_service.RenderStepped:Connect(function()
    local tool = local_player.Character:FindFirstChildWhichIsA("Tool");
    local now = tick();

    if (tool) and (tool:FindFirstChild("Handle")) and (now - last_ran > ragebot_delay) then
        local shooting_cooldown = tool:FindFirstChild("ShootingCooldown");
        local range = tool:FindFirstChild("Range");
        local ammo = tool:FindFirstChild("Ammo");
        if (ammo) and (range) and (shooting_cooldown) then
            if (ammo.Value == 0) and (tonumber(local_player.DataFolder.Inventory[tool.Name].Value) > 0) then
                main_event:FireServer("Reload", tool);
            end
            if (ammo.Value > 0) and (not local_player.Character.BodyEffects["K.O"].Value) and (not local_player.Character.BodyEffects["Reload"].Value) then
                local larps = closest_larps(range.Value, tool.Handle, 2);
                if (#larps > 0) then
                    for _, head in (larps) do
                        setthreadidentity(2);
                        local position, part, lookvector = gun_handler.shoot({
                            ["Shooter"] = game:GetService("Players").LocalPlayer.Character;
                            ["Handle"] = tool.Handle;
                            ["ForcedOrigin"] = tool.Handle.Position;
                            ["AimPosition"] = head.Position;
                            ["BeamColor"] = Color3.new(1, 1, 1);
                            ["Range"] =  tool.Range.Value
                        })
                        setthreadidentity(8);
                        main_event:FireServer("ShootGun", tool.Handle, tool.Handle.Position, position, part, lookvector);
                        ragebot_delay = shooting_cooldown.Value / 3;
                        last_ran = now;
                    end
                end
            end
        end
    end
end)
--loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))();
