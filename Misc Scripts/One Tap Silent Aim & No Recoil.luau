local replicated_storage = game:GetService("ReplicatedStorage");
local user_input_service = game:GetService("UserInputService");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;

local shove = filtergc("function", {
    Name = "shove"
}, true)

local weapon_manager = require(replicated_storage.Common.Managers.WeaponManager);

weapon_manager.Constants.DEFAULT_PISTOL_RELOAD_TIME = 0;
weapon_manager.Constants.DEFAULT_PISTOL_FIRERATE = 500;
weapon_manager.Constants.DEFAULT_RELOAD_TIME = 0;
weapon_manager.Constants.DEFAULT_MAGAZINE = 9e9;

local silent_fov, current_target = 500, nil;

local silent_aim_fov_outline = Drawing.new("Circle");
local silent_aim_fov = Drawing.new("Circle");
local snapline_outline = Drawing.new("Line");
local snapline = Drawing.new("Line");

do
    silent_aim_fov_outline.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov_outline.Color = Color3.new(0, 0, 0)
    silent_aim_fov_outline.Visible = true;
    silent_aim_fov_outline.Thickness = 3;
    silent_aim_fov_outline.Radius = silent_fov;
end

do
    silent_aim_fov.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov.Color = Color3.new(1, 1, 1)
    silent_aim_fov.Visible = true;
    silent_aim_fov.Thickness = 1;
    silent_aim_fov.Radius = silent_fov;
end

do
    snapline_outline.Color = Color3.new(0, 0, 0);
    snapline_outline.Thickness = 3;
end

do
    snapline.Color = Color3.new(1, 1, 1);
    snapline.Thickness = 1;
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    silent_aim_fov_outline.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov.Position = silent_aim_fov_outline.Position;
end)

local function closest_player(radius: number)
    local closest_head, max_distance = nil, radius;

    local mouse = user_input_service:GetMouseLocation();

    for _, model in (workspace:GetChildren()) do
        if (model == local_player.Character) or (not model:GetAttribute("deployed")) or (model:FindFirstChild("ForceField")) then
            continue;
        end
        local humanoid = model:FindFirstChildWhichIsA("Humanoid");
        local head = model:FindFirstChild("Head");
        if (not head) or (not humanoid) or (humanoid.Health <= 0) then
            continue;
        end
        local screen_position, visible = camera:WorldToViewportPoint(head.Position);
        if (not visible) then
            continue;
        end
        local distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude;
        if (distance < max_distance) then
            max_distance = distance;
            closest_head = head;
        end
    end

    return closest_head;
end

run_service.RenderStepped:Connect(function()
    current_target = closest_player(silent_fov);
    if (current_target) then
        local screen_position = camera:WorldToViewportPoint(current_target.Position);
        snapline_outline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
        snapline_outline.To = Vector2.new(screen_position.X, screen_position.Y);
        snapline.From = snapline_outline.From;
        snapline.To = snapline_outline.To;
        snapline_outline.Visible = true;
        snapline.Visible = true;
    else
        snapline_outline.Visible = false;
        snapline.Visible = false;
    end
end)

local old_cast; old_cast = hookfunction(weapon_manager.cast, function(origin, direction, bullet_speed, max_distance, ignore_list, ...)
    if (current_target) then
        bullet_speed = 9e9;
        max_distance = 9e999;
        direction = (current_target.Position - origin).Unit;
    end
    return old_cast(origin, direction, bullet_speed, max_distance, ignore_list, ...);
end)

hookfunction(shove, function()
    return;
end)
