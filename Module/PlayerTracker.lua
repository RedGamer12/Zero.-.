local PlayerTracker = {}

-- Tạo một table để lưu trữ danh sách người chơi đã được kiểm tra
local checkedPlayers = {}

function PlayerTracker.CheckNewPlayers(plr)
    local newPlayers = {}
    for _, player in ipairs(plr:GetPlayers()) do
        if not checkedPlayers[player] then  -- Kiểm tra xem người chơi đã được kiểm tra hay chưa
            table.insert(newPlayers, player.Name)
            checkedPlayers[player] = true  -- Đánh dấu người chơi đã được kiểm tra
        end
    end
    return newPlayers
end

function PlayerTracker.GetPlayerTeam(player)
    local playerTeam = player.Team
    if playerTeam then
        return playerTeam.Name
    else
        return nil
    end
end

return PlayerTracker

--[[
-- Kiểm tra người chơi mới vào trò chơi
local newPlayers = PlayerTracker.CheckNewPlayers(game:GetService("Players"))

-- In ra màn hình tên của những người chơi mới
for _, name in ipairs(newPlayers) do
    print(name)
end
]]

--[[
-- Lấy danh sách người chơi
local players = game:GetService("Players"):GetPlayers()

-- Kiểm tra nhóm của từng người chơi
for _, player in ipairs(players) do
    local playerTeam = TeamChecker.GetPlayerTeam(player)
    if playerTeam then
        print(player.Name .. " thuộc nhóm " .. playerTeam)
    else
        print(player.Name .. " không thuộc bất kỳ nhóm nào.")
    end
end
]]