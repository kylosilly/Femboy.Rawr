local Debug = false -- only enable if you wanna see what these hidden remotes do

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = game:GetService("Players").LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SellZone = Workspace:WaitForChild("Touches"):WaitForChild("SellZones"):WaitForChild("Arctic")

local Network = require(Modules:WaitForChild("Network")) -- Network.FireServer, Network.InvokeServer

local GetHandler = filtergc("function", {
    Name = "GetHandler"
}, true)

-- Blank remote fixer
if (Debug) then
    for _, Table in (debug.getupvalue(GetHandler, 1)) do
        for RemoteName, Data in Table do
            local Remote = Data.Remote

            if (Remote) then
                Remote.Name = RemoteName
            end
        end
    end
end

local Delays = {
    ShakeBottle = { LastRan = 0, Delay = .25},
    AutoSell = { LastRan = 0, Delay = 1},
}

local Library = loadstring(game:HttpGet("https://github.com/pubmain/bin/raw/main/Thugsense.luau"))()

Library.Theme.Accent = Color3.fromRGB(128, 128, 128)

Library:Connection(RunService.RenderStepped:Connect(function()
    local Now = tick()

    if (Library.Flags["Farm.AutoShake"]) and (Now > (Delays.ShakeBottle.LastRan + Delays.ShakeBottle.Delay)) then
        Delays.ShakeBottle.LastRan = Now

        Remotes.Network:FireServer("ShakeBottle", false)
    end

    if (Library.Flags["Farm.AutoSell"]) and (Now > (Delays.AutoSell.LastRan + Delays.AutoSell.Delay)) then
        local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if (Root) then
            Delays.AutoSell.LastRan = Now

            firetouchinterest(Root, SellZone, 0)
            firetouchinterest(Root, SellZone, 1)
        end
    end
end))

local Window = Library:Window({
	Name = "Sniper",
	GameName = "Operation One",
	Size = UDim2.fromOffset(450, 500),
})

do
	local _Unload = Library.Unload
	Library.Unload = function(self)
		_Unload(self)
	end
end

local Watermark = Library:Watermark(`Femboy.Rawr ~ {os.date("%b %d %Y")}`)
local KeybindList = Library:KeybindList()

Watermark:SetVisibility(false)
KeybindList:SetVisibility(false)

local Pages = {
	Main = Window:Page({ Name = "Main", Columns = 2, Subtabs = false }),
	Settings = Library:CreateSettingsPage(Window, Watermark, KeybindList)
}

do
    local Farm = Pages.Main:Section({ Name = "Farm", Side = 1 })

    do
        Farm:Toggle({
            Name = "Auto Shake",
            Flag = "Farm.AutoShake",
            Default = false,
        })
        Farm:Toggle({
            Name = "Auto Sell",
            Flag = "Farm.AutoSell",
            Default = false,
        })
    end
end