--[[
        Made by @kylosilly on discord
    Game: https://www.roblox.com/games/901793731/D-DAY
]]
local replicated_storage = game:GetService("ReplicatedStorage");
local user_input_service = game:GetService("UserInputService");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;

local framework = require(replicated_storage.Modules.Universal.Framework);
local framework_modules = framework.modules;

if (not IB_OBFUSCATED) then
	getfenv().IB_NO_VIRTUALIZE = function(...)
		return (...);
	end
end

local IB_NO_UPVALUES = function(fn)
	local identifier = `_{tostring(fn):gsub("function: ", "")}`;

	return loadstring(`local b=...local c=function(...)return {identifier}(...)end;getfenv(c).{identifier}=b;return c`)(fn);
end

local hooked_functions = {}
local hookfunction = function(target, hook)
	local original = getgenv().hookfunction(target, IB_NO_UPVALUES(hook))
	hooked_functions[target] = original
	return original
end

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

local function is_visible(limb: BasePart)
    local raycast = RaycastParams.new();
    raycast.FilterType = Enum.RaycastFilterType.Exclude;
	raycast.IgnoreWater = true;
	raycast.FilterDescendantsInstances = { local_player.Character, camera };
	local origin = camera.CFrame.Position;
	local direction = limb.Position - origin;
	local result = workspace:Raycast(origin, direction, raycast);

    if (not result) then
        return;
    end

    return (result.Instance:IsDescendantOf(limb.Parent));
end

local function closest(radius: number)
    local closest_head, max_distance = nil, radius;

    local mouse = user_input_service:GetMouseLocation();

    for _, player in (players:GetChildren()) do
        if (player == local_player) or (player.Team == local_player.Team) then
            continue;
        end
        local character = player.Character;
        if (not character) or (character:FindFirstChildWhichIsA("ForceField")) then
            continue;
        end
        local humanoid = character:FindFirstChildWhichIsA("Humanoid");
        local head = character:FindFirstChild("Head");
        if (not head) or (not humanoid) or (humanoid.Health <= 0) then
            continue;
        end
        local screen_position, visible = camera:WorldToViewportPoint(head.Position);
        if (not visible) then
            continue;
        end
        if (not is_visible(head)) then
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

run_service.RenderStepped:Connect(IB_NO_VIRTUALIZE(function()
    current_target = closest(silent_fov);
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
end))

local old; old = hookfunction(framework_modules.Client_Bullet, function(player, held_gun, end_position, spread, ...)
    if (current_target) then
        end_position = current_target.Position;
        spread = spread:Lerp(CFrame.identity, 1); -- if this gets flagged just remove it or try to improve it
    end
    return old(player, held_gun, end_position, spread, ...);
end)

hookfunction(framework_modules.Shake_Camera, function()
    return;
end)
