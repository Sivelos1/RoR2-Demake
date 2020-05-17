
------ mult.lua
---- Adds MUL-T from ROR2 as a playable character.

local toolbot = Survivor.new("MUL-T")

-- Load all of our sprites into a table
local sprites = {
	idle1 = Sprite.load("toolbot_idle_nailgun", "Actors/mult/idle1", 1, 11, 17),
	idle2 = Sprite.load("toolbot_idle_rebar", "Actors/mult/idle2", 1, 11, 17),
	walk1 = Sprite.load("toolbot_walk_nailgun", "Actors/mult/walk1", 2, 11, 17),
	walk2 = Sprite.load("toolbot_walk_rebar", "Actors/mult/walk2", 2, 11, 17),
	jump1 = Sprite.load("toolbot_jump_nailgun", "Actors/mult/jump1", 1, 13, 17),
	jump2 = Sprite.load("toolbot_jump_rebar", "Actors/mult/jump2", 1, 13, 17),
	climb1 = Sprite.load("toolbot_climb_nailgun", "Actors/mult/climb1", 2, 9, 16),
	climb2 = Sprite.load("toolbot_climb_rebar", "Actors/mult/climb2", 2, 9, 16),
	death1 = Sprite.load("toolbot_death_nailgun", "Actors/mult/death1", 14, 13, 24),
	death2 = Sprite.load("toolbot_death_rebar", "Actors/mult/death2", 14, 13, 24),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("toolbot_decoy", "Actors/mult/decoy", 1, 9, 14),
}


toolbot.idleSprite = sprites.idle1

local Projectile = require("Libraries.Projectile")

-- Auto-Nailgun --
local sprShoot1_1 = Sprite.load("toolbot_shoot1_1", "Actors/mult/shoot1_1", 4, 11, 17)
local sprShoot1_1end = Sprite.load("toolbot_shoot1_1cooldown", "Actors/mult/shoot1_1end", 4, 11, 17)
local nailgunImpact = Sprite.load("toolbot_shoot1_1hitsprite", "Actors/mult/nails", 6, 8, 4)
local nailgunFireSound = Sound.load("toolbot_shoot1_snd1", "Sounds/SFX/mult/multMinigun.ogg")--Sound.find("Bullet2", "vanilla")
local nailgunCooldownSound = Sound.load("toolbot_shoot1_snd2", "Sounds/SFX/mult/multGunWinddown.ogg")--Sound.find("Chest1", "vanilla")
local nailRotationOffset = 2
local bulletToFire = 0

--Rebar Puncher--
local sprShoot1_2 = Sprite.load("toolbot_shoot1_2", "Actors/mult/shoot1_2", 10, 11, 17)
local rebarImpact = Sprite.load("toolbot_shoot1_2hitsprite", "Actors/mult/rebar", 8, 34, 9)
local rebarChargeSound = Sound.load("toolbot_shoot1_snd3", "Sounds/SFX/mult/rebarWindup.ogg")--Sound.find("SamuraiShoot1", "vanilla")
local rebarFireSound = Sound.load("toolbot_shoot1_snd4", "Sounds/SFX/mult/multRebarPuncher.ogg")--Sound.find("Crowbar", "vanilla")

