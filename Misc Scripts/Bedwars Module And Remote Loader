-- if ur too lazy to make ur own or urs is worse use this fr
local RuntimeLibrary = require(game:GetService("ReplicatedStorage").rbxts_include.RuntimeLib)

local Modules = debug.getupvalue(RuntimeLibrary.import, 2)

local AllowedClasses = {
    "AsyncRemoteFunction",
    "RemoteFunction",
    "RemoteEvent"
}

local Caches = {
    Modules = {}
}

for Module in (Modules) do
    Caches.Modules[Module.Name] = Module
end

local function GetModule(ModuleName: string, ExpectedParent: string?)
    local Module = Caches.Modules[ModuleName]

    if (not Module) then
        return
    end

    if (ExpectedParent) and (Module.Parent.Name ~= ExpectedParent) then
        return
    end

    return require(Module)
end

local RequiredModules = {
    Internal = assert(GetModule("internal"), "Internal module not found")
}

local ScriptUtility = {}; do
    function ScriptUtility.GetRemote(ClassName: string, RemoteName: string)
        if (not table.find(AllowedClasses, ClassName)) then
            return
        end

        local Success, Results = pcall(function()
            return RequiredModules.Internal.getRemoteOrThrow(ClassName, RemoteName)
        end)

        if (not Success) then
            return
        end

        return Results
    end
end
