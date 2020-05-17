--require("Misc.loadout")
--require("Libraries.skill.main")

---------------
-- Resources --
---------------

local baseSprites = {
	idle = Sprite.find("Feral2Idle", "vanilla"),
	walk = Sprite.find("Feral2Walk", "vanilla"),
	jump = Sprite.find("Feral2Jump", "vanilla"),
	climb = Sprite.find("Feral2Climb", "vanilla"),
	death = Sprite.find("Feral2Death", "vanilla"),
}

local sprites = {
	shoot1_1 = Sprite.find("Feral2Shoot1_1", "vanilla"),
	shoot1_2 = Sprite.find("Feral2Shoot1_2", "vanilla"),
	shoot2 = Sprite.find("Feral2Shoot2", "vanilla"),
	icons = Sprite.load("AcridSkills", "Actors/commando/skills", 8, 0, 0),
	palettes = Sprite.load("AcridPalettes", "Actors/commando/palettes", 2, 0, 0),
	loadout = Sprite.find("SelectFeral", "vanilla"),
	------
	bite2 = Sprite.find("Bite2", "vanilla")
}

local sounds = {
	feralShoot1 = Sound.find("FeralShoot1", "vanilla"),
	feralShoot2 = Sound.find("FeralShoot2", "vanilla"),
}

------------
-- Skills --
------------

local function initActivity(player, index, sprite, speed, scaleSpeed, resetHSpeed)
	if player:get("activity") == 0 then
		player:survivorActivityState(index, sprite, speed, scaleSpeed, resetHSpeed)
		player:activateSkillCooldown(index)
		return true
	end
	return false
end

-- Passives

local poison = Skill.new()

poison.displayName = "Poison"
poison.description = "Certain attacks Poison enemies, dealing 24% damage per second."
poison.icon = sprites.icons
poison.iconIndex = 1
poison.cooldown = 0

local poison2 = Skill.new()

poison2.displayName = "Poison 2.0"
poison2.description = "Certain attacks Poison enemies, dealing damage equal to 10% of their maximum health over time. Poison cannot kill enemies."
poison2.icon = sprites.icons
poison2.iconIndex = 1
poison2.cooldown = 0

local blight = Skill.new()

blight.displayName = "Blight"
blight.description = "Attacks that apply Poison apply stacking Blight instead, dealing 60% damage per second."
blight.icon = sprites.icons
blight.iconIndex = 1
blight.cooldown = 0

-- Festering Wounds

local festeringWounds = Skill.new()

festeringWounds.displayName = "Festering Wounds"
festeringWounds.description = "Maul an enemy for 120% damage. The target is poisoned for 24% damage per second."
festeringWounds.icon = sprites.icons
festeringWounds.iconIndex = 1
festeringWounds.cooldown = 22

festeringWounds:setEvent("init", function(player, index)
	local animations = {
		[0] = player:getAnimation("shoot1_1"),
		[1] = player:getAnimation("shoot1_2")
	}
	return initActivity(player, index, animations[math.round(math.random())], 0.25, true, true)
end)
festeringWounds:setEvent(3, function(player, index)
	if not player:survivorFireHeavenCracker() then
		sounds.feralShoot1:play(0.9 + (math.random() * 0.1))
		for i = 0, player:get("sp") do
			local exp = player:fireExplosion(player.x + (12*player.xscale), player.y + 7, 1, 3, 1.2, nil, sprites.bite2)
			exp:set("climb", i*8)
			exp:set("max_hit_number", 1)
			exp:set("poison_dot", 1)
			player:set("pHspeed", 3 * player.xscale)

		end
	end
end)

-- Neurotoxin

local neurotoxin = Skill.new()

neurotoxin.displayName = "Neurotoxin"
neurotoxin.description = "Spit toxic bile for 220% damage, stunning enemies in a line for 1 second."
neurotoxin.icon = sprites.icons
neurotoxin.iconIndex = 2
neurotoxin.cooldown = 2 * 60
neurotoxin:setEvent("init", function(player, index)
	return initActivity(player, index, player:getAnimation("shoot2"), 0.25, true, true)
end)
neurotoxin:setEvent("all", function(player, index)
	if player:get("free") == 1 then player:set("pHspeed", 0) end
end)
neurotoxin:setEvent(4, function(player, index)
	sounds.feralShoot2:play()
	misc.shakeScreen(4)
	for i = 0, player:get("sp") do
		local penetrating = player:fireBullet(player.x, player.y, 90 - (90 * player.xscale), 80, 2.2, nil, nil)
		penetrating:set("stun", 0.5)
	end
end)

