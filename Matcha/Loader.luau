local HttpService = game:GetService("HttpService")

loadstring(game:HttpGet("https://raw.githubusercontent.com/zee-7654/UI/refs/heads/main/UI.lua"))()

local function GetScripts()
    local Files = {}

    for _, File in (HttpService:JSONDecode(game:HttpGet("https://api.github.com/repos/kylosilly/Femboy.Rawr/contents/Matcha"))) do
        if (File.type == "file") then
            local Name = File.name
            if (not Name:find("Loader")) and (Name:find(".luau")) then
                table.insert(Files, Name)
            end
        end
    end

    return Files
end

local Window = UI:Window({
	Title = "Femboy.Rawr Loader",
	Size = Vector2.new(700, 500),
	Flags = {},
})

local LoaderTab = Window:Tab({ Title = "Loader" })
local LoaderSection = LoaderTab:Section({ Title = "Loader" })

local Success, Files = pcall(GetScripts)
if (not Success) then
    LoaderSection:Label({
        Title = "API rate limit exceeded for you, try again later!", 
    })
    return
end

local ScriptNames = {}

for _, Script in (Files) do
    table.insert(ScriptNames, (Script:gsub("%.luau", "")))
end

local SelectorDropdown = LoaderSection:Dropdown({ 
    Title = "Select Script To Load", 
    Options = ScriptNames, 
    Default = "" 
})

LoaderSection:Button({ Title = "Load Script" }, function()
    local Selected = SelectorDropdown:Get()
    if (Selected == "") then
        return print("Select a script before trying this again")
    end
    loadstring(game:HttpGet(`https://raw.githubusercontent.com/kylosilly/Femboy.Rawr/main/Matcha/{Selected}.luau`))()
    Window:Unload()
end)

LoaderSection:Button({ Title = "Unload Loader" }, function()
    Window:Unload()
end)
