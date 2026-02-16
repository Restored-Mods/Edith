local Wiki = require("lua.mod_compat.encyclopedia.wiki")
EdithRestored:AddModCompat("Encyclopedia", function()

	for fn, tp in pairs(Wiki) do
		for k, v in pairs(tp) do
			Encyclopedia["Add" .. fn](v)
		end
	end

	EdithRestored.Enums.Wiki = Wiki
end)
