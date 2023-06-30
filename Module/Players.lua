local Players = {}

local blackList = {}

function Players.Get(plr)
    local playerNames = {}
    for _, player in ipairs(plr:GetPlayers()) do
        if not blackList[player.Name] then  -- Kiểm tra xem người chơi có trong danh sách cấm hay không
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

function Players.AddToBlacklist(playerName)
    blackList[playerName] = true
end

function Players.RemoveFromBlacklist(playerName)
    blackList[playerName] = nil
end

print("Loaded Players_Module.lua")
return Players


--[[
-- Thêm một người chơi vào danh sách cấm
Players.AddToBlacklist("Player1")

-- Xóa một người chơi khỏi danh sách cấm
Players.RemoveFromBlacklist("Player2")

-- Lấy danh sách tên người chơi không nằm trong danh sách cấm
local playerNames = Players.Get(game:GetService("Players"))

-- In ra màn hình tên của từng người chơi
for _, name in ipairs(playerNames) do
    print(name)
end
]]
