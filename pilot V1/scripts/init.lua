
-- init.lua is the entry point of every mod

local mod = {
	id = "Nico_V1_Pilot",
	name = "V1 Ultrakill pilot",
	version = "0.0.0",
	requirements = {},
	modApiVersion = "2.3.0",
	icon = "img/mod_icon.png"
}

function mod:init()
	-- look in template/pilot to see how to code pilots.
	local pilot = require(self.scriptPath .."pilot")
	pilot:init(mod)
	local replaceRepair = require(self.scriptPath.."replaceRepair/replaceRepair")
end

function mod:load(options, version)
end

return mod
