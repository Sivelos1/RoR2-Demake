--playerbots

local objects = {
    poi = Object.find("POI", "vanilla"),
    actors = ParentObject.find("actors", "vanilla")
}

local survivors = {
    commando = 1,
}

local sprites = {
    commando = {
    	idle = Sprite.find("GManIdle", "vanilla"),
    	walk = Sprite.find("GManWalk", "vanilla"),
	    jump = Sprite.find("GManJump", "vanilla"),
    	climb = Sprite.find("GManClimb", "vanilla"),
        death = Sprite.find("GManDeath", "vanilla"),
	    shoot1 = Sprite.find("GManShoot1", "vanilla"),
	    shoot2 = Sprite.find("GManShoot2", "vanilla"),
    	shoot3 = Sprite.find("GManShoot3", "vanilla"),
	    shoot4_1 = Sprite.find("GManShoot4_1", "vanilla"),
    	shoot4_2 = Sprite.find("GManShoot4_2", "vanilla"),
	    shoot5_1 = Sprite.find("GManShoot5_1", "vanilla"),
    	shoot5_2 = Sprite.find("GManShoot5_2", "vanilla"),
	    sparks1 = Sprite.find("Sparks1", "vanilla"),
	    sparks2 = Sprite.find("Sparks2", "vanilla")
    }
}

local sounds = {
    commando = {
	    bullet1 = Sound.find("bullet1", "vanilla"),
    	bullet2 = Sound.find("bullet2", "vanilla"),
	    bullet3 = Sound.find("bullet3", "vanilla"),
	    guardDeath = Sound.find("GuardDeath", "vanilla")
    }
}

local Bots = {
    commando = {},
}