--Blast Canister--
local sprShoot2_1 = Sprite.load("toolbot_shoot2_1", "Actors/mult/shoot2_1", 8, 11, 17)
local sprShoot2_2 = Sprite.load("toolbot_shoot2_2", "Actors/mult/shoot2_2", 8, 11, 17)
local bombSprite = Sprite.load("toolbot_stunBombSprite", "Actors/mult/stunBomb", 4, 4, 4)
local bombFireSound =  Sound.load("toolbot_shoot2_snd1", "Sounds/SFX/mult/multBombLoad.ogg")--Sound.find("CowboyShoot2", "vanilla")
local stunBombExplosionSound = Sound.load("toolbot_shoot2_snd2", "Sounds/SFX/mult/multBomb.ogg")--Sound.find("RiotGrenade", "vanilla")
local bombletExplosionSound = Sound.load("toolbot_shoot2_snd3", "Sounds/SFX/mult/multBomblets.ogg")--Sound.find("ClayDeath", "vanilla")
local stunBomb = Projectile.new({
		name = "Stun Bomb",
		mask = bombSprite,
		vx = 1.5,
		vy = -3,
		ax = 0,
		ay = 0.2,
		sprite = bombSprite,
		mask = nil,
		damage = 2.2,
		pierce = true,
		deathsprite_life = Sprite.find("EfBombExplode","vanilla"),
		deathsprite_collision = Sprite.find("EfBombExplode","vanilla"),
		life = 100,
		explosion = true,
		ghost = false,
		multihit = false,
		explosionw = 100,
		explosionh = 100,
		impact_explosion = false,
		damager_variables = {knockback = 1, stun = 1.2},
		})
local bombletA = Projectile.new({
		name = "Bomblet A",
		mask = bombSprite,
		vx = 0.5,
		vy = -3,
		ax = 0,
		ay = 0.2,
		sprite = bombSprite,
		damage = 0.44,
		pierce = false,
		deathsprite_life = Sprite.find("EfExplosive","vanilla"),
		deathsprite_collision = Sprite.find("EfExplosive","vanilla"),
		life = 25,
		explosion = true,
		ghost = false,
		multihit = false,
		explosionw = 90,
		explosionh = 90,
		impact_explosion = true,
		bounce = 0.5,
		damager_variables = {knockback = 0.5, stun = 2},
		})
local bombletB = Projectile.new({
		name = "Bomblet B",
		mask = bombSprite,
		vx = 1.5,
		vy = -2,
		ax = 0,
		ay = 0.2,
		sprite = bombSprite,
		damage = 0.44,
		pierce = false,
		deathsprite_life = Sprite.find("EfExplosive","vanilla"),
		deathsprite_collision = Sprite.find("EfExplosive","vanilla"),
		life = 25,
		explosion = true,
		ghost = false,
		multihit = false,
		explosionw = 90,
		explosionh = 90,
		impact_explosion = true,
		bounce = 0.5,
		damager_variables = {knockback = 0.5, stun = 2},
		})
		
stunBomb:addCallback("step", function(projectileInstance)
    if projectileInstance:isValid() then
        if projectileInstance:get("Projectile_dead") > 0 then
			stunBombExplosionSound:play(1 + math.random() * 0.05, 2)
            Projectile.fire(bombletA, projectileInstance.x,projectileInstance.y,Projectile.getParent(projectileInstance), 1)
            Projectile.fire(bombletB, projectileInstance.x,projectileInstance.y,Projectile.getParent(projectileInstance), 1)
            Projectile.fire(bombletA, projectileInstance.x,projectileInstance.y,Projectile.getParent(projectileInstance), -1)
            Projectile.fire(bombletB, projectileInstance.x,projectileInstance.y,Projectile.getParent(projectileInstance), -1)
        end
    end
end)

bombletA:addCallback("step", function(projectileInstance)
    if projectileInstance:isValid() then
        if projectileInstance:get("Projectile_dead") > 0 then
			bombletExplosionSound:play(1 + math.random() * 0.5, 2)
        end
    end
end)
bombletB:addCallback("step", function(projectileInstance)
    if projectileInstance:isValid() then
        if projectileInstance:get("Projectile_dead") > 0 then
			bombletExplosionSound:play(1 + math.random() * 0.5, 2)
        end
    end
end)

