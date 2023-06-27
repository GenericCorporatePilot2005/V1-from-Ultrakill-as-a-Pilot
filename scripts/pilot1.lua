local this={}

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- read out other files and add what they return to variables.
local mod = modApi:getCurrentMod()
local scriptPath = modApi:getCurrentMod().scriptPath
local replaceRepair = require(scriptPath.."replaceRepair/replaceRepair")

local pilotV1 = {
	Id = "Nico_Pilot_V1",					-- id must be unique. Used to link to art assets.
	Personality = "Vek",        -- must match the id for a personality you have added to the game.
	Name = "V1",
	Rarity = 2,
	PowerCost = 1,
	Voice = "/voice/ai",				-- audio. look in pilots.lua for more alternatives.
	Skill = "Nico_V1skill",				-- pilot's ability - Must add a tooltip for new skills.
}

CreatePilot(pilotV1)

-- add assets - notice how the name is identical to pilot.Id
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1.png", path .."img/portraits/Nico_Pilot_V1.png")
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1_2.png", path .."img/portraits/Nico_Pilot_V1_2.png")
	modApi:appendAsset("img/portraits/pilots/Nico_Pilot_V1_blink.png", path .."img/portraits/Nico_Pilot_V1_blink.png")

function this:init(mod)

	replaceRepair:addSkill{
		Name = "Blood Lust",
		Description = "Instead of repairing, does a melee attack that flips the target's attacks and damages, if the target is a Vek, fully heals self.",
		weapon = "Nico_V1skill",
		pilotSkill = "Nico_V1skill",
		Icon = "img/weapons/V1Punchrepair.png",
		IsActive = function(pawn)
			return pawn:IsAbility(pilotV1.Skill)
		end
	}

	---- Parry ----
	Nico_V1skill = Skill:new{
		Name = "Parry",
		Description = "Instead of repairing, does a melee attack that flips the target's attacks and damages, if the target is a Vek, fully heals self.",
		Icon = "img/weapons/V1Punchrepair.png",
		Flip = true,
		PathSize = 1, --This does the TargetArea on its own, no need for our own
		Damage=1,
		TipImage = { --You'll have to create a custom tip image if you want the enemy to fire
			Unit = Point(1,2),
			Enemy1 = Point(1,1),
			Target = Point(1,1),
			Queued1 = Point(2,1),
			Friendly = Point(3,1),
			CustomEnemy = "Firefly2",
			Length = 4,
		} --Check Science_Confuse in weapons_science.lua if you want an example
	}
	-- art, icons, animations
		modApi:appendAsset("img/effects/V1punch_D.png",mod.resourcePath.."img/effects/V1punch_D.png")
		modApi:appendAsset("img/effects/V1punch_L.png",mod.resourcePath.."img/effects/V1punch_L.png")
		modApi:appendAsset("img/effects/V1punch_R.png",mod.resourcePath.."img/effects/V1punch_R.png")
		modApi:appendAsset("img/effects/V1punch_U.png",mod.resourcePath.."img/effects/V1punch_U.png")
		modApi:appendAsset("img/effects/V1Blood.png",mod.resourcePath.."img/effects/V1Blood.png")
		
		ANIMS.V1punch_0 = Animation:new{
			Image = "effects/V1punch_U.png",
			NumFrames = 6,
			Time = 0.06,
			PosX = -22,
			PosY = -8,
		}
		
		ANIMS.V1punch_1 = ANIMS.V1punch_0:new{
			Image = "effects/V1punch_R.png",
			PosX = -21,
			PosY = -6,
		}
		
		ANIMS.V1punch_2 = ANIMS.V1punch_0:new{
			Image = "effects/V1punch_D.png",
			PosX = -24,
			PosY = -6,
		}
		
		ANIMS.V1punch_3 = ANIMS.V1punch_0:new{
			Image = "effects/V1punch_L.png",
			PosX = -22,
			PosY = -8,
		}
		ANIMS.V1Blood = Animation:new{
			Image = "effects/V1Blood.png",
			NumFrames = 8,
			Time = 0.08,
			
			PosX = -22,
			PosY = 1
		}

	function Nico_V1skill:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local direction = GetDirection(p2-p1)
		local push_damage = self.Flip and DIR_FLIP or direction
		local damage = SpaceDamage(p2, self.Damage, push_damage)
		damage.sAnimation = "V1punch_"..((direction+1)%4)
		local swipe = SpaceDamage(p2,0)
		swipe.sAnimation = "SwipeClaw2"
		local heal= SpaceDamage(p1,-10)
		heal.sAnimation="V1Blood"
		if Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetDefaultFaction() ~= FACTION_BOTS and Board:GetPawnTeam(p2) == TEAM_ENEMY then
			ret:AddDamage(heal)
			ret:AddDamage(swipe)
		end
		ret:AddBounce(p1,1)
		ret:AddBounce(p2,3)

		ret:AddMelee(p2 - DIR_VECTORS[direction], damage)
		return ret
	end
end




return this