local survivorFunctions = {
    [1] = { --Commando
        init = function(player)
            local data = player:getData()
            local self = player:getAccessor()
            self.name = "Commando"
            self.maxhp = 110 
            data.level = 1
            self.hp = self.maxhp
            self.damage = 12
            self.pHmax = 1.3
            player:setAnimations{
                idle = sprites.commando.idle,
                walk = sprites.commando.walk,
                jump = sprites.commando.jump,
                shoot1 = sprites.commando.shoot1,
                shoot2 = sprites.commando.shoot2,
                shoot3 = sprites.commando.shoot3,
                shoot4_1 = sprites.commando.shoot4_1,
                shoot4_2 = sprites.commando.shoot4_2,
                shoot5_1 = sprites.commando.shoot5_1,
                shoot5_2 = sprites.commando.shoot5_2,
                death = sprites.commando.death
            }
            player.mask = sprites.mask
            self.health_tier_threshold = 1
            self.knockback_cap = self.maxhp
            self.exp_worth = 0
            self.z_range = 700
            self.x_range = 700
            self.c_range = 700
            self.v_range = 700
            self.can_drop = 1
            self.can_jump = 1
        end,
        step = function(player)
            local data = player:getData()
            local self = player:getAccessor()
            if self.state == "chase" then
                if self.z_skill == 1 and player:getAlarm(2) <= -1 then
                    self.state = "attack1"
                    return
                end
            elseif self.state == "attack1" then --double tap
                if player:getAlarm(2) <= -1 then
                    if self.free ~= 1 then
                        self.pHspeed = 0
                    end
                    if player.sprite == player:getAnimation("shoot1") then
                        local frame = math.floor(player.subimage)
                        if data.lastSubimage ~= frame then
                            if frame >= player:getAnimation("shoot1").frames or self.state == "feared" or self.state ~= "attack1" or self.stunned > 0 then
                                self.activity = 0
                                self.activity_type = 0
                                player.spriteSpeed = 0.25
                                self.state = "idle"
                                player:setAlarm(2, (0.2*60))
                                self.activity_var1 = 0
                                self.activity_var2 = 0
                                return
                            end
                            if frame == 1 then
                                sounds.commando.bullet1:play(self.attack_speed + math.random() * 0.01)
                                player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 0.9, sprites.commando.sparks1)
                            elseif frame == 3 then
                                sounds.commando.bullet1:play(self.attack_speed + math.random() * 0.01)
                                player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 0.9, sprites.commando.sparks1)
                            end
                        end
                    else
                        data.lastSubimage = 0
                        player.subimage = 1
                        self.z_skill = 0
                        player.spriteSpeed = self.attack_speed * 0.20
                        self.activity = 2
                        self.activity_type = 1
                        player.sprite = player:getAnimation("shoot1")
                        return
                    end
                end
            elseif self.state == "attack2" then --fmj
                if player:getAlarm(3) <= -1 then
                    if self.free ~= 1 then
                        self.pHspeed = 0
                    end
                    if player.sprite == player:getAnimation("shoot2") then
                        local frame = math.floor(player.subimage)
                        if data.lastSubimage ~= frame then
                            if frame >= player:getAnimation("shoot2").frames or self.state == "feared" or self.state ~= "attack2" or self.stunned > 0 then
                                self.activity = 0
                                self.activity_type = 0
                                player.spriteSpeed = 0.25
                                self.state = "idle"
                                player:setAlarm(3, (3*60))
                                self.activity_var1 = 0
                                self.activity_var2 = 0
                                return
                            end
                        end
                    else
                        data.lastSubimage = 0
                        player.subimage = 1
                        self.x_skill = 0
                        player.spriteSpeed = self.attack_speed * 0.20
                        self.activity = 2
                        misc.shakeScreen(4)
                        sounds.commando.bullet2:play(1)
                        for i = 0, player:get("sp") do
                            local b = player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 1, sprites.commando.sparks2)
                            b:set("knockback", 6)
                            b:set("climb", i * 8)
                        end
                        self.activity_type = 1
                        player.sprite = player:getAnimation("shoot2")
                        return
                    end
                end

            elseif self.state == "attack3" then --ACTION ROLL
                if player:getAlarm(4) <= -1 then
                    if self.free ~= 1 then
                        self.pHspeed = 0
                    end
                    if player.sprite == player:getAnimation("shoot3") then
                        local frame = math.floor(player.subimage)
                        if data.lastSubimage ~= frame then
                            if frame >= player:getAnimation("shoot3").frames or self.state == "feared" or self.state ~= "attack3" or self.stunned > 0 then
                                self.activity = 0
                                self.invincible = 0
                                self.activity_type = 0
                                player.spriteSpeed = 0.25
                                self.state = "idle"
                                player:setAlarm(4, (4*60))
                                self.activity_var1 = 0
                                self.activity_var2 = 0
                                return
                            end
                            self.invincible = 5
                            self.pHspeed = self.pHmax * 2 * player.xscale
                        end
                    else
                        data.lastSubimage = 0
                        player.subimage = 1
                        self.c_skill = 0
                        player.spriteSpeed = 0.25
                        self.activity = 3
                        self.activity_type = 1
                        player.sprite = player:getAnimation("shoot3")
                        return
                    end
                end

            elseif self.state == "attack4" then --suppressive fire / barrage
                if player:getAlarm(5) <= -1 then
                    if self.free ~= 1 then
                        self.pHspeed = 0
                    end
                    if player.sprite == player:getAnimation("shoot4") then
                        local frame = math.floor(player.subimage)
                        if data.lastSubimage ~= frame then
                            if frame >= player:getAnimation("shoot4").frames or self.state == "feared" or self.state ~= "attack4" or self.stunned > 0 then
                                self.activity = 0
                                self.activity_type = 0
                                player.spriteSpeed = 0.25
                                self.state = "idle"
                                player:setAlarm(5, (5*60))
                                self.activity_var1 = 0
                                self.activity_var2 = 0
                                return
                            end
                            self.activity_var1 = (self.activity_var1 + 1) % 2
                            if (self.activity_var1 == 0 and (frame == 1 or frame == 5 or frame == 9 or (frame == 13 and self.scepter > 0) or (frame == 17 and self.scepter > 0))) or (self.activity_var1 == 1 and (frame == 3 or frame == 7 or frame == 9 or frame == 11 or (frame == 15 and self.scepter > 0) or (frame == 19 and self.scepter > 0))) then
                                for i = 0, self.sp do
                                    local b = nil
                                    if self.activity_var2 == 0 then --forward
                                        b = player:fireBullet(player.x, player.y, player:getFacingDirection(), 700, 1, sprites.commando.sparks1)
                                    elseif self.activity_var2 == 1 then --left/right
                                        b = player:fireBullet(player.x, player.y, player:getFacingDirection() + (180 * self.activity_var1), 700, 1, sprites.commando.sparks1)
                                    end
                                    b:set("stun", 0.5)
                                    b:set("climb", i*8)
                                    if self.scepter > 0 then
                                        sounds.commando.guardDeath:play(0.8 + (0.2 * math.random()), 0.25)
                                    else
                                        sounds.commando.bullet3:play(0.85 + (math.random() * 0.15))
                                    end
                                end
                                
                            end
                        end
                    else
                        data.lastSubimage = 0
                        player.subimage = 1
                        self.v_skill = 0
                        self.activity_var1 = 0
                        self.activity_var2 = 0
                        player.spriteSpeed = self.attack_speed * 0.3
                        if self.scepter > 0 then player.spriteSpeed = self.attack_speed * 0.4 end
                        self.activity = 4
                        sounds.commando.bullet2:play(1)
                        self.activity_type = 1
                        if self.scepter > 0 then
                            player:setAnimation("shoot4", player:getAnimation("shoot5_2"))
                        else
                            player:setAnimation("shoot4", player:getAnimation("shoot4_2"))
                        end
                        local scan = objects.actors:findAllLine(player.x, player.y, player.x + (300 * -player.xscale), player.y)
                        for _, inst in ipairs(scan) do
                            if inst and inst:isValid() then
                                if inst:get("team") ~= self.team and inst ~= player then
                                    if self.scepter > 0 then
                                        player:setAnimation("shoot4", player:getAnimation("shoot5_1"))
                                    else
                                        player:setAnimation("shoot4", player:getAnimation("shoot4_1"))
                                    end
                                    self.activity_var2 = 1
                                    break
                                end
                            end
                        end
                        player.sprite = player:getAnimation("shoot4")
                        return
                    end
                end
            end
            data.lastSubimage = math.floor(player.subimage)
        end,
        destroy = function(player)

        end,
        draw = function(player)

        end
    }
}