-- Caustic Sludge

local spreadSludge = Skill.new()

spreadSludge.displayName = "Caustic Sludge"
spreadSludge.description = "Secrete poisonous sludge for 2 seconds. Speeds up allies, while slowing and hurting enemies for 90% damage."
spreadSludge.icon = sprites.icons
spreadSludge.iconIndex = 3
spreadSludge.cooldown = 17 * 60

-- Epidemic

local epidemic = Skill.new()

epidemic.displayName = "Epidemic"
epidemic.description = "Release a deadly disease, poisoning enemies for 100% per second. The contagion spreads to two targets after 1 second."
epidemic.icon = sprites.icons
epidemic.iconIndex = 4
epidemic.cooldown = 11 * 60

-- Pandemic

local pandemic = Skill.new()

pandemic.displayName = "Pandemic"
pandemic.description = "Release a deadly disease, poisoning enemies for 100% per second. The contagion spreads to two targets after 1 second. If an enemy is killed by Pandemic, you are healed."
pandemic.icon = sprites.icons
pandemic.iconIndex = 4
pandemic.cooldown = 11 * 60

--------------
--  Skins   --
--------------

local s_default = Skill.new()

s_default.displayName = "Default"
s_default.description = ""
s_default.icon = sprites.palettes
s_default.iconIndex = 1
s_default.cooldown = -1

local defaultSprites = {
	["loadout"] = sprites.loadout,
	["idle"] = baseSprites.idle,
	["walk"] = baseSprites.walk,
	["jump"] = baseSprites.jump,
	["climb"] = baseSprites.climb,
	["death"] = baseSprites.death,
	["shoot1_1"] = sprites.shoot1_1,
	["shoot1_2"] = sprites.shoot1_2,
	["shoot2"] = sprites.shoot2,
}

local s_albino = Skill.new()

s_albino.displayName = "Albino"
s_albino.description = ""
s_albino.icon = sprites.palettes
s_albino.iconIndex = 2
s_albino.cooldown = -1

--[[local albinoSprites = {
	["loadout"] = Sprite.load("SelectCommando_Skin1", "Actors/commando/hornet/select", 13, 2, 0),
	["idle"] = Sprite.load("CommandoIdleSkin1", "Actors/commando/hornet/idle", baseSprites.idle.frames, baseSprites.idle.xorigin, baseSprites.idle.yorigin),
	["walk"] = Sprite.load("CommandoWalkSkin1", "Actors/commando/hornet/walk", baseSprites.walk.frames, baseSprites.walk.xorigin, baseSprites.walk.yorigin),
	["jump"] = Sprite.load("CommandoJumpSkin1", "Actors/commando/hornet/jump", baseSprites.jump.frames, baseSprites.jump.xorigin, baseSprites.jump.yorigin),
	["climb"] =Sprite.load("CommandoClimbSkin1", "Actors/commando/hornet/climb", baseSprites.climb.frames, baseSprites.climb.xorigin, baseSprites.climb.yorigin),
	["death"] = Sprite.load("CommandoDeathSkin1", "Actors/commando/hornet/death", baseSprites.death.frames, baseSprites.death.xorigin, baseSprites.death.yorigin),
	["shoot1"] = Sprite.load("CommandoShoot1Skin1", "Actors/commando/hornet/shoot1", sprites.shoot1.frames, sprites.shoot1.xorigin, sprites.shoot1.yorigin),
	["shoot2"] = Sprite.load("CommandoShoot2Skin1", "Actors/commando/hornet/shoot2", sprites.shoot2.frames, sprites.shoot2.xorigin, sprites.shoot2.yorigin),
	["shoot2b"] = Sprite.load("CommandoShoot2bSkin1", "Actors/commando/hornet/altshoot2", sprites.shoot2b.frames, sprites.shoot2b.xorigin, sprites.shoot2b.yorigin),
	["shoot3"] = Sprite.load("CommandoShoot3Skin1", "Actors/commando/hornet/shoot3", sprites.shoot3.frames, sprites.shoot3.xorigin, sprites.shoot3.yorigin),
	["shoot4_1"] = Sprite.load("CommandoShoot4_1Skin1", "Actors/commando/hornet/shoot4_1", sprites.shoot4_1.frames, sprites.shoot4_1.xorigin, sprites.shoot4_1.yorigin),
	["shoot4_2"] = Sprite.load("CommandoShoot4_2Skin2", "Actors/commando/hornet/shoot4_2", sprites.shoot4_2.frames, sprites.shoot4_2.xorigin, sprites.shoot4_2.yorigin),
	["shoot4b"] = Sprite.load("CommandoShoot4bSkin1", "Actors/commando/hornet/altshoot4", sprites.shoot4b.frames, sprites.shoot4b.xorigin, sprites.shoot4b.yorigin),
	["shoot5_1"] = Sprite.load("CommandoShoot5_1Skin1", "Actors/commando/hornet/shoot5_1", sprites.shoot5_1.frames, sprites.shoot5_1.xorigin, sprites.shoot5_1.yorigin),
	["shoot5_2"] = Sprite.load("CommandoShoot5_2Skin2", "Actors/commando/hornet/shoot5_2", sprites.shoot5_2.frames, sprites.shoot5_2.xorigin, sprites.shoot5_2.yorigin),
}]]