--Transport Mode--
local sprShoot3_1_1 = Sprite.load("toolbot_shoot3_1_1", "Actors/mult/shoot3_1_1", 4, 11, 14)
local sprShoot3_1_2 = Sprite.load("toolbot_shoot3_1_2", "Actors/mult/shoot3_1_2", 4, 11, 14)
local sprShoot3_2 = Sprite.load("toolbot_shoot3_2", "Actors/mult/shoot3_2", 2, 11, 10)
local sprShoot3_3_1 = Sprite.load("toolbot_shoot3_3_1", "Actors/mult/shoot3_3_1", 4, 11, 14)
local sprShoot3_3_2 = Sprite.load("toolbot_shoot3_3_2", "Actors/mult/shoot3_3_2", 4, 11, 14)

local transportTimeMax = 60 * 1 --in frames (60 = 1 second)
local transportSpeedMultiplier = 2 -- MUL-T will go X times his pHmax when in transport mode.

local transportEnterSound = Sound.load("toolbot_shoot3_snd1", "Sounds/SFX/mult/transportStart.ogg")--Sound.find("Chest1", "vanilla")
local transportLoopSound = Sound.load("toolbot_shoot3_snd2", "Sounds/SFX/mult/multTransportB.ogg")--Sound.find("Chest1", "vanilla")
local transportHitSound = Sound.load("toolbot_shoot3_snd3", "Sounds/SFX/mult/multImpact.ogg")--Sound.find("Lightning", "vanilla")
local transportExitSound = Sound.find("Chest2", "vanilla")

local transportImpactFX = Sprite.find("Sparks1", "vanilla")
local transportParticleFX = ParticleType.new("Eat my fuckin dust")
transportParticleFX:sprite(Sprite.find("MinerShoot2Dust1", "vanilla"), true, false, false)
transportParticleFX:life(10,10)

local endingTransportMode = 0
local transportMode = Buff.new("Transport Mode")
transportMode.sprite = Sprite.load("transportModeIcon", "Actors/mult/transportMode", 1, 3, 3)
local transportModeImpact = Projectile.new({
	name = "MUL-T",
	mask = sprShoot3_2,
	vx = 0,
	vy = 0,
	ax = 0,
	ay = 0,
	player = toolbot,
	sprite = Sprite.load("transportImpactSprite", "Graphics/empty", 1, 0, 0),
	hitsprite = transportImpactFX,
	damage = 2.5,
	pierce = true,
	deathsprite_life = sprite,
	deathsprite_collision = sprite,
	life = transportTimeMax,
	explosion = false,
	ghost = false,
	multihit = false,
	damager_variables = {knockback = 3, stun = 1.2, knockup = 3},
	})
local enemiesHit = {}
Projectile.addCallback(transportModeImpact, "onCollide", function(damager, hit, hitTable)
	if(enemiesHit[hit] and hit:get("team") == "enemy") then
		misc.shakeScreen(5)
		if not transportHitSound:isPlaying() then
			transportHitSound:play(1 + math.random() * 0.05)
		end
	end
end)

--Retool--
local sprShoot4_1 = Sprite.load("toolbot_shoot4_nailgun", "Actors/mult/shoot4_1", 9, 11, 17)
local sprShoot4_2 = Sprite.load("toolbot_shoot4_rebar", "Actors/mult/shoot4_2", 9, 11, 17)
local reToolSound = Sound.load("toolbot_shoot4_snd", "Sounds/SFX/mult/multRetool.ogg")--Sound.find("Reload", "vanilla")
local reTooled = 0
local refurbish = Buff.new("Refurbished")
local useItemSlot1 = {} --nailgun item
local useItemSlot2 = {} --rebar item

refurbish.sprite = Sprite.load("refurbSprite","Actors/mult/refurbished", 1, 3, 3)
local originalDamageVal = 0
local nailgunUseItem
local rebarUseItem

-- The sprite used by the skill icons
local sprSkills = Sprite.load("toolbot_skills", "Actors/mult/skills", 7, 0, 0)
local sprSkillsLoadout = Sprite.load("toolbot_skills_loadout", "Actors/mult/skillsLoadout", 4, 0, 0)



