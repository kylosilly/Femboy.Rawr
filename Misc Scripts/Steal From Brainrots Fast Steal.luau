local local_player = game:GetService("Players").LocalPlayer;

local claim_brainrot = game:GetService("Workspace").Atmosphere.ClaimBrainrot;

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if (prompt.ActionText == "Steal? 😈") then
        fireproximityprompt(prompt);
        firetouchinterest(local_player.Character.PrimaryPart, claim_brainrot, 0);
        firetouchinterest(local_player.Character.PrimaryPart, claim_brainrot, 1);
    end
end)
