local sprites = {
    crosshair = Sprite.find("EfCrosshair", "vanilla"),
    shield = Sprite.find("EfShield", "vanilla"),
    reflector = Sprite.find("EfReflector", "vanilla"),
    reflectorCharge = Sprite.find("ReflectorCharge", "vanilla"),
    medkit = Sprite.find("MedkitBar", "vanilla"),
    wispSpark = Sprite.find("WispSpark", "vanilla")
}

local objects = {
    actors = ParentObject.find("actors", "vanilla"),
    mushroom = Object.find("EfMushroom", "vanilla"),
    impFriend = Object.find("ImpFriend", "vanilla"),
    jetpack = Object.find("EfJetpack", "vanilla"),
    fly = Object.find("EfFlies", "vanilla"),
    targeting = Object.find("EfTargeting", "vanilla"),
    thorns = Object.find("EfThorns", "vanilla"),
    laserBlast = Object.find("EfLaserBlast")
}

local sounds = {
    mushroom = Sound.find("EfMushroom", "vanilla"),
    use = Sound.find("Use", "vanilla"),
    bubbleShield = Sound.find("BubbleShield", "vanilla"),
    reflect = Sound.find("Reflect", "vanilla"),
    guardDeath = Sound.find("GuardDeath", "vanilla")
}

local particles ={
    heal = ParticleType.find("Heal", "vanilla"),
    spark = ParticleType.find("Spark", "vanilla"),
    smoke = ParticleType.find("Smoke", "vanilla"),
    dust2 = ParticleType.find("Dust2", "vanilla"),
    leaf = ParticleType.find("Leaf", "vanilla"),
    pixelDust = ParticleType.find("PixelDust", "vanilla"),
    radioactive = ParticleType.find("Radioactive", "vanilla"),
    speed = ParticleType.find("Speed", "vanilla")
}

------------------------------------------------------------

