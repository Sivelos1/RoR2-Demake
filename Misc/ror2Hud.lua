
local ror2Hud = {}
ror2Hud.inst = nil

----------------------------------------------------------------------------------
                        -- CONSTANT VARIABLE DEFINITIONS --
----------------------------------------------------------------------------------
ror2Hud.localPlayer = {}

local screenW = 0
local screenH = 0
ror2Hud.sprites = {
    immune = Sprite.find("Immune", "vanilla"),
    allyIcon = Sprite.load("Graphics/UI/allies", 1, 8, 8),
    distortion = Sprite.find("MobSkills", "vanilla"),
    drizzle = Sprite.find("DifficultyDrizzle", "vanilla"),
    rainstorm = Sprite.find("DifficultyRainstorm", "vanilla"),
    monsoon = Sprite.find("DifficultyMonsoon", "vanilla"),
}

ror2Hud.currencyBoxW = 100
ror2Hud.currencyBoxX = 20
ror2Hud.currencyBoxY = 20
ror2Hud.currencies = {
    [1] = {name = "gold", color = Color.ROR_YELLOW, get = function(player)
        return misc.getGold()
    end},
    [2] = {name = "lunar", color = Color.PURPLE, get = function(player)
        return player:get("lunar_coins") or 0
    end},
}

ror2Hud.hpBoxW = 150
ror2Hud.hpBoxH = 20
ror2Hud.hpBoxX = 20
ror2Hud.hpBoxY = 0
ror2Hud.hpColors = {
    hp = Color.fromRGB(136, 211, 103),
    hurt = Color.fromRGB(255, 0, 0),
    infusion = Color.fromRGB(169, 63, 66),
    shield = Color.fromRGB(72, 183, 183),
    exp = Color.fromRGB(168, 223, 218),
    glass = Color.fromRGB(175, 116, 201),
    barrier = Color.fromRGB(221, 182, 47),
    immune = Color.fromRGB(226, 191, 139),
    invincible = Color.fromRGB(239, 191, 139)
}
ror2Hud.hpBarElements = {
    [1] = {
        [1] = {current = "hp", max = "maxhp", color = ror2Hud.hpColors.hp, contributeToCurrentHP = true, contributeToMaxHP = true},
        [2] = {current = "shield", max = "maxshield", color = ror2Hud.hpColors.shield, contributeToCurrentHP = true, contributeToMaxHP = false}
    },
    [2] = {
        [1] = {current = "barrier", max = "maxhp", color = ror2Hud.hpColors.barrier, contributeToCurrentHP = true, contributeToMaxHP = false}
    }
}

