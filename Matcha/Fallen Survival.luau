if (game.GameId ~= 3747388906) or (game.PlaceId ~= 13800717766) then
    return notify("The script can only be used on official Fallen Survival servers.", "Femboy.Rawr", 10)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/kylosilly/Femboy.Rawr/refs/heads/main/Matcha/Extra/debug.profile.luau"))()

debug.profilebegin("ScriptLoad")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Vegetation = Workspace.Vegetation
local Plants = Workspace.Plants
local Loners = Workspace.Loners
local Drops = Workspace.Drops
local Nodes = Workspace.Nodes
local Bases = Workspace.Bases

local Benches = ReplicatedStorage.Benches -- stuff that can be inside bases
local Values = ReplicatedStorage.Values

local Cache = {
    ["Plants"] = {},
    ["Drops"] = {},
    ["Nodes"] = {}
}

local PlantNames = {
    ["Raspberry Plant"] = {
        ["Name"] = "Raspberry",
        ["Color"] = Color3.fromRGB(227, 11, 93)
    },
    ["Blueberry Plant"] = {
        ["Name"] = "Blueberry",
        ["Color"] = Color3.fromRGB(0, 0, 255)
    },
    ["Pumpkin Plant"] = {
        ["Name"] = "Pumpkin",
        ["Color"] = Color3.fromRGB(255, 127, 0)
    },
    ["Tomato Plant"] = {
        ["Name"] = "Tomato",
        ["Color"] = Color3.fromRGB(255, 0, 0)
    },
    ["Lemon Plant"] = {
        ["Name"] = "Lemon",
        ["Color"] = Color3.fromRGB(255, 255, 0)
    },
    ["Corn Plant"] = {
        ["Name"] = "Corn",
        ["Color"] = Color3.fromRGB(251, 236, 93)
    },
    ["Wool Plant"] = {
        ["Name"] = "Wool",
        ["Color"] = Color3.fromRGB(255, 255, 255)
    }
}

local NodeNames = {
    ["Phosphate_Node"] = {
        ["Name"] = "Phosphate Node",
        ["Color"] = Color3.fromRGB(16, 88, 16)
    },
    ["Metal_Node"] = {
        ["Name"] = "Metal Node",
        ["Color"] = Color3.fromRGB(78, 74, 74)
    },
    ["Stone_Node"] = {
        ["Name"] = "Stone Node",
        ["Color"] = Color3.fromRGB(255, 255, 255)
    }
}

local MainUtility = {}; do
    function MainUtility.Magnitude(Position1: Vector3, Position2: Vector3)
        if (not Position1) or (not Position2) then
            return 0
        end

        local DistanceX = Position1.X - Position2.X
        local DistanceY = Position1.Y - Position2.Y
        local DistanceZ = Position1.Z - Position2.Z

        return math.floor(math.sqrt(DistanceX * DistanceX + DistanceY * DistanceY + DistanceZ * DistanceZ))
    end
end

