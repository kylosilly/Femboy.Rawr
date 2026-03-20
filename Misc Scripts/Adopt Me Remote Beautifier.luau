local RouterClient = require(game:GetService("ReplicatedStorage"):WaitForChild("Fsys")).load("RouterClient")

for Index = 1, #debug.getupvalues(RouterClient.init) do
    local Remotes = debug.getupvalue(RouterClient.init, Index)
    
    if (type(Remotes) == "table") then
        for OriginalName, Remote in (Remotes) do
            if (typeof(Remote) == "Instance") and (Remote:IsA("RemoteEvent") or Remote:IsA("RemoteFunction")) then
                Remote.Name = OriginalName
            end
        end
    end
end
