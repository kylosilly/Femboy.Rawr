loadstring(game:HttpGet("https://raw.githubusercontent.com/zee-7654/UI/refs/heads/main/UI.lua"))()
_G.Running = true

local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local Hatches = Workspace:WaitForChild("Hatches"):WaitForChild("Zone1")
local SpawnedCrates = Workspace:WaitForChild("SpawnedCrates")
local SpawnedItems = Workspace:WaitForChild("SpawnedItems")

local EspCache = {
    ["SpawnedCrates"] = {},
    ["SpawnedItems"] = {},
    ["Hatches"] = {}
}

local Window = UI:Window({
	Title = "Femboy.Rawr | The Armory",
	Size = Vector2.new(700, 500),
	Flags = {}
})

local EspUtility = {}; do
    function EspUtility:AddCrate(Crate: Model)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Distance.Outline = true
        Distance.Center = true
        Distance.Size = 12
        Name.Outline = true
        Name.Text = "Crate"
        Name.Center = true
        Name.Size = 12

        EspCache["SpawnedCrates"][Crate.Address] = {
            Root = Crate:FindFirstChild("Root"),
            Distance = Distance,
            Name = Name
        }
    end

    function EspUtility:AddSpawned(Dropped: Part)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Name.Text = Dropped:FindFirstChildOfClass("Model").Name
        Distance.Outline = true
        Distance.Center = true
        Distance.Size = 12
        Name.Outline = true
        Name.Center = true
        Name.Size = 12

        EspCache["SpawnedItems"][Dropped.Address] = {
            Distance = Distance,
            Root = Dropped,
            Name = Name
        }
    end

    function EspUtility:AddHatch(Hatch: Model)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Distance.Outline = true
        Distance.Center = true
        Distance.Size = 12
        Name.Outline = true
        Name.Text = "Hatch"
        Name.Center = true
        Name.Size = 12

        EspCache["Hatches"][Hatch.Address] = {
            Root = Hatch:FindFirstChild("Root"),
            Distance = Distance,
            Name = Name
        }
    end

    function EspUtility:ClearEsp(EspTable: table)
        for _, Drawing in (EspTable) do
            if (type(Drawing) == "table") then
                self:ClearEsp(Drawing)
            end
            if (not Drawing.ClassName) and (Drawing.Remove) then
                Drawing:Remove()
            end
        end
    end
end

local HandlerUtility = {}; do
    function HandlerUtility:Magnitude(Position1: Vector3, Position2: Vector3)
        if (not Position1) or (not Position2) then
            return 0
        end
        local DistanceX = Position1.X - Position2.X
        local DistanceY = Position1.Y - Position2.Y
        local DistanceZ = Position1.Z - Position2.Z
        return math.floor(math.sqrt(DistanceX * DistanceX + DistanceY * DistanceY + DistanceZ * DistanceZ))
    end
end

for _, Hatch in (Hatches:GetChildren()) do
    EspUtility:AddHatch(Hatch)
end

