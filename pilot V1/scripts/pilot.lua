local this={}

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- read out other files and add what they return to variables.
local mod = modApi:getCurrentMod()
local scriptPath = modApi:getCurrentMod().scriptPath
local replaceRepair = require(scriptPath.."replaceRepair/replaceRepair")

local pilot = {
	Id = "Nico_Pilot_V1",					-- id must be unique. Used to link to art assets.
	Personality = "Artificial",        -- must match the id for a personality you have added to the game.
	Name = "V1",
	Rarity = 1,
	PowerCost = 1,
	Voice = "/voice/ai",				-- audio. look in pilots.lua for more alternatives.
	Skill = "Nico_V1skill",				-- pilot's ability - Must add a tooltip for new skills.
}

CreatePilot(pilot)

-- add assets - notice how the name is identical to pilot.Id
modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1.png", path .."img/portraits/Nico_Pilot_V1.png")
modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1_2.png", path .."img/portraits/Nico_Pilot_V1_2.png")
modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1_blink.png", path .."img/portraits/Nico_Pilot_V1_blink.png")

function this:init(mod)

	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Blood Lust", "If an adjacent vek suffers damage, heals 1 health point.\nReplaces repair with a punch that flips an enemy's attack."))

	---- Parry ----
	Nico_V1skill = Skill:new{
		Icon = "img/weapons/V1Punchrepair.png",
		Flip = true,
		PathSize = 1,
		Damage=1,
		TipImage = {
			Unit = Point(2,3),
			Target = Point(2,2),
		}
	}


	function Nico_V1skill:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local push_damage = self.Flip and DIR_FLIP or direction
		local damage = SpaceDamage(target, self.Damage, push_damage)
		damage.sAnimation = "punch1_"..direction
		ret:AddMelee(p2 - DIR_VECTORS[direction], damage)
		return ret
	end

	function Nico_V1skill:GetTargetArea(point) 
  	  local ret = PointList()
		ret:push_back(curr)    
	    return ret 
	end
end


	
replaceRepair:addSkill{
	Name = "Parry",
	Description = "Repairing is replaced with a melee attack that flips enemies' attacks.",
	weapon = "Nico_V1skill",
	pilotSkill = "Nico_V1skill",
	Icon = "img/weapons/V1Punchrepair.png",
	IsActive = function(pawn)
		return pawn:IsAbility(pilot.Skill)
	end
}
return this