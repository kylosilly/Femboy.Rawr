local router_client = require(game:GetService("ReplicatedStorage"):WaitForChild("Fsys")).load("RouterClient");

for index = 1, #debug.getupvalues(router_client.init) do
    local remotes = debug.getupvalue(router_client.init, index);
    if (type(remotes) == "table") then
        for remote_name, remote in (remotes) do
            if (typeof(remote) == "Instance") and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                remote.Name = remote_name;
            end
        end
    end
end