local BotStep = function(bot)
    local data = bot:getData()
    local self = bot:getAccessor()
    if self.team == "player" then
        if not data.poi or (data.poi and not data.poi:isValid()) then
            data.poi = objects.poi:create(bot.x, bot.y)
            data.poi:set("parent", bot.id)
        end
    elseif self.team == "enemy" then
        if data.poi and data.poi:isValid() then
            data.poi:destroy()
        end
    end
end

local playerbot = Object.base("EnemyClassic", "PlayerBot")
playerbot.sprite = sprites.commando.idle

playerbot:addCallback("create", function(player)
    local data = player:getData()
    local self = player:getAccessor()
    data.survivor = 1 --Commando
    data.lastSubimage = -1
    self.team = "player"
    data.poi = objects.poi:create(player.x, player.y)
    data.poi:set("parent", player.id)
    GlobalItem.initActor(player)
    if survivorFunctions[data.survivor] and survivorFunctions[data.survivor].init then
        survivorFunctions[data.survivor].init(player)
    end
end)

playerbot:addCallback("step", function(player)
    local data = player:getData()
    local self = player:getAccessor()
    BotStep(player)
    if survivorFunctions[data.survivor] and survivorFunctions[data.survivor].step then
        survivorFunctions[data.survivor].step(player)
    end
end)

playerbot:addCallback("destroy", function(player)
    local data = player:getData()
    local self = player:getAccessor()
    if survivorFunctions[data.survivor] and survivorFunctions[data.survivor].destroy then
        survivorFunctions[data.survivor].destroy(player)
    end
end)

playerbot:addCallback("draw", function(player)
    local data = player:getData()
    local self = player:getAccessor()
    if survivorFunctions[data.survivor] and survivorFunctions[data.survivor].draw then
        survivorFunctions[data.survivor].draw(player)
    end
end)

callback.register("onGameEnd", function()
    Bots = {}
end)