-- Set the description of the character and the sprite used for skill icons
toolbot:setLoadoutInfo(
[[&y&MUL-T&!& is an aggressive survivor who has the tools necessary for any job! 
&y&Auto-Nailgun&!& has an &y&extremely high damage output&!&, but has a &r&short range&!&. 
&y&Transport Mode&!& can be both a great tool to &y&run down small groups of monsters&!&.
Constantly &y&Retooling&!& can help eliminate &b&fragile enemies&!& with &y&Rebar Puncher&!& while
keeping &b&damage output high&!& with &y&Auto-Nailgun&!&.]], sprSkillsLoadout)

-- Set the character select skill descriptions

toolbot:setLoadoutSkill(1, "Multifunctional",
[[MUL-T can hold &b&two use items&!& at once.
The active equiment is swapped by using &y&Retool&!&.]])

toolbot:setLoadoutSkill(2, "Auto-Nailgun",
[[Rapidly fire nails for &y&60% damage.&!& Fires &y&six&!& nails 
when initially pressed.]])

toolbot:setLoadoutSkill(3, "Blast Canister",
[[Launch a &y&stun&!& canister for &y&220% damage&!&. Drops 
&y&stun bomblets&!& for &y&5x44% damage&!&.]])

toolbot:setLoadoutSkill(4, "Transport Mode\n\n\nRetool",
[[Zoom forward, gaining &b&armor&!& and &b&speed&!&. Deals &y&250% damage&!& 
to enemies in the way. Deals more damage at higher speeds.

Switches his primary fire between the rapid &y&Auto-Nailgun&!& 
and the piercing heavy damage &y&Rebar Puncher&!&.]])

-- The color of the character's skill names in the character select
toolbot.loadoutColor = Color.fromRGB(200,100,0)

-- The character's sprite in the selection pod
toolbot.loadoutSprite = Sprite.load("toolbot_select", "Actors/mult/select", 16, 2, 0)
toolbot.loadoutWide = true

-- The character's walk animation on the title screen when selected
toolbot.titleSprite = sprites.walk1

-- Quote displayed when the game is beat as the character
toolbot.endingQuote = "..and so it left, aiming to find a new purpose."

registercallback("onPlayerStep", function(player)
	local playerA = player:getAccessor()
	if player:getSurvivor() == toolbot then
		if playerA.reTooled == 1 then
			player:setAnimation("idle", sprites.idle2)
			player:setAnimation("walk", sprites.walk2)
			player:setAnimation("jump", sprites.jump2)
			player:setAnimation("climb", sprites.climb2)
			player:setAnimation("death", sprites.death2)
		else
			player:setAnimation("idle", sprites.idle1)
			player:setAnimation("walk", sprites.walk1)
			player:setAnimation("jump", sprites.jump1)
			player:setAnimation("climb", sprites.climb1)
			player:setAnimation("death", sprites.death1)
		end
	end
end)

registercallback("onPlayerStep", function(player)
	if player:getSurvivor() == toolbot then
		if player:isValid() then
			local playerA = player:getAccessor()
			local data = player:getData()
			if player.useItem then
				if playerA.reTooled == 1 then
					if data.useItemSlot2 then
						data.useItemSlot2.item = player.useItem
						data.useItemSlot2.cooldown = player:getAlarm(0)
						if data.useItemSlot1.cooldown > -1 then
							data.useItemSlot1.cooldown = data.useItemSlot1.cooldown - 1
						end
					else
						data.useItemSlot2 = {item = nil, cooldown = 0}
					end
				else
					if data.useItemSlot1 then
						data.useItemSlot1.item = player.useItem
						data.useItemSlot1.cooldown = player:getAlarm(0)
						if data.useItemSlot2.cooldown > -1 then
							data.useItemSlot2.cooldown = data.useItemSlot2.cooldown - 1
						end
					else
						data.useItemSlot1 = {item = nil, cooldown = 0}
					end
				end
			end
		end
	end
end)

