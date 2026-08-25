local targetURL = (getgenv().DaKeyless == false)
	and "https://raw.githubusercontent.com/rileybeerblx1/aurora/refs/heads/main/fahh.lua"
	or "https://raw.githubusercontent.com/rileybeerblx1/aurora/refs/heads/main/uimobile.lua"

local success, result = pcall(function()
	return loadstring(game:HttpGet(targetURL))()
end)

if not success then
	warn("[Aurora Loader] Error loading script: " .. tostring(result))
end
