local hpBoxX = 0
local hpBoxY = 0
local hpBoxH = 0
local hpBoxW = 0

local sprites = {
    immune = Sprite.find("Immune", "vanilla"),
}

local hpColors = {
    hp = Color.fromRGB(136, 211, 103),
    hurt = Color.fromRGB(255, 0, 0),
    infusion = Color.fromRGB(169, 63, 66),
    shield = Color.fromRGB(72, 183, 183),
    exp = Color.fromRGB(168, 223, 218),
    glass = Color.fromRGB(175, 116, 201),
    barrier = Color.fromRGB(221, 182, 47),
    immune = Color.fromRGB(226, 191, 139),
    invincible = Color.fromRGB(239, 191, 139),
    empty = Color.fromRGB(26, 26, 26)
}

local hpBarElements = {
    [1] = {
        [1] = {current = "hp", max = "maxhp", color = hpColors.hp, contributeToCurrentHP = true, contributeToMaxHP = true},
        [2] = {current = "shield", max = "maxshield", color = hpColors.shield, contributeToCurrentHP = true, contributeToMaxHP = false}
    },
    [2] = {
        [1] = {current = "barrier", max = "maxhp", color = hpColors.barrier, contributeToCurrentHP = true, contributeToMaxHP = false}
    }
}

callback.register("onPlayerHUDDraw", function(player, x, y)
    --Draw hp
    local hpX = x -35
    local hpY = y + 29
    local hpW = 160
    local hpH = 7
    -- Draw bg
    graphics.color(hpColors.empty)
    graphics.alpha(1)
    graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
    --Calculate shit
    local maxHP = 0
    local currentHP = 0
    for _, layer in ipairs(hpBarElements) do
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
                        graphics.color(hpColors.glass)
                    else
                        graphics.color(hpColors.hp)
                    end
                    if player:countItem(Item.find("Infusion", "vanilla")) > 0 then
                        graphics.color(hpColors.infusion)
                    end
                else
                    graphics.color(stat.color)
                end
                graphics.alpha(1)
                graphics.rectangle(hpX + currentX, hpY, hpX + currentX + length, hpY + hpH)
                currentX = currentX + length
            end
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
        graphics.color(hpColors.immune)
        if player:get("invincible") > 1000 then
            subimage = 2    
            graphics.color(hpColors.invincible)
        end
        graphics.rectangle(hpX, hpY, hpX + hpW, hpY + hpH)
        graphics.drawImage{
            image = sprites.immune,
            subimage = subimage,
            x = hpX + (hpW/2),
            y = hpY + (hpH/2) + 1
        }
    else
        --Draw Text
        graphics.print(math.ceil(currentHP).."/"..maxHP, hpX + (hpW/2), hpY + (hpH/2) + 0.5, NewDamageFont, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
    end

end)