registercallback("onUseItemUse", function(player)
	if player:getSurvivor() == toolbot then
		if player:isValid() then
			local playerA = player:getAccessor()
			local data = player:getData()
			if player.useItem then
				if playerA.reTooled == 1 then
					data.useItemSlot2.cooldown = player:getAlarm(0)
				else
					data.useItemSlot1.cooldown = player:getAlarm(0)
				end
			end
		end
	end
end)

registercallback("onPlayerHUDDraw", function(player, hudx, hudy)
	if player:getSurvivor() == toolbot then
		if player:isValid() then
			local playerA = player:getAccessor()
			local data = player:getData()
			local dataSlot
			if playerA.reTooled == 1 then
				dataSlot = data.useItemSlot1
			else
				dataSlot = data.useItemSlot2
			end
			if dataSlot and dataSlot.item then
				if dataSlot.cooldown > -1 then
					graphics.drawImage{
						image = dataSlot.item.sprite,
						subimage = 2,
						x = hudx + 140, 
						y = hudy + 4,
						scale = 0.75,
						alpha = 0.25
						}
					graphics.print(math.round(dataSlot.cooldown/60), hudx + 140, hudy + 9, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
				else
					graphics.drawImage{
						image = dataSlot.item.sprite,
						subimage = 2,
						x = hudx + 140, 
						y = hudy + 4,
						alpha = 0.5
					}
				end
			end
		end
	end
end)

-- Called when the player is created
toolbot:addCallback("init", function(player)
	local playerA = player:getAccessor()
	local data = player:getData()
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(200, 11, 0.01)
	-- initializeVariables
	playerA.reTooled = 0
	playerA.bulletToFire = 1
	data.useItemSlot1 = {item = nil, cooldown = 0}
	data.useItemSlot2 = {item = nil, cooldown = 0}
	playerA.endingTransportMode = 0
	-- Set the player's skill icons
	player:setSkill(1,
		"Auto-Nailgun",
		"Rapidly fire nails for 60% damage. Fires six nails when initially pressed.",
		sprSkills, 1,
		30
	)
	player:setSkill(2,
		"Blast Canister",
		"Launch a stun canister for 220% damage. Drops stun bomblets for 5*44% damage.",
		sprSkills, 2,
		5 * 60
	)
	player:setSkill(3,
		"Transport Mode",
		"Zoom forward, gaining armor and speed. Deals 250% to enemies in the way. Deals more damage at higher speeds.",
		sprSkills, 3,
		5 * 60
	)
	player:setSkill(4,
		"Retool",
		"Toggle between Auto-Nailgun and Rebar Puncher.",
		sprSkills, 4,
		60
	)
end)

-- Called when the player levels up
toolbot:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(60, 6, 0.002, 5)
end)

-- Called when the player picks up the Ancient Scepter
toolbot:addCallback("scepter", function(player)
	player:setSkill(4,
		"Refurbish",
		"Toggle between Auto-Nailgun and Rebar Puncher. Boosts the damage of your next attack.",
		sprSkills, 6,
		60
	)
end)



-- Called when the player tries to use a skill
toolbot:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	local playerA = player:getAccessor()
	if playerA.activity == 0 then
		-- Set the player's state
		if skill == 1 then
			-- Z skill
			if playerA.reTooled == 1 then
				player:survivorActivityState(1, sprShoot1_2, 0.2, true, true)
			else
				player:survivorActivityState(1, sprShoot1_1, 0.5, true, true)
			end
		elseif skill == 2 then
			-- X skill
			if playerA.reTooled == 1 then
				player:survivorActivityState(2, sprShoot2_2, 0.25, true, true)
			else
				player:survivorActivityState(2, sprShoot2_1, 0.25, true, true)
			end
			
		elseif skill == 3 then
			-- C skill
			if player:hasBuff(transportMode) == false then
				if playerA.reTooled == 1 then
					player:survivorActivityState(3, sprShoot3_1_2, 0.25, true, true)
				else
					player:survivorActivityState(3, sprShoot3_1_1, 0.25, true, true)
				end
			else
				player:survivorActivityState(3, sprShoot3_2, 0.25, false, true)
			end
		elseif skill == 4 then
			-- V skill
			if playerA.reTooled == 1 then
				player:survivorActivityState(4, sprShoot4_2, 0.25, true, false)
			else
				player:survivorActivityState(4, sprShoot4_1, 0.25, true, false)
			end
		end
	end
