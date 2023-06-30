local Players = {}

local blackList = {}

function Players.AddToBlacklist(playerName)
    blackList[playerName] = true
end

function Players.RemoveFromBlacklist(playerName)
    blackList[playerName] = nil
end

function Players.IsPlayerBlacklisted(playerName)
    return blackList[playerName] or false
end

print("Loaded Players_Module.lua")
return Players


--[[
-- Thêm một người chơi vào danh sách cấm
Players.AddToBlacklist("Player1")

-- Xóa một người chơi khỏi danh sách cấm
Players.RemoveFromBlacklist("Player2")

local playerToCheck = "Player1"
if Players.IsPlayerBlacklisted(playerToCheck) then
    print(playerToCheck .. " is blacklisted.")
else
    print(playerToCheck .. " is not blacklisted.")
end
]]
