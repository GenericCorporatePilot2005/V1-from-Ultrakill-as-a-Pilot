local this={}

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- read out other files and add what they return to variables.
local mod = modApi:getCurrentMod()
local scriptPath = modApi:getCurrentMod().scriptPath
local replaceRepair = require(scriptPath.."replaceRepair/replaceRepair")

local pilotV2 = {
	Id = "Nico_Pilot_V2",					-- id must be unique. Used to link to art assets.
	Personality = "Vek",        -- must match the id for a personality you have added to the game.
	Name = "V2",
	Rarity = 3,
	PowerCost = 1,
	Voice = "/voice/ai",				-- audio. look in pilots.lua for more alternatives.
	Skill = "Nico_V2skill",				-- pilot's ability - Must add a tooltip for new skills.
}

CreatePilot(pilotV2)

-- add assets - notice how the name is identical to pilot.Id
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V2.png", path .."img/portraits/Nico_Pilot_V2.png")
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V2_2.png", path .."img/portraits/Nico_Pilot_V2_2.png")
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V2_blink.png", path .."img/portraits/Nico_Pilot_V2_blink.png")

function this:init(mod)

	replaceRepair:addSkill{
		Name = "Clair de Lune",
		Description = "Instead of repairing, punch an adjacent tile, dealing huge damage and pushing tiles adjacent to target.",
		weapon = "Nico_V2skill",
		pilotSkill = "Nico_V2skill",
		Icon = "img/weapons/V2Punchrepair.png",
		IsActive = function(pawn)
			return pawn:IsAbility(pilotV2.Skill)
		end
	}

	---- Heavy punch ----
	Nico_V2skill = Prime_Smash:new{
		Name = "KnuckleBlaster",
		Description = "Instead of repairing, punch an adjacent tile, dealing huge damage and pushing adjacent tiles.",
		Icon = "img/weapons/V2Punchrepair.png",
		PathSize = 1,
		Damage = 2,
		PowerCost = 0,
		Upgrades = 0,
		Limited = 0,
		LaunchSound = "/weapons/titan_fist",
		TipImage = {
			Unit = Point(2,3),
			Enemy = Point(2,2),
			Enemy2 = Point(3,2),
			Target = Point(2,2)
		}
	}
	-- art, icons, animations
		modApi:appendAsset("img/effects/V2punch_D.png",mod.resourcePath.."img/effects/V2punch_D.png")
		modApi:appendAsset("img/effects/V2punch_L.png",mod.resourcePath.."img/effects/V2punch_L.png")
		modApi:appendAsset("img/effects/V2punch_R.png",mod.resourcePath.."img/effects/V2punch_R.png")
		modApi:appendAsset("img/effects/V2punch_U.png",mod.resourcePath.."img/effects/V2punch_U.png")
		
		ANIMS.V2punch_0 = Animation:new{
			Image = "effects/V2punch_U.png",
			NumFrames = 6,
			Time = 0.12,
			PosX = -22,
			PosY = -8,
		}
		
		ANIMS.V2punch_1 = ANIMS.V2punch_0:new{
			Image = "effects/V2punch_R.png",
			PosX = -21,
			PosY = -6,
		}
		
		ANIMS.V2punch_2 = ANIMS.V2punch_0:new{
			Image = "effects/V2punch_D.png",
			PosX = -24,
			PosY = -6,
		}
		
		ANIMS.V2punch_3 = ANIMS.V2punch_0:new{
			Image = "effects/V2punch_L.png",
			PosX = -22,
			PosY = -8,
		}
	
		function Nico_V2skill:GetSkillEffect(p1, p2)
			local ret = SkillEffect()
			local direction = GetDirection(p2 - p1)
			
			ret:AddDamage(SoundEffect(p2,self.LaunchSound))
			
			damage = SpaceDamage(p2, self.Damage)
			damage.sAnimation = "V2punch_"..direction
			
			ret:AddDamage(damage)
			
			ret:AddBounce(p2,4)
			ret:AddDelay(1)
			
			local damage = SpaceDamage(p2 + DIR_VECTORS[direction], 0, direction)
			damage.sAnimation = "airpush_"..direction
			ret:AddBounce(damage.loc,2)
			ret:AddDamage(damage)
			
			damage = SpaceDamage(p2 + DIR_VECTORS[(direction + 1)% 4], 0, (direction+1)%4)
			damage.sAnimation = "airpush_"..((direction+1)%4)
			ret:AddBounce(damage.loc,2)
			ret:AddDamage(damage)
			
			damage = SpaceDamage(p2 + DIR_VECTORS[(direction - 1)% 4],0, (direction-1)%4)
			damage.sAnimation = "airpush_"..((direction-1)%4)
			ret:AddBounce(damage.loc,2)
			ret:AddDamage(damage)
			
			
			return ret
		end	


end




return this
