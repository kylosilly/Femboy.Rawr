local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local Drops = Workspace.Drops
local Nodes = Workspace.Nodes

local NodeData = {
    ["Phosphate_Node"] = { Name = "Phosphate", Color = Color3.fromRGB(16, 88, 16) },
    ["Metal_Node"] = { Name = "Metal", Color = Color3.fromRGB(78, 74, 74) },
    ["Stone_Node"] = { Name = "Stone", Color = Color3.fromRGB(255, 255, 255) },
}

local NodeNames = {
    "Phosphate",
    "Metal",
    "Stone",
}

local Cache = {
    ["DroppedItems"] = {},
    ["Nodes"] = {}
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/zee-7654/UI/refs/heads/main/UI.lua"))()
_G.Running = true

local Window = UI:Window({
	Title = "Femboy.Rawr | Fallen Survival",
	Size = Vector2.new(700, 500),
	Flags = {},
})

local MainUtility = {}; do
    function MainUtility:Magnitude(Position1: Vector3, Position2: Vector3)
        local DistanceX = Position1.X - Position2.X
        local DistanceY = Position1.Y - Position2.Y
        local DistanceZ = Position1.Z - Position2.Z

        return math.floor(math.sqrt(DistanceX * DistanceX + DistanceY * DistanceY + DistanceZ * DistanceZ))
    end
end

local EspUtility = {}; do
    function EspUtility:AddDropped(Item: Model)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Distance.Color = Color3.new(1, 1, 1)
        Distance.Outline = true
        Distance.Center = true
        Distance.Size = 12

        Name.Color = Color3.new(1, 1, 1)
        Name.Text = Item.Name
        Name.Outline = true
        Name.Center = true
        Name.Size = 12

        Cache["DroppedItems"][Item.Address] = {
            Root = Item:FindFirstChild("Main"),
            Distance = Distance,
            Name = Name
        }
    end

    function EspUtility:AddNode(Node: Model)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        local NodeData = NodeData[Node.Name]

        local NodeColor = NodeData.Color

        Distance.Color = NodeColor
        Distance.Outline = true
        Distance.Center = true
        Distance.Size = 12

        Name.Text = NodeData.Name
        Name.Color = NodeColor
        Name.Outline = true
        Name.Center = true
        Name.Size = 12

        Cache["Nodes"][Node.Address] = {
            Root = Node:FindFirstChild("Main"),
            NodeData = NodeData,
            Distance = Distance,
            Name = Name
        }
    end

    function EspUtility:ClearEsp(Table: table)
        for _, Drawing in (Table) do
            if (type(Drawing) == "table") then
                self:ClearEsp(Drawing)
            end

            if (not Drawing.ClassName) and (Drawing.Remove) then
                Drawing:Remove()
            end
        end

        Table = nil
    end

    function EspUtility:HideDrawing(Table: table)
        for _, Drawing in (Table) do
            if (not Drawing.ClassName) and (Drawing.Remove) then
                Drawing.Visible = false
            end
        end
    end
end

task.spawn(function()
    while (_G.Running) do
        local MaxDistance = Window.Flags.MaxDistance or 1000

        for _, Item in (Drops:GetChildren()) do
            if (not Cache["DroppedItems"][Item.Address]) then
                EspUtility:AddDropped(Item)
            end
        end

        for _, Node in (Nodes:GetChildren()) do
            if (not Cache["Nodes"][Node.Address]) then
                EspUtility:AddNode(Node)
            end
        end

        for Address, Data in (Cache["Nodes"]) do
            local DistanceText = Data.Distance
            local Name = Data.Name
            local Root = Data.Root

            if (not Root) then
                EspUtility:ClearEsp(Data)
                continue
            end

            local RootPosition = Root.Position

            local ScreenPosition, OnScreen = WorldToScreen(Root.Position)

            if (not OnScreen) then
                EspUtility:HideDrawing(Data)
                continue
            end

            local Distance = MainUtility:Magnitude(RootPosition, Camera.Position)

            if (Distance > MaxDistance) then
                EspUtility:HideDrawing(Data)
                continue
            end

            if (Window.Flags.SelectedNodes) and (not table.find(Window.Flags.SelectedNodes, Data.NodeData.Name)) then
                EspUtility:HideDrawing(Data)
                continue
            end

            DistanceText.Visible = Window.Flags.NodeDistance or false
            Name.Visible = Window.Flags.NodeName or false

            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

            DistanceText.Text = `{Distance}m`
        end

        for Address, Data in (Cache["DroppedItems"]) do
            local DistanceText = Data.Distance
            local Name = Data.Name
            local Root = Data.Root

            if (not Root) then
                EspUtility:ClearEsp(Data)
                continue
            end

            local RootPosition = Root.Position

            local ScreenPosition, OnScreen = WorldToScreen(Root.Position)

            if (not OnScreen) then
                EspUtility:HideDrawing(Data)
                continue
            end

            local Distance = MainUtility:Magnitude(RootPosition, Camera.Position)

            if (Distance > MaxDistance) then
                EspUtility:HideDrawing(Data)
                continue
            end

            DistanceText.Visible = Window.Flags.DroppedDistance or false
            Name.Visible = Window.Flags.DroppedName or false

            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

            DistanceText.Text = `{Distance}m`
        end

        task.wait()
    end
end)

local Tabs = {
    Esp = Window:Tab({ Title = "Esp" }),
    Settings = Window:Tab({ Title = "Settings" })
}

local Sections = {
    EspSettings = Tabs.Esp:Section({ Title = "Esp Settings" }),
    Node = Tabs.Esp:Section({ Title = "Node" }),
    Dropped = Tabs.Esp:Section({ Title = "Dropped" }),
    Settings = Tabs.Settings:Section({ Title = "Settings" })
}

Sections.EspSettings:Slider({ Title = "Max Distance", Min = 100, Max = 1000, Default = 1000, Step = 1, Suffix = "m" }, function(Value)
    Window.Flags.MaxDistance = Value
end)

Sections.Node:MultiDropdown({ Title = "Ores To Show:", Options = NodeNames, Default = { "Phosphate", "Metal", "Stone" } }, function(Value)
    Window.Flags.SelectedNodes = Value
end)

Sections.Node:Checkbox({ Title = "Name" }, function(Value)
    Window.Flags.NodeName = Value
end)

Sections.Node:Checkbox({ Title = "Distance" }, function(Value)
    Window.Flags.NodeDistance = Value
end)

Sections.Dropped:Checkbox({ Title = "Name" }, function(Value)
    Window.Flags.DroppedName = Value
end)

Sections.Dropped:Checkbox({ Title = "Distance" }, function(Value)
    Window.Flags.DroppedDistance = Value
end)

Sections.Settings:Keybind({ Title = "Toggle Window", Key = Enum.KeyCode.Q }, function()
	Window:Toggle()
end)

Sections.Settings:Button({ Title = "Unload" }, function()
    _G.Running = false
    Window:Unload()
    for _, Caches in (Cache) do
        EspUtility:ClearEsp(Caches)
    end
end)