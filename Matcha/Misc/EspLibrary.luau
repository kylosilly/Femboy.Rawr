EspHandler = {
    EspCache = {}
}

EspHandler.__index = EspHandler;

function EspHandler:Add(Folder: Folder)
    if (not Folder.ClassName == "Folder") then
        return notify("Error", "To add an object to esp make sure the path ends with a folder to get everything inside", 3)
    end
    if (not self.EspCache[Folder.Name]) then
        self.EspCache[Folder.Name] = Folder
    end
end

function EspHandler:Test(Text: string)
    return print(Text)
end
