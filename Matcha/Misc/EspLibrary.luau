local Camera = game:GetService("Workspace").CurrentCamera

EspHandler = {}
EspHandler.EspCache = {}
EspHandler.__index = EspHandler

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

function EspHandler:Add(CreationData: table)
    local Path = CreationData.Path
    if (not Path) or (Path.ClassName ~= "Folder" and Path.ClassName ~= "Workspace") then
        return warn("To add something make sure the path ends with an folder or workspace")
    end

    local Color = CreationData.Color or Color3.new(1, 1, 1)

    if (not self.EspCache[Path.Name]) then
        self.EspCache[Path.Name] = {}
    end

    for _, Instance in (Path:GetChildren()) do
        local InstanceAddress = Instance.Address
        if (self.EspCache[Path.Name][InstanceAddress]) then
            continue
        end
        local Distance = Drawing.new("Text")
        local Name = Drawing.new("Text")

        do
            Distance.Outline = true
            Distance.Center = true
            Distance.Color = Color
            Distance.Size = 12
        end

        do
            Name.Text = CreationData.CustomName or Instance.Name
            Name.Outline = true
            Name.Center = true
            Name.Color = Color
            Name.Size = 12
        end

        self.EspCache[Path.Name][InstanceAddress] = {
            Distance = Distance,
            Parent = Instance,
            Name = Name
        }
    end
end

function EspHandler:Update()
    for _, EspTable in (self.EspCache) do
        for _, Drawing in (EspTable) do
            local Root

            if (Drawing.Parent.ClassName == "Model") then
                Root = Drawing.Parent.PrimaryPart
            else
                Root = Drawing.Parent
            end

            if (not Root) then
                continue
            end

            local ScreenPosition, OnScreen = WorldToScreen(Root.Position)
            local DistanceText = Drawing.Distance
            local NameText = Drawing.Name

            if (not OnScreen) then
                DistanceText.Visible = false
                NameText.Visible = false
                continue
            end

            DistanceText.Text = `{HandlerUtility:Magnitude(Root.Position, Camera.Position)}m`
            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            NameText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            DistanceText.Visible = true
            NameText.Visible = true
        end
    end
end

while (true) do
    EspHandler:Update()
    task.wait()
end
