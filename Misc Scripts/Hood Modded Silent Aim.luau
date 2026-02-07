local replicated_storage = game:GetService("ReplicatedStorage");
local user_input_service = game:GetService("UserInputService");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;

local gun_client = require(replicated_storage.Modules.Gun.GunClient);

local silent_aim_fov_outline = Drawing.new("Circle");
local silent_aim_fov = Drawing.new("Circle");

silent_aim_fov_outline.Color = Color3.new(0, 0, 0);
silent_aim_fov_outline.Visible = true;
silent_aim_fov_outline.Thickness = 3;
silent_aim_fov_outline.Radius = 100;

silent_aim_fov.Color = Color3.new(1, 1, 1);
silent_aim_fov.Visible = true;
silent_aim_fov.Thickness = 1;
silent_aim_fov.Radius = 100;

local function is_visible(part: BasePart)
    local raycast_params = RaycastParams.new();
    raycast_params.FilterType = Enum.RaycastFilterType.Exclude;
    raycast_params.IgnoreWater = true;
    raycast_params.FilterDescendantsInstances = { local_player.Character };
    local origin = camera.CFrame.Position;
    local direction = part.Position - origin;
    local result = workspace:Raycast(origin, direction, raycast_params);

    if (not result) then
        return false;
    end

    return (result.Instance:IsDescendantOf(part.Parent));
end

local function closest_target(range: number)
    local closest_part, closest_distance = nil, range;

    local mouse = user_input_service:GetMouseLocation();

    for _, player in (players:GetPlayers()) do
        if (player == local_player) then
            continue;
        end
        local character = player.Character;
        if (not character) or (character:FindFirstChild("BodyEffects") and character.BodyEffects["K.O"].Value) or (character:FindFirstChildOfClass("ForceField")) then
            continue;
        end
        local best_part, best_distance = nil, range;
        for _, limb in (character:GetChildren()) do
            if (limb:IsA("MeshPart")) then
                local screen_position, on_screen = camera:WorldToViewportPoint(limb.Position);
                if (not on_screen) then
                    continue;
                end
                if (not is_visible(limb)) then
                    continue;
                end
                local distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude;
                if (distance < best_distance) then
                    best_distance = distance;
                    best_part = limb;
                end
            end
        end
        if (not best_part) then
            continue;
        end
        if (best_part.Position - camera.CFrame.Position).Magnitude > range then
            continue;
        end
        if (best_distance < closest_distance) then
            closest_part = best_part;
            closest_distance = best_distance;
        end
    end

    return closest_part;
end

run_service.RenderStepped:Connect(function()
    local mouse = user_input_service:GetMouseLocation();
    silent_aim_fov_outline.Position = Vector2.new(mouse.X, mouse.Y);
    silent_aim_fov.Position = Vector2.new(mouse.X, mouse.Y);
end)

local old; old = hookfunction(gun_client.Shoot, function(self, sigma, data)
    if (data.Shooter == local_player.Character) then
        local closest = closest_target(silent_aim_fov.Radius);
        if (closest) then
            data.AimPosition = closest.Position;
        end
    end
    return old(self, sigma, data);
end)