end)

-- Called each frame the player is in a skill state
toolbot:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0
	local playerA = player:getAccessor()
	
	if skill == 1 then 
		-- Z skill
		if playerA.reTooled == 1 then
			--Rebar Puncher
			if relevantFrame == 1 then
				rebarChargeSound:play(player:get("attack_speed") + math.random() * 0.05)
			elseif relevantFrame == 6 then
				if not player:survivorFireHeavenCracker(1) then
					rebarFireSound:play(1 + math.random() * 0.05, 1.5)
					player:fireBullet(player.x, player.y, player:getFacingDirection(), 500, 4.5, rebarImpact, DAMAGER_BULLET_PIERCE)
				else
					rebarFireSound:play(1 + math.random() * 0.05, 1.5)
					player:fireBullet(player.x, player.y, player:getFacingDirection(), 500, 4.5, rebarImpact, DAMAGER_BULLET_PIERCE)
				end
				player:activateSkillCooldown(1)
				if player:hasBuff(refurbish) then
					player:removeBuff(refurbish)
				end
			end
		elseif playerA.reTooled == 0 then
			--Auto Nailgun
			if input.checkControl("ability1") == input.HELD or input.checkControl("ability1") == input.PRESSED  then
				if relevantFrame == 2 or relevantFrame == 4 then
					nailgunFireSound:play(1 + math.random() * 0.5)
					playerA.bulletToFire = (playerA.bulletToFire + 1) % 11
					if playerA.bulletToFire >= 4 then
						player:fireBullet(player.x, player.y, player:getFacingDirection() + math.random(-nailRotationOffset, nailRotationOffset), 300, 0.6, nailgunImpact)
					else
						player:fireBullet(player.x, player.y, player:getFacingDirection() + math.random(-nailRotationOffset, nailRotationOffset), 300, 0.6, nailgunImpact, DAMAGER_NO_PROC)
					end
				end
			else--if player:control("ability1") == input.NEUTRAL or player:control("ability1") == input.RELEASED  then
				playerA.activity = 0
				nailgunCooldownSound:play(1 + math.random() * 0.05)
				player:survivorActivityState(2, sprShoot1_1end, 0.15, false, true)
				if player:hasBuff(refurbish) then
					player:removeBuff(refurbish)
				end
				player:activateSkillCooldown(1)
				
			end
		end
		
		
	elseif skill == 2 then
		-- X skill: Blast Canister
		if relevantFrame == 1 then
			bombFireSound:play(0.8 + math.random() * 0.2, 2)
		elseif relevantFrame == 4 then
			local bombProjectile = Projectile.fire(stunBomb, player.x + 10 * player.xscale,player.y - 4 - 4,player)
			player:activateSkillCooldown(2)
			if player:hasBuff(refurbish) then
				player:removeBuff(refurbish)
			end
		end
		
		
		
		
	elseif skill == 3 then
		-- C skill: Transport Mode
		if not player:hasBuff(transportMode) then
			if playerA.endingTransportMode == 0 then
				if relevantFrame == 1 then
					transportEnterSound:play(1 + math.random() * 0.05)
					transportLoopSound:loop()
				elseif relevantFrame == 3 and not player:hasBuff(transportMode) then --begins transport mode
					enemiesHit = {},
					player:applyBuff(transportMode, transportTimeMax)
					local hitProjectile = Projectile.fire(transportModeImpact, player.x,player.y,player)
				end
			else
				if relevantFrame == 3 then --ends transport mode normally
					
					if transportLoopSound:isPlaying() then
						transportLoopSound:stop()
					end
					transportExitSound:play(1.3 + math.random() * 0.2)
					player:removeBuff(transportMode)
					playerA.endingTransportMode = 0
					if player:hasBuff(refurbish) then
						player:removeBuff(refurbish)
					end
				end
			end
		end
		
		
	elseif skill == 4 then
		-- V skill: Retool
		if relevantFrame == 1 then
			reToolSound:play(1)
		elseif relevantFrame == 3 then
			local data = player:getData()
			if playerA.reTooled == 1 then
				player.useItem = data.useItemSlot1.item
				player:setAlarm(0, data.useItemSlot1.cooldown or -1)
				player:setSkill(1,
				"Auto-Nailgun",
				"Rapidly fire nails for 60% damage. Fires six nails when initially pressed.",
				sprSkills, 1,
				30
				)
				playerA.reTooled = 0
			else
				player.useItem = data.useItemSlot2.item
				player:setAlarm(0, data.useItemSlot2.cooldown or -1)
				player:setSkill(1,
				"Rebar Puncher",
				"Long range precision attack for 450% damage.",
				sprSkills, 5,
				30
				)
				playerA.reTooled = 1
			end
			if playerA.scepter >= 1 then
				player:applyBuff(refurbish, 60*99999)
			end
		end
		player:activateSkillCooldown(4)
	end