GlobalItem.items[Item.find("Hermit's Scarf", "vanilla")] = {
    apply = function(inst, count)
        inst:set("scarf", inst:get("scarf") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if math.random(100) < math.min(10 + (i.scarf - 1)*3, 25) and i.invincible < 2 then
                i.invincible = 1
                i.scarfed = 1
            else
                i.scarfed = 0
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("scarf", 0)
        else
            inst:set("scarf", inst:get("scarf") - 1)
        end
    end,
}

------------------------------------------------------------


GlobalItem.items[Item.find("Bustling Fungus", "vanilla")] = {
    apply = function(inst, count)
        inst:set("shroom_timer", 60)
        inst:set("mushroom", inst:get("mushroom") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if i.hp < i.lastHp then
                i.still_timer = 0
            end
            if i.pHspeed == 0 then
                i.still_timer = i.still_timer + 1
            else
                i.still_timer = 0
            end
            if i.mushroom > 0 and i.still_timer > 2*60 then
                if not inst:collidesWith(objects.mushroom, inst.x, inst.y) then
                    sounds.mushroom:play(0.8 + math.random() * 0.4)
                    local shroom = objects.mushroom:create(inst.x, inst.y + (inst.sprite.height/2) + 2)
                    shroom.depth = inst.depth - 1
                    shroom:set("value", math.ceil(i.maxhp *0.045) * i.mushroom)
                    shroom:set("parent", inst.id)
                    i.shroom_timer = 0 
                end
                if i.shroom_timer then
                    local shroom = objects.mushroom:findNearest(inst.x, inst.y)
                    if i.shroom_timer > -1 then
                        i.shroom_timer = i.shroom_timer - 1
                    else
                        i.hp = i.hp + shroom:get("value")
                        misc.damage(math.ceil(shroom:get("value")), shroom.x + 5, shroom.y -10, false, Color.DAMAGE_HEAL)
                        i.shroom_timer = 60
                    end
                else
                    i.shroom_timer = 0
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("mushroom", 0)
        else
            inst:set("mushroom", inst:get("mushroom") - count)
        end
    end,
}

------------------------------------------------------------

callback.register("onStep", function()
    for _, imp in ipairs(objects.impFriend:findAll()) do
        if imp and imp:isValid() then
            local parent = Object.findInstance(imp:get("parent"))
            if not parent then
                imp:destroy()
                return
            end
        end
    end
end)

GlobalItem.items[Item.find("Imp Overlord's Tentacle", "vanilla")] = {
    apply = function(inst, count)
        inst:set("tentacle", inst:get("tentacle") + count)
    end,
    step = function(inst, count)
        local i = inst:getAccessor()
        if i.tentacle > 0 then
            if i.tentacle_cd == 0 and not Object.findInstance(i.tentacle_id) and i.free == 0 then
                local friend = objects.impFriend:create(inst.x, inst.y)
                i.tentacle_id = friend.id
                friend:set("parent", inst.id)
            else
                if i.tentacle_cd > 0 then
                    i.tentacle_cd = i.tentacle_cd - 1
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("tentacle", 0)
        else
            inst:set("tentacle", inst:get("tentacle") - 1)
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Soldier's Syringe", "vanilla")] = {
    apply = function(inst, count)
        inst:set("attack_speed", math.clamp(inst:get("attack_speed") + (0.15 * count), 0, 2.8))
    end,
    step = function(inst, count)
        print("step")
    end,
    remove = function(inst, count, hardRemove)
        inst:set("attack_speed", math.clamp(inst:get("attack_speed") - (0.15 * count), 1, 2.8))
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = inst.sprite,
                x = inst.x,
                y = inst.y,
                subimage = inst.subimage,
                alpha = 0.75,
                xscale = inst.xscale + (math.random(-1, 1) * 0.2),
                yscale = inst.yscale + (math.random(-1, 1) * 0.2),
                color = Color.YELLOW,
            }
            if inst:get("head_active") then
                graphics.drawImage{
                    image = Sprite.fromID(inst:get("head_sprite")),
                    x = inst.x,
                    y = inst.y,
                    subimage = inst:get("head_subimage"),
                    alpha = 0.75,
                    xscale = inst:get("head_scale") + (math.random(-1, 1) * 0.2),
                    yscale = inst.yscale + (math.random(-1, 1) * 0.2),
                    color = Color.YELLOW,
                }
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Lens Maker's Glasses", "vanilla")] = {
    apply = function(inst, count)
        inst:set("critical_chance", inst:get("critical_chance") + (7 * count))
    end,
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("critical_chance", inst:get("critical_chance") - (7 * count))
        else
            inst:set("critical_chance", inst:get("critical_chance") - 7)
        end
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = sprites.crosshair,
                x = inst.x,
                y = inst.y - 7,
                subimage = 1,
            }
        end
    end
}

