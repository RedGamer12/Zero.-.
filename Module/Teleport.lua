local DependencyLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/RedGamer12/Zero.-./main/Module/FastLoadDependencies.lua"))()

local PlayerChecker = DependencyLoader.FastLoadDependencies("https://raw.githubusercontent.com/RedGamer12/Zero.-./main/Module/PlayerTracker.lua")

local TeleportModule = {}

function TeleportModule.TweenService1(player, pos, speed, found, toggle)
    if PlayerChecker.IsPlayerDead(player) then
        player.Character.HumanoidRootPart.CFrame = pos
        return
    end

    local val = Instance.new("CFrameValue")
    val.Value = player.Character.HumanoidRootPart.CFrame

    local tween = game:GetService("TweenService"):Create(val, 
    TweenInfo.new((player.Character.HumanoidRootPart.Position - pos.p).magnitude / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
    {Value = pos}
    )

    tween:Play()

    local completed
    tween.Completed:Connect(function()
        completed = true
    end)

    while not completed do
        if found or not toggle or PlayerChecker.IsPlayerDead(player) then
            tween:Cancel()
            break
        end
        player.Character.HumanoidRootPart.CFrame = val.Value
        task.wait()
    end

    val:Destroy()
end

function TeleportModule.TweenService2(player, object, speed, found, toggle)
    if PlayerChecker.IsPlayerDead(player) then
        player.Character.HumanoidRootPart.CFrame = object.CFrame
        return
    end

    local val = Instance.new("CFrameValue")
    val.Value = player.Character.HumanoidRootPart.CFrame

    local tween = game:GetService("TweenService"):Create(val,
        TweenInfo.new((player.Character.HumanoidRootPart.Position - object.Position).magnitude / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
        {Value = object.CFrame}
    )

    tween:Play()

    local function updateCFrame()
        while true do
            if found or not toggle or PlayerChecker.IsPlayerDead(player) then
                tween:Cancel()
                break
            end
            player.Character.HumanoidRootPart.CFrame = val.Value
            task.wait()
        end
    end

    spawn(updateCFrame)

    local completed
    tween.Completed:Connect(function()
        completed = true
    end)

    repeat
        wait()
    until completed

    val:Destroy()
end

return TeleportModule