end)

transportMode:addCallback("start", function(player)
	local playerA = player:getAccessor()
	playerA.armor = playerA.armor + 200
end)

transportMode:addCallback("step", function(player)
	local playerA = player:getAccessor()
	transportParticleFX:burst("above", player.x, player.y, 1)
	playerA.activity = 0
	player:survivorActivityState(3, sprShoot3_2, 0.15, true, false)
	if player:getFacingDirection() == 180 then
		playerA.pHspeed = -playerA.pHmax * transportSpeedMultiplier
	else
		playerA.pHspeed = playerA.pHmax * transportSpeedMultiplier
	end
end)

transportMode:addCallback("end", function(player)
	local playerA = player:getAccessor()
	playerA.endingTransportMode = 1
	playerA.activity = 0
	if playerA.reTooled == 1 then	
		player:survivorActivityState(3, sprShoot3_3_2, 0.15, true, false)
	else	
		player:survivorActivityState(3, sprShoot3_3_1, 0.15, true, false)
	end
	playerA.armor = playerA.armor - 200
	player:activateSkillCooldown(3)
end)

transportModeImpact:addCallback("step", function(projectileInstance)
	if projectileInstance:isValid() then
        projectileInstance.x = Projectile.getParent(projectileInstance).x
		projectileInstance.y = Projectile.getParent(projectileInstance).y
    end
end)

refurbish:addCallback("start", function(player)
	local playerA = player:getAccessor()
	playerA.originalDamageVal = playerA.damage
	playerA.damage = playerA.damage * 2
end)


refurbish:addCallback("end", function(player)
	local playerA = player:getAccessor()
	playerA.damage = playerA.originalDamageVal
end)

callback.register("onGameEnd", function()
	if transportLoopSound:isPlaying() then
		transportLoopSound:stop()
	end
end)

local verified = Achievement.new("Verified")
verified.requirement = 5
verified.deathReset = false
verified.description = "Complete the first Teleporter event five times."
verified.highscoreText = "\'MUL-T\' Unlocked"
verified:assignUnlockable(toolbot)

local teleporter = Object.find("Teleporter", "vanilla")
callback.register("onStep", function()
	for _, tpInst in ipairs(teleporter:findAll()) do
		if misc.director:get("stages_passed") <= 0 then	
			local data = misc.director:getData()
			if tpInst:get("time") == tpInst:get("maxtime") and not data.verify then
				verified:increment(1)
				data.verify = true
			end
		end
	end
end)

if modloader.checkFlag("ror2_debug") then
    if not verified:isComplete() then
        verified:increment(5)
    end
end