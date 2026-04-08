--[[
    Example ussage:
    debug.profilebegin("Test")
    debug.profileend("Test")
]]

debug = {
    Data = {},
}
debug.__index = debug

function debug.profilebegin(Name: string)
    if (not debug.Data[Name]) then
        debug.Data[Name] = {
            ["Start"] = os.clock(),
            ["Name"] = Name,
        }
    end
end

function debug.profileend(Name: string)
    local Data = debug.Data[Name]

    if (not Data) then
        return
    end

    print(`{Name} took {(os.clock() - Data.Start) * 1000}ms to run.`)
    debug.Data[Name] = nil
end