GlobalItem.items[Item.find("Harvester's Scythe", "vanilla")] = {
    apply = function(inst, count)
        inst:set("critical_chance", inst:get("critical_chance") + (5 * count))
        inst:set("scythe", inst:get("scythe") + (count))
    end,
    --[[hit = function(inst, count, damager, hit, x, y)
        if damager:get("critical") == 1 then
            local heal = (8 + (2 * (count - 1)))
            inst:set("hp", inst:get("hp") + heal)
            misc.damage(heal, inst.x, inst.y, false, Color.DAMAGE_HEAL)
        end
    end,]]
    remove = function(inst, count, hardRemove)
        if hardRemove then
            inst:set("critical_chance", inst:get("critical_chance") - (5 * count))
            inst:set("scythe", inst:get("scythe") - (count))
        else
            inst:set("critical_chance", inst:get("critical_chance") - 5)
            inst:set("scythe", inst:get("scythe") - 1)
        end
    end,
    draw = function(inst, count)
        if count > 0 then
            graphics.drawImage{
                image = sprites.crosshair,
                x = inst.x,
                y = inst.y - 7,
                subimage = 2,
            }
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Mysterious Vial", "vanilla")] = {
    apply = function(inst, count)
        inst:set("hp_regen", inst:get("hp_regen") + (0.014 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("hp_regen", inst:get("hp_regen") - (0.014 * count))
    end,
    draw = function(inst, count)
        local i = inst:getAccessor()
        if count > 0 then
            if (i.hp < i.maxhp and math.random(100) < 25) or (misc.getOption("video.quality") and math.random(100) < 5) then
                particles.heal:burst("below", inst.x, inst.y, 1)

            end
        end
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Crowbar", "vanilla")] = {
    apply = function(inst, count)
        inst:set("crowbar", inst:get("crowbar") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("crowbar", inst:get("crowbar") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Plasma Chain", "vanilla")] = {
    apply = function(inst, count)
        inst:set("plasma", inst:get("plasma") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("plasma", inst:get("plasma") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Meat Nugget", "vanilla")] = {
    apply = function(inst, count)
        inst:set("nugget", inst:get("nugget") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("nugget", inst:get("nugget") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Leeching Seed", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lifesteal", inst:get("lifesteal") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("lifesteal", inst:get("lifesteal") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") >= 3 and math.random(100) < 4 then
                particles.dust2:burst("above", inst.x, inst.y, 1, Color.RED)
            end
        end
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Ukulele", "vanilla")] = {
    apply = function(inst, count)
        inst:set("lightning", inst:get("lightning") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("lightning", inst:get("lightning") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") >= 3 and math.random(100) < 4 then
                particles.spark:burst("above", inst.x, inst.y, 1, Color.fromRGB(142,184,196))
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("The Ol' Lopper", "vanilla")] = {
    apply = function(inst, count)
        inst:set("axe", inst:get("axe") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("axe", inst:get("axe") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Hyper-Threader", "vanilla")] = {
    apply = function(inst, count)
        inst:set("blaster", inst:get("blaster") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("blaster", inst:get("blaster") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("Rusty Blade", "vanilla")] = {
    apply = function(inst, count)
        inst:set("bleed", inst:get("bleed") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("bleed", inst:get("bleed") - count)
    end,
}

------------------------------------------------------------

GlobalItem.items[Item.find("AtG Missile Mk. 1", "vanilla")] = {
    apply = function(inst, count)
        if inst:get("missile") <= 0 then
            local tt = objects.targeting:create(inst.x, inst.y)
            tt:getAccessor().image_blend = Color.fromRGB(92, 152, 78).gml
            tt:getAccessor().parent = inst.id
            tt:getAccessor().direction = 45
        end
        inst:set("missile", inst:get("missile") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("missile", inst:get("missile") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("AtG Missile Mk. 2", "vanilla")] = {
    apply = function(inst, count)
        
        if inst:get("missile_tri") <= 0 then
            local tt = objects.targeting:create(inst.x, inst.y)
            tt:getAccessor().image_blend = Color.ORANGE.gml
            tt:getAccessor().parent = inst.id
            tt:getAccessor().direction = 0
        end
        inst:set("missile_tri", inst:get("missile_tri") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("missile_tri", inst:get("missile_tri") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Ifrit's Horn", "vanilla")] = {
    apply = function(inst, count)
        inst:set("horn", inst:get("horn") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("horn", inst:get("horn") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Taser", "vanilla")] = {
    apply = function(inst, count)
        inst:set("taser", inst:get("taser") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("taser", inst:get("taser") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Thallium", "vanilla")] = {
    apply = function(inst, count)
        inst:set("thallium", inst:get("thallium") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("thallium", inst:get("thallium") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Sticky Bomb", "vanilla")] = {
    apply = function(inst, count)
        inst:set("sticky", inst:get("sticky") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("sticky", inst:get("sticky") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Shattering Justice", "vanilla")] = {
    apply = function(inst, count)
        inst:set("sunder", inst:get("sunder") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("sunder", inst:get("sunder") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Boxing Gloves", "vanilla")] = {
    apply = function(inst, count)
        inst:set("knockback", inst:get("knockback") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("knockback", inst:get("knockback") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Telescopic Sight", "vanilla")] = {
    apply = function(inst, count)
        inst:set("scope", inst:get("scope") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("scope", inst:get("scope") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Brilliant Behemoth", "vanilla")] = {
    apply = function(inst, count)
        inst:set("explosive_shot", inst:get("explosive_shot") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("explosive_shot", inst:get("explosive_shot") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Legendary Spark", "vanilla")] = {
    apply = function(inst, count)
        inst:set("spark", inst:get("spark") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("spark", inst:get("spark") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Wicked Ring", "vanilla")] = {
    apply = function(inst, count)
        inst:set("skull_ring", inst:get("skull_ring") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("skull_ring", inst:get("skull_ring") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Prison Shackles", "vanilla")] = {
    apply = function(inst, count)
        inst:set("slow_on_hit", inst:get("slow_on_hit") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("slow_on_hit", inst:get("slow_on_hit") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Permafrost", "vanilla")] = {
    apply = function(inst, count)
        inst:set("freeze", inst:get("freeze") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("freeze", inst:get("freeze") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local w = inst.sprite.width
            local h = inst.sprite.height
            local color = Color.WHITE
            if math.random() < 0.5 then
                color = Color.fromRGB(142,186,193)
            end
            if misc.getOption("video.quality") >= 2 and math.random(100) < 10 then
                particles.pixelDust:burst("above", inst.x - (w/2-math.random(w)) * math.random(1.7) * math.random(1.7),inst.y - (h/2-math.random(h)) * math.random(1.7) * math.random(1.7), 1, color)
            end
        end

    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Mortar Tube", "vanilla")] = {
    apply = function(inst, count)
        inst:set("mortar", inst:get("mortar") + count)
    end,
    remove = function(inst, count, hardRemove)
        inst:set("mortar", inst:get("mortar") - count)
    end,
}
------------------------------------------------------------

GlobalItem.items[Item.find("Alien Head", "vanilla")] = {
    apply = function(inst, count)
        inst:set("cdr", math.min(1 - (1-inst:get("cdr")) * (1-0.3), 0.6))
    end,
    remove = function(inst, count, hardRemove)
    end,
    draw = function(inst, count)
        if count > 0 then
            if misc.getOption("video.quality") > 2 and math.random(100) < 5 then
                local s = objects.fly:create(inst.x + math.random(-5,5), inst.y + math.random(-5,5))
                s:set("target", inst.id)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Rusty Jetpack", "vanilla")] = {
    apply = function(inst, count)
    end,
    remove = function(inst, count, hardRemove)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.free == 0 and i.activity ~= 30 and i.moveUp == 1 then
                local j = objects.jetpack:create(inst.x, inst.y)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Concussion Grenade", "vanilla")] = {
    apply = function(inst, count)
    end,
    remove = function(inst, count, hardRemove)
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 4 then
                particles.smoke:burst("below", inst.x + math.random(-10, 10), inst.y + math.random(-10, 10), 1)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Bitter Root", "vanilla")] = {
    apply = function(inst, count)
        inst:set("percent_hp", inst:get("percent_hp") + (0.08 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("percent_hp", inst:get("percent_hp") - (0.08 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 5 and misc.getOption("video.quality") >= 2 then
                particles.leaf:burst("below", inst.x, inst.y , 3)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Dead Man's Foot", "vanilla")] = {
    apply = function(inst, count)
        
    end,
    remove = function(inst, count, hardRemove)
        
    end,
    draw = function(inst, count)
        if count > 0 then
            if math.random(100) < 5 and misc.getOption("video.quality") >= 2 then
                particles.radioactive:burst("above", inst.x, inst.y , 3)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Paul's Goat Hoof", "vanilla")] = {
    apply = function(inst, count)
        inst:set("pHmax", inst:get("pHmax") + (0.08 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("pHmax", inst:get("pHmax") - (0.08 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.pHspeed ~= 0 and math.random(100) < 20 and misc.getOption("video.quality") >= 2 then
                particles.speed:burst("above", inst.x, inst.y + math.random(-5, 5), 1)
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("Guardian's Heart", "vanilla")] = {
    apply = function(inst, count)
        inst:set("maxshield", inst:get("maxshield") + (60 * count))
    end,
    remove = function(inst, count, hardRemove)
        inst:set("maxshield", inst:get("maxshield") - (60 * count))
    end,
    draw = function(inst, count)
        if count > 0 then
            if inst:get("shield") > 0 then
                graphics.drawImage{
                    image = sprites.shield,
                    x = inst.x + 11,
                    y = inst.y - 11,
                }
            end
        end
    end
}

------------------------------------------------------------

GlobalItem.items[Item.find("First Aid Kit", "vanilla")] = {
    apply = function(inst, count)
        inst:set("medkit", inst:get("medkit") + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            i.medkit_timer = math.min(14, i.medkit_timer + (0.15 + (i.medkit - 1) * 8.333/60))
            i.medkit_cd = math.max(0, i.medkit_cd - 1)
            if math.floor(i.medkit_timer) == 10 and i.medkit_cd <= 0 then
                sounds.use:play(0.7)
                i.hp = i.hp + (i.medkit * 10)
                misc.damage(i.medkit * 10, inst.x + 5, inst.y - 10, false, Color.DAMAGE_HEAL)
                i.medkit_cd = 30
            end
        end
    end,
    damage = function(inst, count, damage)
        if count > 0 then
            local i = inst:getAccessor()
            if i.medkit > 0 then
                i.medkit_timer = 0
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("medkit", inst:get("medkit") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.medkit_timer ~= 14 then
                graphics.drawImage{
                    image = sprites.medkit,
                    x = inst.x + 10,
                    y = inst.y - 10,
                    subimage = i.medkit_timer
                }
            end
        end
    end
}
------------------------------------------------------------

GlobalItem.items[Item.find("Repulsion Armor", "vanilla")] = {
    apply = function(inst, count)
        inst:set("reflector", inst:get("reflector") + count)
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.reflector > 0 then
                if i.reflecting > 0 then
                    i.reflecting = math.max(0, i.reflecting - 1)
                    local nearest = objects.actors:findNearest(inst.x, inst.y)
                    if i.reflecting_hit == 1 and (nearest and nearest:isValid() and nearest:get("team") ~= inst:get("team")) and Distance(inst.x, inst.y, nearest.x, nearest.y) < 200 then
                        sounds.reflect:play(0.9 + math.random() * 0.25)
                        local bullet = inst:fireBullet(inst.x, inst.y, GetAngleTowards(inst.x, inst.y, nearest.x, nearest.y), 4, sprites.wispSpark, nil)
                        bullet:set("laser", 3)
                        i.reflecting_hit = 0
                    end
                    if i.reflecting == 0 then
                        i.armor = i.armor - 1000
                        i.reflector_charge = 0
                    end
                end
            end
        end
    end,
    damage = function(inst, count, damage)
        local i = inst:getAccessor()
        if i.reflector > 0 then
            if i.reflecting == 0 then
                i.reflector_charge = i.reflector_charge + 1
                if i.reflector_charge >= 6 then
                    i.armor = i.armor + 1000
                    sounds.bubbleShield:play(2)
                    i.reflecting = math.min(60*4+(60*(i.reflector-1)),60*8)
                end
            else
                i.reflecting_hit = 1
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("reflector", inst:get("reflector") - count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            for charge = 0, 5 do
                local subimage = 1
                local angle = 90 + (360/6) * charge
                local xx = math.floor(math.cos(math.rad(angle)) * 20)
                local yy = math.floor(math.sin(math.rad(angle)) * 20)
                if charge < i.reflector_charge then
                    subimage = 2
                end
                graphics.drawImage{
                    image = sprites.reflectorCharge,
                    x = inst.x + xx,
                    y = inst.y + yy,
                    subimage = subimage,
                    alpha = 0.7
                }
            end
            if i.reflecting ~= 0 then
                graphics.drawImage{
                    image = sprites.reflector,
                    x = inst.x,
                    y = inst.y,
                    subimage = (misc.director:get("time_start") + misc.director:getAlarm(0)) / 20 + 10,
                    angle = (misc.director:get("time_start") + misc.director:getAlarm(0)) * 4,
                    alpha = 0.9
                }
            end
        end
    end
}


------------------------------------------------------------

GlobalItem.items[Item.find("Laser Turbine", "vanilla")] = {
    apply = function(inst, count)
        if not inst:get("laserturbine") then
            inst:set("laserturbine", count)
            inst:set("turbinecharge", 0)
        else
            inst:set("laserturbine", inst:get("laserturbine") + count)
        end
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.activity ~= 0 and i.activity ~= 30 and i.activity ~= 95 and i.activity ~= 99 then
                i.turbinecharge = math.min(i.turbinecharge + (i.laserturbine*0.13), 100)
                if i.turbinecharge >= 100 then
                    sounds.guardDeath:play(0.7 + math.random() * 0.8)
                    objects.laserBlast:create(inst.x, inst.y)
                    local explosion = inst:fireExplosion(inst.x, inst.y + 8, 1600/39, 64/9, 20, nil, nil, DAMAGER_NO_PROC+DAMAGER_NO_RECALC)
                    explosion:set("team", inst:get("team") .. "proc")
                    i.turbinecharge = 0
                end
            end
        end
    end,
    remove = function(inst, count, hardRemove)
        inst:set("laserturbine", inst:get("laserturbine") + count)
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            graphics.color(Color.fromGML(6710991))
            graphics.alpha(0.2)
            graphics.circle(inst.x, inst.y, (24 + math.random(3)) * i.turbinecharge/100, false)
            graphics.circle(inst.x, inst.y, (14 + math.random(2)) * i.turbinecharge/100, false)
            graphics.color(Color.fromGML(16777215))
            graphics.circle(inst.x, inst.y, (6 + math.random(1)) * i.turbinecharge/100, false)
            graphics.alpha(1)
        end
    end
}


------------------------------------------------------------

GlobalItem.items[Item.find("Sprouting Egg", "vanilla")] = {
    apply = function(inst, count)
        
    end,
    remove = function(inst, count, hardRemove)
        
    end,
    draw = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.shield_cooldown == 0 then
                if math.random(100) < 20 then
                    particles.heal:burst("below", inst.x + math.random(-10, 10), inst.y + math.random(-10, 10) , 1, Color.YELLOW)
                end
            end
        end
    end
}

------------------------------------------------------------

--[[GlobalItem.items[Item.find("Barbed Wire", "vanilla")] = {
    apply = function(inst, count)
        local i = inst:getAccessor()
        if i.thorns and Object.findInstance(i.thorns) then
            if i.thorns_coeff then
                i.thorns_coeff = i.thorns_coeff + (0.2 * (count-1))
            else
                i.thorns_coeff = 1 + ((count) * 0.2)
            end
        end
    end,
    step = function(inst, count)
        if count > 0 then
            local i = inst:getAccessor()
            if i.thorns then
                local thorns = Object.findInstance(i.thorns)
                if not thorns then
                    local t = objects.thorns:create(inst.x, inst.y)
                    t:set("parent", inst.id)
                    t:set("inactive", 0)
                    t:set("team", inst:get("team").."proc")
                    t:set("coeff", i.thorns_coeff)
                    i.thorns = t.id
                end
            else
                i.thorns = -1
            end

        end
    end,
    
    remove = function(inst, count)
        local i = inst:getAccessor()
        if i.thorns and Object.findInstance(i.thorns) then
            if i.thorns_coeff then
                if i.thorns_coeff > 1 then
                    i.thorns_coeff = i.thorns_coeff + (0.2 * count)
                else
                    local t = Object.findInstance(i.thorns)
                    if t then t:destroy() end
                    i.thorns = -1
                end
            end
        end
    end,
}]]