--------------
-- Survivor --
--------------

local acrid = Survivor.new("Acrid 2.0")
local vanilla = Survivor.find("Acrid")

local loadout = Loadout.new()
loadout.survivor = acrid
loadout.description = [[&y&Acrid&!& deals &y&huge amount of damage&!& after &y&stacking poisons&!& from his
&y&Festering Wounds, Caustic Sludge, and Epidemic&!&. 
Try to &y&stun targets inside your Caustic Sludge&!& for maximum damage. 
Remember that you can fight at &y&both melee and range!&!&]]

loadout:addSkill("Primary", festeringWounds, {
	loadoutDescription = [[Shoot twice for &y&2x60% damage.&!&]]
})
loadout:addSkill("Secondary", neurotoxin, {
	loadoutDescription = [[Shoot &y&through enemies&!& for &y&230% damage,
knocking them back.&!&]]
})
loadout:addSkill("Utility", spreadSludge,{
	loadoutDescription = [[&y&Roll forward&!& a small distance.
You &b&cannot be hit&!& while rolling.]]
})
loadout:addSkill("Special", epidemic,{
	loadoutDescription = [[Fire rapidly, &y&stunning&!& and hitting nearby enemies
for &y&6x60% damage&!&.]],
	upgrade = loadout:addSkill("Special", epidemic, {hidden = true}) 
}) 
loadout:addSkin(s_default, defaultSprites)
loadout:addSkin(s_albino, defaultSprites, {
	locked = true,
	unlockText = "Acrid: Obliterate yourself at the Obelisk on Monsoon difficulty."
})

acrid.titleSprite = baseSprites.walk
acrid.loadoutColor = Color.fromRGB(201, 242, 77)
acrid.loadoutSprite = sprites.loadout
acrid.endingQuote = "..and so it left, with a new hunger: to be left alone."

acrid:addCallback("init", function(player)
	player:setAnimations(baseSprites)
	player:survivorSetInitialStats(114, 12, 0.01)
	player:set("armor", 15)
	player:set("pHmax", 1.4)
	player:set("pVmax", 3)
end)

acrid:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(50, 3, 0.03, 2)
end)

acrid:addCallback("scepter", function(player)
	Loadout.Upgrade(loadout, player, "Special")
end)

Loadout.RegisterSurvivorID(acrid)

---------------------------------

local albinoUnlock = Achievement.new("unlock_acrid_skin1")
albinoUnlock.requirement = 1
albinoUnlock.sprite = MakeAchievementIcon(sprites.palettes, 2)
albinoUnlock.unlockText = "New skin: \'Albino\' unlocked."
albinoUnlock.highscoreText = "Acrid: \'Albino\' unlocked"
albinoUnlock.description = "Acrid: Obliterate yourself at the Obelisk on Monsoon difficulty."
albinoUnlock.deathReset = false
albinoUnlock:addCallback("onComplete", function()
	loadout:getSkillEntry(s_albino).locked = false
	Loadout.Save(loadout)
end)


return acrid