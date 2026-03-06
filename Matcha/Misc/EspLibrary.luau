-- Inside EspLibrary.luau on GitHub
EspHandler = {} -- No 'local' keyword so it becomes global
EspHandler.EspCache = {}
EspHandler.__index = EspHandler

function EspHandler:Add(Folder: Folder)
    -- Use ~= to avoid the 'not' priority bug
    if typeof(Folder) ~= "Instance" or not Folder:IsA("Folder") then
         -- You can call global UI:Notify here if the UI library is loaded!
         print("Error: Path must end with a folder")
         return 
    end

    if not self.EspCache[Folder.Name] then
        -- Creating the table as requested
        self.EspCache[Folder.Name] = {
            Instance = Folder,
            Objects = {}
        }
        print("Table created for: " .. Folder.Name)
    end
end

function EspHandler:Test(Text: string)
    print("EspHandler Test: " .. Text)
end
