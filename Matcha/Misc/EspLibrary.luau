local Camera = game:GetService("Workspace").CurrentCamera

EspUtility = {}
EspUtility.EspCache = {}
EspUtility.__index = EspUtility

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

function EspUtility:Add(CreationData: table)
    local Path = CreationData.Path
    if (not Path) or (Path.ClassName ~= "Folder" and Path.ClassName ~= "Workspace") then
        return warn("To add something make sure the path ends with an folder or workspace")
    end

    local Color = CreationData.Color or Color3.new(1, 1, 1)
    local CustomName = CreationData.CustomName

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
            Name.Text = CustomName or Instance.Name
            Name.Outline = true
            Name.Center = true
            Name.Color = Color
            Name.Size = 12
        end

        self.EspCache[Path.Name][InstanceAddress] = {
            CustomColor = Color or Color3.new(1, 1, 1),
            CustomName = CustomName,
            Distance = Distance,
            Parent = Instance,
            Name = Name
        }
    end
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

function EspUtility:Update()
    for _, EspTable in (self.EspCache) do
        for _, Instance in (EspTable.Parent:GetChildren()) do
            if (not EspTable[Parent.Address]) then
                local Color = EspTable.CustomColor or Color3.new(1, 1, 1)
                local Distance = Drawing.new("Text")
                local Name = Drawing.new("Text")

                do
                    Distance.Outline = true
                    Distance.Center = true
                    Distance.Color = Color
                    Distance.Size = 12
                end

                do
                    Name.Text = EspTable.CustomName or Instance.Name
                    Name.Outline = true
                    Name.Center = true
                    Name.Color = Color
                    Name.Size = 12
                end

                EspTable[Instance.Address] = {
                    CustomColor = Color or Color3.new(1, 1, 1),
                    CustomName = CustomName,
                    Distance = Distance,
                    Parent = Instance,
                    Name = Name
                }
            end
        end
    end
    
    for _, EspTable in (self.EspCache) do
        for Address, Drawing in (EspTable) do
            if (not Drawing.Parent) then
                EspUtility:ClearEsp(Drawing)
                EspTable[Address] = nil
                continue
            end

            local Root

            if (Drawing.Parent.ClassName == "Model") then
                Root = Drawing.Parent.PrimaryPart
            elseif (Drawing.Parent.ClassName ~= "Camera") then
                Root = Drawing.Parent
            end

            if (not Root) or (not Root.Position) then
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

            DistanceText.Text = `{HandlerUtility:Magnitude(Camera.Position, Root.Position)}m`
            DistanceText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + 12)
            NameText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            DistanceText.Visible = true
            NameText.Visible = true
        end
    end
end

while (true) do
    EspUtility:Update()
    task.wait()
end
