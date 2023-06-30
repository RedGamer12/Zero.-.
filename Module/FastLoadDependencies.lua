local DependencyLoader = {}

local function FastHttpGet(URL)
    if (syn and syn.request) then
        return syn.request({Url = URL}).Body
    end
    return game:HttpGet(URL)
end

function DependencyLoader.FastLoadDependencies(...)
    -- Vars
    local Loaded = {}
    local Arguments = {...}
    local Amount = #Arguments

    -- Loop through each argument
    for i, v in pairs(Arguments) do
        -- Load and set the loaded script
        task.spawn(function()
            Loaded[i] = loadstring(FastHttpGet(v))()
        end)
    end

    -- Wait until we loaded each dependency
    repeat task.wait() until #Loaded == Amount

    -- Return all of the dependencies as a tuple
    return table.unpack(Loaded)
end

return DependencyLoader

--[[
local DependencyLoader = require(path.to.DependencyLoaderModule)

-- Gọi hàm FastLoadDependencies trong module DependencyLoader và cung cấp các đối số
local dependency1, dependency2 = DependencyLoader.FastLoadDependencies("https://example.com/dependency1.lua", "https://example.com/dependency2.lua")
]]