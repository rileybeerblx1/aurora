getgenv().DaKeyless = false
local targetURL

if getgenv().DaKeyless == false then
    targetURL = "https://raw.githubusercontent.com/rileybeerblx1/aurora/refs/heads/main/fahh.lua"
else
    targetURL = "https://raw.githubusercontent.com/rileybeerblx1/aurora/refs/heads/main/uimobile.lua"
end

local success, result = pcall(function()
    return loadstring(game:HttpGet(targetURL))()
end)

if not success then
    warn("[Aurora Loader] Error loading script: " .. tostring(result))
end