ror2Hud.skillsBoxW = 0
ror2Hud.skillsBoxH = 0
ror2Hud.skillsBoxX = 0
ror2Hud.skillsBoxY = 0
ror2Hud.skillIcons = {
    [Survivor.find("Commando", "vanilla")] = {
        image = Sprite.find("GManSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Huntress", "vanilla")] = {
        image = Sprite.find("Huntress1Skills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Bandit", "vanilla")] = {
        image = Sprite.find("CowboySkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Enforcer", "vanilla")] = {
        image = Sprite.find("RiotSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Engineer", "vanilla")] = {
        image = Sprite.find("EngiSkills2", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("HAN-D", "vanilla")] = {
        image = Sprite.find("JanitorSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Mercenary", "vanilla")] = {
        image = Sprite.find("SamuraiSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Miner", "vanilla")] = {
        image = Sprite.find("MinerSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Sniper", "vanilla")] = {
        image = Sprite.find("SniperSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Loader", "vanilla")] = {
        image = Sprite.find("ConsSkills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Acrid", "vanilla")] = {
        image = Sprite.find("Feral2Skills", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("CHEF", "vanilla")] = {
        image = Sprite.find("ChefSkills2", "vanilla"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("MUL-T", "RoR2Demake")] = {
        image = Sprite.find("toolbot_skills", "RoR2Demake"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("Artificer", "RoR2Demake")] = {
        image = Sprite.find("mage_skills", "RoR2Demake"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
    [Survivor.find("REX", "RoR2Demake")] = {
        image = Sprite.find("treebot_skills", "RoR2Demake"), 
        cooldownLimit = {
        [1] = 30,
        [2] = 0,
        [3] = 0,
        [4] = 0
        },
        subimages = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4
        },
        scepterSub = 5
    },
}

ror2Hud.difficultyBoxW = 150
ror2Hud.difficultyBoxH = 40
ror2Hud.difficultyBoxX = 300
ror2Hud.difficultyBoxY = 20
ror2Hud.sliderPointerSize = 3
ror2Hud.sliderChoke = 6
ror2Hud.difficulties = {
    [1] = {name = "Very Easy", color = Color.fromRGB(126,155,98)},
    [2] = {name = "Easy", color = Color.fromRGB(150,157,96)},
    [3] = {name = "Medium", color = Color.fromRGB(172,145,81)},
    [4] = {name = "Hard", color = Color.fromRGB(173,117,80)},
    [5] = {name = "Very Hard", color = Color.fromRGB(180,73,73)},
    [6] = {name = "Insane", color = Color.fromRGB(187,66,97)},
    [7] = {name = "Impossible", color = Color.fromRGB(113,66,109)},
    [8] = {name = "I SEE YOU", color = Color.fromRGB(78,70,108)},
    [9] = {name = "I'M COMING\nFOR YOU", color = Color.fromRGB(97,33,33)},
    [10] = {name = "HAHAHAHAHA", color = Color.fromRGB(50,0,0)},
}
ror2Hud.sliderOffset = 0

ror2Hud.itemBoxW = 100
ror2Hud.itemBoxH = 40
ror2Hud.itemBoxX = 125
ror2Hud.itemBoxY = 20

ror2Hud.bossHPW = 450
ror2Hud.bossHPH = 10
ror2Hud.bossHPX = 5
ror2Hud.bossHPY = 72
ror2Hud.boss = nil


---------------------------------------------------------------------------------

ror2Hud.surfaces = {}
-- Update UI non-static Values and Positions
callback.register("onGameStart", function()
    ror2Hud.sliderOffset = 0
end)

callback.register("onStep", function()
    screenW, screenH = graphics.getHUDResolution()
    
    ror2Hud.hpBoxY = screenH - (ror2Hud.hpBoxH + 20)

    ror2Hud.skillsBoxW = ror2Hud.sprites.allyIcon.width + 4 + ((22) * 4) + 34
    ror2Hud.skillsBoxH = 32 + (graphics.textHeight("Q", graphics.FONT_DEFAULT) + 2)
    ror2Hud.skillsBoxX = screenW - (ror2Hud.skillsBoxW + 40)
    ror2Hud.skillsBoxY = screenH - (ror2Hud.skillsBoxH + 15)

    
    ror2Hud.difficultyBoxX = screenW - (ror2Hud.skillsBoxW + 20)
    ror2Hud.sliderChoke = (ror2Hud.difficultyBoxH/12.5)

    ror2Hud.itemBoxW = (ror2Hud.difficultyBoxX - (ror2Hud.currencyBoxX + ror2Hud.currencyBoxW)) - 10

    ror2Hud.bossHPX = screenW / 2
end)


--local damageFont = graphics.fontFromSprite(Sprite.load("Graphics/font.png", 81, 0, 1), [[ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789/!”#¤%&()=?+-§@£$€{[]}\’*.,_<>^~¨ÜÏËŸ¿¡:;|]], -1, false)

ror2Hud.MouseHoveringOver = function(x1, y1, x2, y2)
    local result = false
    local mx, my = input.getMousePos(true)
    if (mx > x1 and mx < x2) and (my > y1 and my < y2) then
        result = true
    end
    return result
end

ror2Hud.CreateBasicBox = function(w, h)
    local surface = Surface.new(w, h)
    local ww = w - 1
    local hh = h -1
    graphics.setTarget(surface)
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(0, 0, w, h, false)
    graphics.color(Color.WHITE)
    graphics.rectangle(0, 0, ww, hh, true)

    --Corners--
    -- Top-left
    graphics.pixel(0, 0)
    graphics.pixel(1, 0)
    graphics.pixel(0, 1)
    -- Top-right
    graphics.pixel(ww, 0)
    graphics.pixel(ww, 1)
    graphics.pixel(ww-1, 0)
    -- Bottom-left
    graphics.pixel(0, hh)
    graphics.pixel(0, hh-1)
    graphics.pixel(1, hh)
    -- Bottom-right
    graphics.pixel(ww, hh)
    graphics.pixel(ww, hh-1)
    graphics.pixel(ww-1, hh)
    -----------
    table.insert(ror2Hud.surfaces, surface)
    graphics.resetTarget()
    graphics.alpha(1)
    return surface
end

ror2Hud.CreateCurrencyBox = function()
    local cH = graphics.textHeight("$", graphics.FONT_DAMAGE) + 2
    local i = 0
    for _, currency in ipairs(ror2Hud.currencies) do
        i = i + 1
    end
    local h = (2 + (i)) + (cH * (i)) + 1
    local w = ror2Hud.currencyBoxW
    local bg = ror2Hud.CreateBasicBox(w, h)
    graphics.setTarget(bg)
    -----------------------
    i = 0
    for _, currency in ipairs(ror2Hud.currencies) do
        local tempSurface = Surface.new(w - 4, cH)
        graphics.setTarget(tempSurface)
        graphics.color(Color.BLACK)
        for x = 0, w-4 do
            graphics.alpha(x/(w-4))
            graphics.rectangle(x, 0, x, cH)
        end
        graphics.alpha(1)
        graphics.color(currency.color)
        graphics.print("$", 1, cH/2, graphics.FONT_DAMAGE, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
        graphics.setTarget(bg)
        tempSurface:draw(2, (2 + (i)) + (cH * (i)))
        i = i + 1
    end
    -----------------------
    table.insert(ror2Hud.surfaces, bg)
    graphics.resetTarget()
    graphics.alpha(1)
    return bg
end

ror2Hud.DrawCurrencyBox = function(player)
    if ror2Hud.surfaces.currencyBox then --Draw Currency Box
        if not ror2Hud.surfaces.currencyBox:isValid() then
            ror2Hud.surfaces.currencyBox = ror2Hud.CreateCurrencyBox()
        end
        ror2Hud.surfaces.currencyBox:draw(ror2Hud.currencyBoxX, ror2Hud.currencyBoxY)
        local i = 0
        for _, currency in ipairs(ror2Hud.currencies) do
            graphics.color(Color.WHITE)
            graphics.alpha(1)
            local x = ror2Hud.currencyBoxX + (ror2Hud.currencyBoxW - 2)
            local y= ror2Hud.currencyBoxY + ((2 + (i)) + ((graphics.textHeight("$", graphics.FONT_DAMAGE) + 2) * (i)) + 1)
            graphics.print(tostring(math.round(currency.get(player))), x, y, graphics.FONT_DAMAGE, graphics.ALIGN_RIGHT, graphics.ALIGN_TOP)
            i = i + 1
        end
    else
        ror2Hud.surfaces.currencyBox = ror2Hud.CreateCurrencyBox()
    end
end

ror2Hud.CreateHPBox = function()
    local w = ror2Hud.hpBoxW
    local h = ror2Hud.hpBoxH
    local bg = ror2Hud.CreateBasicBox(w, h)
    graphics.setTarget(bg)
    ----------------------
    -- Draw HP background
    local hpW = w - 4
    local hpH = ((h / 2))
    local hpX = 2
    local hpY = (h/2)
    for x = 0, hpW - 1 do
        graphics.alpha(math.sin((math.pi/hpW)*x))
        graphics.color(Color.BLACK)
        graphics.rectangle(hpX + x, hpY, hpX + x, hpY + (hpH - 3))
    end
    
    -- Draw EXP background
    local expW = (2*(w/3)) - 4
    local expH = (h - hpH) - 3
    local expX = (w / 3)
    local expY = 2
    graphics.rectangle(expX, expY, expX + (expW + 1), expY + (expH - 1))
    graphics.resetTarget()
    table.insert(ror2Hud.surfaces, bg)
    graphics.resetTarget()
    graphics.alpha(1)
    ----------------------
    return bg
end

ror2Hud.DrawHPBox = function(player)
    if ror2Hud.surfaces.hpBox then --Draw HP Box
        if not ror2Hud.surfaces.hpBox:isValid() then
            ror2Hud.surfaces.hpBox = ror2Hud.CreateHPBox()
        end
        ror2Hud.surfaces.hpBox:draw(ror2Hud.hpBoxX, ror2Hud.hpBoxY)
        --Draw Level
        local levelX = ror2Hud.hpBoxX + ((ror2Hud.hpBoxW / 3) / 2)
        local levelY = ror2Hud.hpBoxY + (ror2Hud.hpBoxH / 4)
        graphics.color(Color.WHITE)
        graphics.print("Lv: "..tostring(player:get("level")), levelX, levelY, graphics.FONT_SMALL, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        --Draw EXP
        local expX = ror2Hud.hpBoxX+(ror2Hud.hpBoxW / 3)
        local expY = ror2Hud.hpBoxY+2
        local expW = ((2*(ror2Hud.hpBoxW/3)) - 4) * math.clamp((player:get("expr")/player:get("maxexp")), 0, 1)
        graphics.color(ror2Hud.hpColors.exp)
        graphics.rectangle(expX, expY, expX + expW, expY + ((ror2Hud.hpBoxH/2) - 4))
        --Draw hp
        local hpX = ror2Hud.hpBoxX + 2
        local hpY = ror2Hud.hpBoxY + (ror2Hud.hpBoxH / 2)
        local hpW = (ror2Hud.hpBoxW - 5)
        local hpH = (ror2Hud.hpBoxH / 2) - 3
        --Calculate shit
        local maxHP = 0
        local currentHP = 0
        for _, layer in ipairs(ror2Hud.hpBarElements) do
            local currentTotal = 0
            local maxTotal = 0
            local currentX = 0
            --Get currents and maxes for each stat
            for _, stat in ipairs(layer) do
                currentTotal = currentTotal + (player:get(stat.current) or 0)
                maxTotal = maxTotal + (player:get(stat.max) or 0)
                if stat.contributeToCurrentHP then
                    currentHP = currentHP + player:get(stat.current) --If stat contributes to current HP, add it to current HP text value
                end
                if stat.contributeToMaxHP then
                    maxHP = maxHP + player:get(stat.max) --If stat contributes to max HP, add it to max HP text value
                end
            end
            local length = 0
            for _, stat in ipairs(layer) do
                if player:get(stat.current) > 0 then
                    length = (player:get(stat.current) / maxTotal) * (hpW * math.clamp(player:get("percent_hp"), 0, 1))
                    if stat.current == "hp" then
                        if Artifact.find("Glass", "vanilla") and Artifact.find("Glass", "vanilla").active then
                            graphics.color(ror2Hud.hpColors.glass)
                        else
                            graphics.color(ror2Hud.hpColors.hp)
                        end
                        if player:countItem(Item.find("Infusion", "vanilla")) > 0 then
                            graphics.color(ror2Hud.hpColors.infusion)
                        end
                    else
                        graphics.color(stat.color)
                    end
                    graphics.alpha(1)
                    graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                    currentX = currentX + length
                end
            end
            if length > 0 then
                --Draw shine
                graphics.color(Color.WHITE)
                graphics.alpha(0.25)
                graphics.line(hpX + 1, hpY+1, hpX + 2 + length, hpY+1, 1)
                graphics.color(Color.BLACK)
                graphics.line(hpX + 1, hpY+hpH+1, hpX + 2 + length, hpY+hpH+1, 1)
            end
            if player:get("percent_hp") < 1 then --Draw Curse (if percent_hp is less than one, draw something to fill empty part of HP bar)
                graphics.color(Color.WHITE)
                graphics.alpha(0.5)
                local curseW = hpW - (hpW * math.clamp(player:get("percent_hp"), 0, 1))
                local curseX = hpX + (hpW * math.clamp(player:get("percent_hp"), 0, 1))
                graphics.rectangle(curseX, hpY, curseX + curseW, hpY + hpH, true)
            end
            
        end
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        if player:get("invincible") > 0 and player:get("scarfed") == 0 then --Invincibility handler
            local subimage = 1
            graphics.color(ror2Hud.hpColors.immune)
            if player:get("invincible") > 1000 then
                subimage = 2    
                graphics.color(ror2Hud.hpColors.invincible)
            end
            graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
            graphics.drawImage{
                image = ror2Hud.sprites.immune,
                subimage = subimage,
                x = hpX + (hpW/2),
                y = hpY + (hpH/2) + 0.5
            }
        else
            --Draw Text
            graphics.print(math.ceil(currentHP).."/"..maxHP, hpX + (hpW/2), hpY + (hpH/2) + 0.5, graphics.FONT_DAMAGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        end
    else
        ror2Hud.surfaces.hpBox = ror2Hud.CreateHPBox()
    end
end

ror2Hud.CreateSkillIconBox = function(w, h)
    local surface = Surface.new(w + 3, h + 3)
    graphics.setTarget(surface)
    graphics.color(Color.BLACK)
    graphics.alpha(0.75)
    graphics.rectangle(0, 0, w, h, false)
    -------------------------
    table.insert(ror2Hud.surfaces, surface)
    graphics.resetTarget()
    graphics.alpha(1)
    return surface
end

ror2Hud.CreateSkillsHud = function()
    local skillW = ror2Hud.sprites.allyIcon.width + 4 + ((22) * 4) + 34
    local skillH = 32 + (graphics.textHeight("Q", graphics.FONT_DEFAULT) + 2)
    local skillBG = Surface.new(skillW, skillH)
    graphics.setTarget(skillBG)
    if net.online then
        graphics.drawImage{
            image = ror2Hud.sprites.allyIcon,
            x = ror2Hud.sprites.allyIcon.width/2,
            y = skillH/2,
        }
    end
    for i=0, 3 do
        local skillBox = ror2Hud.CreateSkillIconBox(17, 17)
        graphics.setTarget(skillBG)
        graphics.alpha(1)
        skillBox:draw((ror2Hud.sprites.allyIcon.width + 4) + ((22) * i), 14)
    end
    local useBox = ror2Hud.CreateSkillIconBox(32, 32)
    graphics.setTarget(skillBG)
    useBox:draw(skillW - 34, 0)
    -----------------------
    table.insert(ror2Hud.surfaces, skillBG)
    graphics.resetTarget()
    graphics.alpha(1)
    return skillBG
end

ror2Hud.DrawSkillsHud = function(player)
    if ror2Hud.surfaces.skillsHud then --Draw skills
        if not ror2Hud.surfaces.skillsHud:isValid() then
            ror2Hud.surfaces.skillsHud = ror2Hud.CreateSkillsHud()
        end
        graphics.resetTarget()
        graphics.alpha(1)
        ror2Hud.surfaces.skillsHud:draw(ror2Hud.skillsBoxX, ror2Hud.skillsBoxY)
        -- Draw Ally Icon Thing
        if net.online then
            local allyX = ror2Hud.skillsBoxX + (ror2Hud.sprites.allyIcon.width/2)
            local allyY = ror2Hud.skillsBoxY + (32 + (graphics.textHeight("Q", graphics.FONT_DEFAULT) + 2)) - (ror2Hud.sprites.allyIcon.height/3)
            graphics.alpha(0.25)
            graphics.color(Color.BLACK)
            graphics.rectangle(allyX - ((graphics.textWidth("Tab", graphics.FONT_SMALL)/2) + 1), allyY - ((graphics.textHeight("Tab", graphics.FONT_SMALL)/2) + 1), allyX + ((graphics.textWidth("Tab", graphics.FONT_SMALL)/2)), allyY + ((graphics.textHeight("Tab", graphics.FONT_SMALL)/2) - 2))
            graphics.alpha(1)
            graphics.color(Color.WHITE)
            graphics.print("Tab", allyX, allyY, graphics.FONT_SMALL, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        end
        for i = 1, 4 do --Draw Ability Stuff
            -- Ability Control Strings
            local tempX = ror2Hud.skillsBoxX + (ror2Hud.sprites.allyIcon.width + 4) + ((22) * i) - 5.5 - (graphics.textWidth("Z", graphics.FONT_DEFAULT))
            local tempY = ror2Hud.skillsBoxY + (14 + 22)
            graphics.color(Color.BLACK)
            graphics.alpha(0.25)
            graphics.rectangle(tempX - ((graphics.textWidth("Z", graphics.FONT_DEFAULT)/2) + 1), tempY, tempX + (graphics.textWidth("Z", graphics.FONT_DEFAULT)/2), tempY + (graphics.textHeight("Z", graphics.FONT_DEFAULT)/2) + 2)
            graphics.color(Color.WHITE)
            graphics.alpha(1)
            graphics.print(input.getControlString("ability"..i), tempX, tempY, graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)

            -- Ability Icons
            tempX = ror2Hud.skillsBoxX + (ror2Hud.sprites.allyIcon.width + 4) + ((22) * (i-1)) - 1
            tempY = ror2Hud.skillsBoxY + (13)
            local survivor = player:getSurvivor()
            if ror2Hud.MouseHoveringOver(tempX, tempY, tempX + 22, tempY + 22) then
                ror2Hud.DrawSkillInfo(player, i)
            end
            if Artifact.find("Distortion", "vanilla") and Artifact.find("Distortion", "vanilla").active and player:get("artifact_lock_choice") == i-1 then
                graphics.alpha(0.5)
                graphics.color(Color.WHITE)
                graphics.rectangle(tempX, tempY, tempX + 19, tempY + 19, true)
                graphics.drawImage{
                    image = ror2Hud.sprites.distortion,
                    subimage = 1,
                    x = tempX + 1,
                    y = tempY + 1,
                    alpha = 1
                }
            else
                if ror2Hud.skillIcons[survivor] then
                    local subimage = ror2Hud.skillIcons[survivor].subimages[i]
                    if player:get("scepter") > 1 then
                        subimage = ror2Hud.skillIcons[survivor].scepterSub
                    end
                    local skillAlpha = 0.5
                    if player:getAlarm(i+1) <= ror2Hud.skillIcons[survivor].cooldownLimit[i] then
                        skillAlpha = 1
                    end
                    graphics.drawImage{
                        image = ror2Hud.skillIcons[survivor].image,
                        subimage = subimage,
                        x = tempX + 1,
                        y = tempY + 1,
                        alpha = skillAlpha
                    }
                    if player:getAlarm(i+1) > ror2Hud.skillIcons[survivor].cooldownLimit[i] then
                        graphics.alpha(1)
                        local cooldown = math.round(player:getAlarm(i+1)/60)
                        graphics.color(Color.WHITE)
                        graphics.print(tostring(cooldown), tempX + 12, tempY + 12.5, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
                    else
                        graphics.alpha(0.5)
                        graphics.color(Color.WHITE)
                        graphics.rectangle(tempX, tempY, tempX + 19, tempY + 19, true)
                    end 
                end
            end
        end
        --Use Item Stuff
        local tempX = ror2Hud.skillsBoxX + (ror2Hud.skillsBoxW - 17)
        local tempY = ror2Hud.skillsBoxY + 17
        graphics.color(Color.BLACK)
        graphics.alpha(0.25)
        local tempX2 = tempX + 1
        local tempY2 = tempY + 25
        graphics.rectangle(tempX2 - ((graphics.textWidth(input.getControlString("use"), graphics.FONT_DEFAULT)) - 1), tempY2 - ((graphics.textHeight(input.getControlString("use"), graphics.FONT_DEFAULT) / 2)), tempX2 + ((graphics.textWidth(input.getControlString("use"), graphics.FONT_DEFAULT) / 2) - 3), tempY2 + ((graphics.textHeight(input.getControlString("use"), graphics.FONT_DEFAULT) / 2) - 4), false)
        graphics.color(Color.WHITE)
        graphics.alpha(1)
        graphics.print(input.getControlString("use"), tempX2, tempY2, graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        
        local itemAlpha = 0.5
        if player:getAlarm(0) <= -1 then
            itemAlpha = 1
            graphics.alpha(0.5)
            graphics.color(Color.WHITE)
            graphics.rectangle(tempX-18, tempY-18, tempX+16, tempY+16, true)
        end
        if player.useItem then
            graphics.drawImage{
                image = player.useItem.sprite,
                subimage = 2,
                x = tempX,
                y = tempY,
                alpha = itemAlpha
            }
        end
        if player:getAlarm(0) > -1 then
            graphics.alpha(1)
            local cooldown = math.round(player:getAlarm(0)/60)
            graphics.print(tostring(cooldown), tempX, tempY, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        end

        
    else
        ror2Hud.surfaces.skillsHud = ror2Hud.CreateSkillsHud()
    end
end

ror2Hud.DrawSkillInfo = function(player, index)
    graphics.resetTarget()
    graphics.alpha(1)
    local skillName = "Double Tap"
    local skillDesc = "Shoot twice for 2x60% damage."
    local cooldown = 0
    local skillDescFormatted = {}
    local line = 0
    for i = 0, string.len(skillDesc) do
        if i % graphics.textWidth(skillName, graphics.FONT_LARGE) == 0 then
            skillDescFormatted[line] = string.sub(skillDesc, i, i+graphics.textWidth(skillName, graphics.FONT_LARGE))
            line = line + 1
        end
    end
    graphics.color(Color.ROR_YELLOW)
    graphics.print(skillName, ror2Hud.skillsBoxX + ror2Hud.skillsBoxW, ror2Hud.skillsBoxY - (graphics.textHeight(skillName, graphics.FONT_LARGE) * 3), graphics.FONT_LARGE, graphics.ALIGN_RIGHT, graphics.ALIGN_CENTER)
    graphics.color(Color.GREY)
    for i = 0, line do
        if skillDescFormatted[i] then
            graphics.print(skillDescFormatted[i], (ror2Hud.skillsBoxX + ror2Hud.skillsBoxW) - (graphics.textWidth(skillName, graphics.FONT_LARGE)), (ror2Hud.skillsBoxY - (graphics.textHeight(skillName, graphics.FONT_DEFAULT) * 2)) + (graphics.textHeight(skillDesc, graphics.FONT_DEFAULT) * i), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
        end 
    end
    graphics.print(cooldown.." second cooldown", ror2Hud.skillsBoxX + ror2Hud.skillsBoxW, ror2Hud.skillsBoxY - (graphics.textHeight(cooldown.." second cooldown", graphics.FONT_DEFAULT) * 3), graphics.FONT_DEFAULT, graphics.ALIGN_RIGHT, graphics.ALIGN_CENTER)
    
end

ror2Hud.CreateDifficultySlider = function()
    local sliderH = (ror2Hud.difficultyBoxH / 2) - (ror2Hud.sliderChoke+2)
    local count = 0
    for _, difficulty in pairs(ror2Hud.difficulties) do
        count = count + 1
    end
    local sliderW = (sliderH * 3) * (2*count)
    local slider = Surface.new(sliderW, sliderH)
    graphics.setTarget(slider)
    count = 0
    local sliderX = 0
    for x=1, 10 do
        if x < 10 then
            for i = 1, 3 do
                graphics.alpha(1)
                graphics.color(ror2Hud.difficulties[x].color)
                graphics.rectangle(sliderX, 0, sliderX + sliderH, sliderH)
                graphics.alpha(0.25)
                graphics.color(Color.WHITE)
                graphics.line(sliderX + 1, 1, sliderX + sliderH, 1)
                graphics.color(Color.BLACK)
                graphics.line(sliderX+1, 1, sliderX+1, sliderH)
                graphics.line(sliderX, sliderH, sliderX + sliderW, sliderH)
                sliderX = sliderX + sliderH
            end
            graphics.alpha(1)
            graphics.color(Color.WHITE)
            graphics.print(ror2Hud.difficulties[x].name, sliderX - ((sliderH*3)/2), sliderH/2, graphics.FONT_SMALL, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
            count = count + 1
        else
            
            graphics.color(ror2Hud.difficulties[10].color)
            graphics.alpha(1)
            graphics.rectangle(sliderX, 0, sliderW, sliderH)
            for z = 0,(sliderW - sliderX) do
                if z%sliderH == 0 then
                    graphics.alpha(0.25)
                    graphics.color(Color.WHITE)
                    graphics.line((sliderX+1)+z, 1, (sliderX+z)+sliderH, 1)
                    graphics.color(Color.BLACK)
                    graphics.line((sliderX+1)+z, 1, (sliderX+1)+z, sliderH)
                    graphics.line(sliderX+z, sliderH, (sliderX+z) + sliderW, sliderH)
                end
            end
            for y = 0, (sliderW-sliderX) do
                if y%(graphics.textWidth(ror2Hud.difficulties[10].name, graphics.FONT_SMALL)) == 0 then
                    graphics.alpha(1)
                    graphics.color(Color.WHITE)
                    graphics.print(ror2Hud.difficulties[10].name, (sliderX + 1)+(y), sliderH/2, graphics.FONT_SMALL, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
                end
            end
        end        
    end
    table.insert(ror2Hud.surfaces, slider)
    graphics.resetTarget()
    graphics.alpha(1)
    return slider
end

ror2Hud.CreateDifficultyBox = function()
    if ror2Hud.surfaces.slider == nil or not ror2Hud.surfaces.slider:isValid() then
        ror2Hud.surfaces.slider = ror2Hud.CreateDifficultySlider()
    end
    local bg = ror2Hud.CreateBasicBox(ror2Hud.difficultyBoxW, ror2Hud.difficultyBoxH)
    graphics.setTarget(bg)
    --Draw slider background
    graphics.alpha(1)
    graphics.color(Color.BLACK)
    local sliderY = (ror2Hud.difficultyBoxH/2)+1+ror2Hud.sliderChoke
    local sliderH = (ror2Hud.difficultyBoxH / 2) - (ror2Hud.sliderChoke+4)
    local sliderW = (ror2Hud.difficultyBoxW-(ror2Hud.sliderChoke+2))
    graphics.rectangle((ror2Hud.sliderChoke-1), sliderY, (ror2Hud.sliderChoke-1)+sliderW, sliderY + (sliderH))

    --Draw Timer Background
    local timerX = (ror2Hud.difficultyBoxW/2)
    local timerY = 1
    local timerW = (ror2Hud.difficultyBoxW/2) - 2
    local timerH = (ror2Hud.difficultyBoxH/2) - 2

    graphics.alpha(0.8)
    graphics.color(Color.BLACK)
    graphics.rectangle(timerX, timerY, timerX + (timerW - (timerW/8)), timerY + timerH)
    graphics.rectangle(timerX + 1 +(timerW - (timerW/8)), timerY + (timerH/3), timerX + (timerW - (timerW/8)) + (timerW/8), timerY + (timerH/3) + (timerH - (timerH/3)))
    graphics.triangle(timerX + (timerW - (timerW/8)), timerY-1, timerX + (timerW - (timerW/8)), timerY + (timerH/3) - 1, timerX + (timerW - (timerW/8)) + (timerW/8), timerY + (timerH/3) - 1, false)

    -----------------------
    table.insert(ror2Hud.surfaces, bg)
    graphics.resetTarget()
    return bg
end

ror2Hud.DrawDifficultyBox = function()
    if ror2Hud.surfaces.difficultyHud then --Draw difficulty
        if not ror2Hud.surfaces.difficultyHud:isValid() then
            ror2Hud.surfaces.difficultyHud = ror2Hud.CreateDifficultyBox()
        end
        graphics.resetTarget()
        graphics.alpha(1)
        ror2Hud.surfaces.difficultyHud:draw(ror2Hud.difficultyBoxX, ror2Hud.difficultyBoxY)
        -- Draw Timer
        local timerX = ror2Hud.difficultyBoxX + (ror2Hud.difficultyBoxW - (ror2Hud.difficultyBoxW/5))
        local timerY = ror2Hud.difficultyBoxY + (ror2Hud.difficultyBoxH/4) + 1
        local timerW = (ror2Hud.difficultyBoxW/2) - 2
        local timerH = (ror2Hud.difficultyBoxH/2) - 2
        graphics.alpha(1)
        graphics.color(Color.WHITE)
        local m, s = misc.getTime()
        graphics.print(":", timerX, timerY, graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        --..":"..string.format("%02.f", math.floor(s - m *60))
        graphics.print(string.format("%02.f", m), timerX - graphics.textWidth(":", graphics.FONT_DEFAULT), timerY + 1, graphics.FONT_LARGE, graphics.ALIGN_RIGHT, graphics.ALIGN_CENTER)
        
        graphics.print(string.format("%02.f", s), timerX + graphics.textWidth(":", graphics.FONT_DEFAULT), timerY + 1, graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)

        --Draw Difficulty Icon
        local difficulty = Difficulty.getActive()
        local iconW = difficulty.icon.width
        local iconX = ror2Hud.difficultyBoxX + ((ror2Hud.difficultyBoxW)/2) - (iconW/1.25)
        local iconY = ror2Hud.difficultyBoxY + (difficulty.icon.height / 1.75)
        graphics.drawImage{
            image = difficulty.icon,
            subimage = 3,
            x = iconX,
            y = iconY
        }
        -- Draw Difficulty Slider
        local sliderX = ror2Hud.difficultyBoxX + (ror2Hud.sliderChoke-1)
        local sliderY = ror2Hud.difficultyBoxY + (ror2Hud.difficultyBoxH/2)+1+ror2Hud.sliderChoke
        local sliderH = (ror2Hud.difficultyBoxH / 2) - (ror2Hud.sliderChoke+2)
        local sliderW = (ror2Hud.difficultyBoxW-(ror2Hud.sliderChoke+2))
        local sliderBG = Surface.new(sliderW + 2,sliderH + 1)
        graphics.setTarget(sliderBG)

        ror2Hud.sliderOffset = math.max(80*(1-((60*ror2Hud.inst:getAccessor().minute+ror2Hud.inst:getAccessor().second))/(81/2*60)), 0) - 7.25
        print(ror2Hud.sliderOffset)
        if ror2Hud.surfaces.slider and ror2Hud.surfaces.slider:isValid() then
            ror2Hud.surfaces.slider:draw(ror2Hud.sliderOffset, 0)
        end
        graphics.resetTarget()
        sliderBG:draw(sliderX, sliderY)
        sliderBG:free()

        -- Draw little pointer thingy
        graphics.alpha(1)
        graphics.color(Color.WHITE)
        graphics.triangle((sliderX + (sliderW/2)) - ror2Hud.sliderPointerSize, (sliderY - ror2Hud.sliderPointerSize),(sliderX + (sliderW/2)) + ror2Hud.sliderPointerSize, (sliderY - ror2Hud.sliderPointerSize), sliderX + (sliderW/2), sliderY + (ror2Hud.sliderPointerSize/2), false)
        graphics.color(Color.BLACK)
        graphics.triangle((sliderX + (sliderW/2)) - ror2Hud.sliderPointerSize, (sliderY - ror2Hud.sliderPointerSize),(sliderX + (sliderW/2)) + ror2Hud.sliderPointerSize, (sliderY - ror2Hud.sliderPointerSize), sliderX + (sliderW/2), sliderY + (ror2Hud.sliderPointerSize/2), true)
        
        --Draw Stage Num
        local textX = ror2Hud.difficultyBoxX + (ror2Hud.difficultyBoxW-2)/6
        local textY = ror2Hud.difficultyBoxY + (ror2Hud.difficultyBoxH/4)
        graphics.color(Color.WHITE)
        graphics.print("Stage", textX, textY - (graphics.textHeight("Stage", graphics.FONT_DEFAULT)/4) + 2, graphics.FONT_DEFAULT, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
        local stageNum = misc.director:get("stages_passed") + 1
        graphics.print(tostring(stageNum), textX, textY + (graphics.textHeight("1", graphics.FONT_DAMAGE)/2) + 1, graphics.FONT_DAMAGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
    else
        ror2Hud.surfaces.difficultyHud = ror2Hud.CreateDifficultyBox()
    end
end

ror2Hud.CreateItemBox = function()
    local bg = ror2Hud.CreateBasicBox(ror2Hud.itemBoxW, ror2Hud.itemBoxH)
    table.insert(ror2Hud.surfaces, bg)
    graphics.resetTarget()
    graphics.alpha(1)
    return bg
end

ror2Hud.DrawItemBox = function(player)
    if ror2Hud.surfaces.itemHud then --Draw Item Box
        if not ror2Hud.surfaces.itemHud:isValid() then
            ror2Hud.surfaces.itemHud = ror2Hud.CreateItemBox()
        end
        graphics.resetTarget()
        graphics.alpha(1)
        ror2Hud.surfaces.itemHud:draw(ror2Hud.itemBoxX, ror2Hud.itemBoxY)
    else
        ror2Hud.surfaces.itemHud = ror2Hud.CreateItemBox()
    end
end

ror2Hud.DrawBossHealth = function()
    if ror2Hud.boss and ror2Hud.boss:isValid() then
        graphics.resetTarget()
        --Draw Bar BG
        graphics.color(Color.BLACK)
        graphics.alpha(0.5)
        graphics.rectangle(ror2Hud.bossHPX - (ror2Hud.bossHPW/2) - 1, ror2Hud.bossHPY - 1, ror2Hud.bossHPX + (ror2Hud.bossHPW/2) + 1, ror2Hud.bossHPY + ror2Hud.bossHPH + 1)
        graphics.rectangle(ror2Hud.bossHPX - (ror2Hud.bossHPW/2), ror2Hud.bossHPY, ror2Hud.bossHPX + (ror2Hud.bossHPW/2), ror2Hud.bossHPY + ror2Hud.bossHPH)
        --Draw Bar
        graphics.alpha(1)
        graphics.color(Color.fromGML(ror2Hud.inst:get("boss_hp_color")))
        local length = ror2Hud.bossHPW * (ror2Hud.boss:get("hp")/ror2Hud.boss:get("maxhp"))
        graphics.rectangle(ror2Hud.bossHPX - (ror2Hud.bossHPW/2), ror2Hud.bossHPY, (ror2Hud.bossHPX - (ror2Hud.bossHPW/2)) + length, ror2Hud.bossHPY + ror2Hud.bossHPH)
        --Draw Shine
        graphics.alpha(0.5)
        graphics.color(Color.WHITE)
        graphics.rectangle(ror2Hud.bossHPX - (ror2Hud.bossHPW/2), ror2Hud.bossHPY + 1, (ror2Hud.bossHPX - (ror2Hud.bossHPW/2)) + length, ror2Hud.bossHPY + 3)
        --Draw hp
        graphics.alpha(1)
        graphics.color(Color.WHITE)
        graphics.print("/", ror2Hud.bossHPX, ror2Hud.bossHPY + (ror2Hud.bossHPH/2) + (graphics.textHeight("1", graphics.FONT_DEFAULT)/4), graphics.FONT_DEFAULT, graphics.ALIGN_CENTER, graphics.ALIGN_MIDDLE)
        
        graphics.print(math.round(ror2Hud.boss:get("hp")), ror2Hud.bossHPX - graphics.textWidth("/", graphics.FONT_DEFAULT), ror2Hud.bossHPY + (ror2Hud.bossHPH/8) + (graphics.textHeight("1", graphics.FONT_DEFAULT)/2), graphics.FONT_DEFAULT, graphics.ALIGN_RIGHT, graphics.ALIGN_MIDDLE)
        graphics.print(math.round(ror2Hud.boss:get("maxhp")), ror2Hud.bossHPX + graphics.textWidth("/", graphics.FONT_DEFAULT), ror2Hud.bossHPY + (ror2Hud.bossHPH/8) + (graphics.textHeight("1", graphics.FONT_DEFAULT)/2), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_MIDDLE)
        --Draw name
        graphics.print(ror2Hud.boss:get("name"), ror2Hud.bossHPX, ror2Hud.bossHPY + (ror2Hud.bossHPH + 3), graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_TOP)
        graphics.print(ror2Hud.boss:get("name2"), ror2Hud.bossHPX, ror2Hud.bossHPY + (ror2Hud.bossHPH + 3) + graphics.textHeight("A", graphics.FONT_LARGE), graphics.FONT_NORMAL, graphics.ALIGN_MIDDLE, graphics.ALIGN_TOP)
    else
        local potentialBosses = ParentObject.find("actors", "vanilla"):findMatchingOp("show_boss_health", "==", 1)
        for _, inst in ipairs(potentialBosses) do
            if inst and inst:isValid() then
                ror2Hud.boss = inst
                break
            end
        end
    end

end

callback.register("onGameStart", function()
    ror2Hud.inst = nil
    ror2Hud.surfaces = {}
end)

callback.register("onStageEntry", function()
    for _, surface in ipairs(ror2Hud.surfaces) do
        surface:free()
    end
    ror2Hud.surfaces = {}
end)
callback.register("onGameEnd", function()
    for _, surface in ipairs(ror2Hud.surfaces) do
        surface:free()
    end
    ror2Hud.surfaces = {}
end)

callback.register("onPlayerHUDDraw", function(player, x, y)
    --Grab local player
    ror2Hud.player = player
end)

callback.register("onHUDDraw", function()
    if ror2Hud.inst and ror2Hud.inst:isValid() then
        ror2Hud.inst:set("show_gold", 0)
        ror2Hud.inst:set("show_skills", 0)
        --ror2Hud.inst:set("show_time", 0)
        ror2Hud.inst:set("show_boss", 0)
    else
        ror2Hud.inst = misc.hud
    end
    local player = ror2Hud.player
    if player then
        ror2Hud.DrawDifficultyBox()
        ror2Hud.DrawCurrencyBox(player)
        ror2Hud.DrawHPBox(player)
        ror2Hud.DrawSkillsHud(player)
        ror2Hud.DrawItemBox(player)
        ror2Hud.DrawBossHealth()
    end
end)