local EspUtility = {}; do
    function EspUtility.Clear(Table: table)
        if (Table.Connections) then
            for _, Connections in (Table.Connections) do
                Connections:Disconnect()
            end
        end

        for _, Data in (Table) do
            if (type(Data) == "table") and (Data ~= Table.Connections) then
                EspUtility.Clear(Data)
            elseif (not Data.ClassName) and (Data.Remove) then
                Data:Remove()
            end
        end

        Table = nil
    end

    function EspUtility.Hide(Table: table)
        for _, Data in (Table) do
            if (type(Data) == "table") and (Data ~= Table.Connections) then
                EspUtility.Hide(Data)
            elseif (not Data.ClassName) and (Data.Remove) then
                Data.Visible = false
            end
        end
    end

    function EspUtility.Plant(Plant: Model)
        local Data = PlantNames[Plant.Name]

        if (not Data) then
            return
        end

        local Color = Data.Color

        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Distance.Outline = true
        Distance.Center = true
        Distance.Color = Color
        Name.Text = Data.Name
        Name.Outline = true
        Name.Color = Color
        Name.Center = true
        Distance.Size = 16
        Name.Size = 16

        Cache["Plants"][Plant.Address] = {
            Distance = Distance,
            Name = Name,
            Connections = {
                RenderStepped = RunService.RenderStepped:Connect(function()
                    local Root = Plant:FindFirstChild("Main")

                    if (not Root) then
                        EspUtility.Clear(Cache["Plants"][Plant.Address])
                        return
                    end

                    local ScreenPosition, OnScreen = WorldToScreen(Root.Position)

                    if (not OnScreen) then
                        EspUtility.Hide(Cache["Plants"][Plant.Address])
                        return
                    end

                    if (not UI.GetValue(PlantNames[Plant.Name].Name)) then
                        EspUtility.Hide(Cache["Plants"][Plant.Address])
                        return
                    end

                    local Magnitude = MainUtility.Magnitude(Root.Position, Camera.Position)

                    if (Magnitude > UI.GetValue("PlantMaxDistance")) then
                        EspUtility.Hide(Cache["Plants"][Plant.Address])
                        return
                    end

                    Distance.Visible = UI.GetValue("PlantDistance")
                    Name.Visible = UI.GetValue("PlantName")

                    Distance.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
                    Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

                    Distance.Text = `{Magnitude}m`
                end)
            }
        }
    end

    function EspUtility.Node(Node: Model)
        local Data = NodeNames[Node.Name]

        if (not Data) then
            return
        end

        local Color = Data.Color

        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Distance.Outline = true
        Distance.Center = true
        Distance.Color = Color
        Name.Text = Data.Name
        Name.Outline = true
        Name.Color = Color
        Name.Center = true
        Distance.Size = 16
        Name.Size = 16

        Cache["Nodes"][Node.Address] = {
            Distance = Distance,
            Name = Name,
            Connections = {
                RenderStepped = RunService.RenderStepped:Connect(function()
                    local Root = Node:FindFirstChild("Main")

                    if (not Root) then
                        EspUtility.Clear(Cache["Nodes"][Node.Address])
                        return
                    end

                    local ScreenPosition, OnScreen = WorldToScreen(Root.Position)

                    if (not OnScreen) then
                        EspUtility.Hide(Cache["Nodes"][Node.Address])
                        return
                    end

                    if (not UI.GetValue(NodeNames[Node.Name].Name)) then
                        EspUtility.Hide(Cache["Nodes"][Node.Address])
                        return
                    end

                    local Magnitude = MainUtility.Magnitude(Root.Position, Camera.Position)

                    if (Magnitude > UI.GetValue("NodeMaxDistance")) then
                        EspUtility.Hide(Cache["Nodes"][Node.Address])
                        return
                    end

                    Distance.Visible = UI.GetValue("NodeDistance")
                    Name.Visible = UI.GetValue("NodeName")

                    Distance.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
                    Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

                    Distance.Text = `{Magnitude}m`
                end)
            }
        }
    end

    function EspUtility.Drops(Dropped: Model)
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        Name.Text = Dropped.Name
        Distance.Outline = true
        Distance.Center = true
        Name.Outline = true
        Name.Center = true
        Distance.Size = 16
        Name.Size = 16

        Cache["Drops"][Dropped.Address] = {
            Distance = Distance,
            Name = Name,
            Connections = {
                RenderStepped = RunService.RenderStepped:Connect(function()
                    local Root = Dropped:FindFirstChild("Main") or Dropped:FindFirstChild("Handle") or nil

                    if (not Root) then
                        EspUtility.Clear(Cache["Drops"][Dropped.Address])
                        return
                    end

                    local ScreenPosition, OnScreen = WorldToScreen(Root.Position)

                    if (not OnScreen) then
                        EspUtility.Hide(Cache["Drops"][Dropped.Address])
                        return
                    end

                    local Magnitude = MainUtility.Magnitude(Root.Position, Camera.Position)

                    if (Magnitude > UI.GetValue("DropMaxDistance")) then
                        EspUtility.Hide(Cache["Drops"][Dropped.Address])
                        return
                    end

                    Distance.Visible = UI.GetValue("DropDistance")
                    Name.Visible = UI.GetValue("DropName")

                    Distance.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
                    Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

                    Distance.Text = `{Magnitude}m`
                end)
            }
        }
    end

    function EspUtility.Init()
        RunService.RenderStepped:Connect(function()
            for _, Plant in (Plants:GetChildren()) do
                if (not Cache["Plants"][Plant.Address]) then
                    EspUtility.Plant(Plant)
                end
            end

            for _, Node in (Nodes:GetChildren()) do
                if (not Cache["Nodes"][Node.Address]) then
                    EspUtility.Node(Node)
                end
            end

            for _, Dropped in (Drops:GetChildren()) do
                if (not Cache["Drops"][Dropped.Address]) then
                    EspUtility.Drops(Dropped)
                end
            end
        end)
    end
end

UI.AddTab("Fallen Survival [Femboy.Rawr]", function(Tab)
    local PlantEsp = Tab:Section("Plant Esp", "Left", {"Main", "Settings"})

    if (PlantEsp.page == 0) then
        PlantEsp:Toggle("PlantDistance", "Distance")
        PlantEsp:Toggle("PlantName", "Name")
    elseif (PlantEsp.page == 1) then
        PlantEsp:SliderFloat("PlantMaxDistance", "Max Render Distance", 50, 1200, 1200, "%.2f")
        PlantEsp:Spacing()
        for _, Data in (PlantNames) do
            local Name = Data.Name

            PlantEsp:Toggle(Name, `Show {Name}`)
        end
    end

    local NodeEsp = Tab:Section("Node Esp", "Left", {"Main", "Settings"})

    if (NodeEsp.page == 0) then
        NodeEsp:Toggle("NodeDistance", "Distance")
        NodeEsp:Toggle("NodeName", "Name")
    elseif (NodeEsp.page == 1) then
        NodeEsp:SliderFloat("NodeMaxDistance", "Max Render Distance", 50, 1200, 1200, "%.2f")
        NodeEsp:Spacing()
        for _, Data in (NodeNames) do
            local Name = Data.Name

            NodeEsp:Toggle(Name, `Show {Name}`)
        end
    end

    local DroppedEsp = Tab:Section("Dropped Esp", "Right", {"Main", "Settings"})

    if (DroppedEsp.page == 0) then
        DroppedEsp:Toggle("DropDistance", "Distance")
        DroppedEsp:Toggle("DropName", "Name")
    elseif (DroppedEsp.page == 1) then
        DroppedEsp:SliderFloat("DropMaxDistance", "Max Render Distance", 50, 1200, 1200, "%.2f")
    end

    local Server = Tab:Section("Server Info", "Right")

    Server:Text(`Server Name: {Values.ServerName.Value}`)
    Server:Text(`Server Build: {Values.ServerBuild.Value}`)
	Server:Text(`Wipe Version: {Values.WipeVersion.Value}`)
    Server:Text(`Team Limit: {Values.TeamSize.Value}`)
end)

EspUtility.Init()
debug.profileend("ScriptLoad")