task.spawn(function()
    while (_G.Running) do
        for _, SpawnedCrate in (SpawnedCrates:GetChildren()) do
            if (not EspCache["SpawnedCrates"][SpawnedCrate.Address]) then
                EspUtility:AddCrate(SpawnedCrate)
            end
        end

        for _, SpawnedItems in (SpawnedItems:GetChildren()) do
            if (not EspCache["SpawnedItems"][SpawnedItems.Address]) then
                EspUtility:AddSpawned(SpawnedItems)
            end
        end

        for Adress, CrateData in (EspCache["SpawnedCrates"]) do
            if (not CrateData.Root) or (not CrateData.Root.Parent) then
                EspCache["SpawnedCrates"][Adress] = nil
                EspUtility:ClearEsp(CrateData)
                continue
            end

            local ScreenPosition, OnScreen = WorldToScreen(CrateData.Root.Position)
            local DistanceText = CrateData.Distance
            local NameText = CrateData.Name

            if (not OnScreen) then
                DistanceText.Visible = false
                NameText.Visible = false
                continue
            end

            DistanceText.Text = `{HandlerUtility:Magnitude(CrateData.Root.Position, Camera.Position)}m`
            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            NameText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            DistanceText.Visible = (Window.Flags.CrateDistance and OnScreen)
            NameText.Visible = (Window.Flags.CrateName and OnScreen)
        end

        for Adress, SpawnedData in (EspCache["SpawnedItems"]) do
            if (not SpawnedData.Root) or (not SpawnedData.Root.Parent) then
                EspCache["SpawnedItems"][Adress] = nil
                EspUtility:ClearEsp(SpawnedData)
                continue
            end

            local ScreenPosition, OnScreen = WorldToScreen(SpawnedData.Root.Position)
            local DistanceText = SpawnedData.Distance
            local NameText = SpawnedData.Name

            if (not OnScreen) then
                DistanceText.Visible = false
                NameText.Visible = false
                continue
            end

            DistanceText.Text = `{HandlerUtility:Magnitude(SpawnedData.Root.Position, Camera.Position)}m`
            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            NameText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            DistanceText.Visible = (Window.Flags.SpawnedDistance and OnScreen)
            NameText.Visible = (Window.Flags.SpawnedName and OnScreen)
        end

        for Adress, HatchData in (EspCache["Hatches"]) do
            if (not HatchData.Root) or (not HatchData.Root.Parent) then
                EspCache["Hatches"][Adress] = nil
                EspUtility:ClearEsp(HatchData)
                continue
            end

            local ScreenPosition, OnScreen = WorldToScreen(HatchData.Root.Position)
            local DistanceText = HatchData.Distance
            local NameText = HatchData.Name

            if (not OnScreen) then
                DistanceText.Visible = false
                NameText.Visible = false
                continue
            end

            DistanceText.Text = `{HandlerUtility:Magnitude(HatchData.Root.Position, Camera.Position)}m`
            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            NameText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            DistanceText.Visible = (Window.Flags.HatchDistance and OnScreen)
            NameText.Visible = (Window.Flags.HatchName and OnScreen)
        end
        task.wait()
    end
end)

local Tabs = {
    Esp = Window:Tab({ Title = "Esp" }),
    Settings = Window:Tab({ Title = "Settings" })
}

local Sections = {
    SpawnedEsp = Tabs.Esp:Section({ Title = "Spawned Items Esp" }),
    CrateEsp = Tabs.Esp:Section({ Title = "Crate Esp" }),
    HatchEsp = Tabs.Esp:Section({ Title = "Hatch Esp" }),
    Settings = Tabs.Settings:Section({ Title = "Settings" })
}

Sections.CrateEsp:Checkbox({ Title = "Name" }, function(Value)
    Window.Flags.CrateName = Value
end)

Sections.CrateEsp:Checkbox({ Title = "Distance" }, function(Value)
    Window.Flags.CrateDistance = Value
end)

Sections.SpawnedEsp:Checkbox({ Title = "Name" }, function(Value)
	Window.Flags.SpawnedName = Value
end)

Sections.SpawnedEsp:Checkbox({ Title = "Distance" }, function(Value)
    Window.Flags.SpawnedDistance = Value
end)

Sections.HatchEsp:Checkbox({ Title = "Name" }, function(Value)
	Window.Flags.HatchName = Value
end)

Sections.HatchEsp:Checkbox({ Title = "Distance" }, function(Value)
    Window.Flags.HatchDistance = Value
end)

Sections.Settings:Keybind({ Title = "Toggle Window", Key = Enum.KeyCode.Q }, function()
	Window:Toggle()
end)

Sections.Settings:Button({ Title = "Unload" }, function()
    _G.Running = false
    Window:Unload()
    for _, Caches in (EspCache) do
        EspUtility:ClearEsp(Caches)
    end
end)
