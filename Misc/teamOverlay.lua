
local uiX = 10
local uiY = 100

local portraitSize = 16

local width = 72
local height = 18

local actors = ParentObject.find("actors", "vanilla")

local surfaces = {}

local createTeamElement = function(actor)
    local newSurface = Surface.new(width, height)
    graphics.setTarget(newSurface)
    ---
    --Create background
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(0, 0, width, height, false)

    --Create portrait surface
    local portrait = Surface.new(portraitSize, portraitSize)
    graphics.setTarget(portrait)
    graphics.alpha(0.5)
    graphics.rectangle(0, 0, portraitSize, portraitSize)
    graphics.alpha(1)
    --Draw sprite to new surface
    local sprite = actor:getAnimation("idle")
    if sprite then
        graphics.drawImage{
            image = sprite,
            x = portraitSize / 2,
            y = sprite.height / 1.5,
            color = actor.blendColor,
            alpha = 1,
    }
    end
    graphics.setTarget(newSurface)
    --Draw portrait to surface
    graphics.alpha(1)
    portrait:draw(1, 1)
    portrait:free() --delete portrait after use
    
    -- Draw name
    graphics.color(Color.WHITE)
    local name = actor:get("name") or "???"
    if net.online and isa(actor, "PlayerInstance") and actor:get("user_name") then
        name = actor:get("user_name")
    end
    graphics.print(name, (portraitSize + 2), ((graphics.textHeight("???", graphics.FONT_SMALL)/2) + 1), graphics.FONT_SMALL, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
    
    --Draw HP background
    graphics.color(Color.BLACK)
    local xx = portraitSize + 2
    local xMax = xx + ((width - xx) - 3)
    local yy = ((graphics.textHeight("???", graphics.FONT_SMALL)) + 1)
    graphics.rectangle(xx, yy, xMax, yy + 5)
    
    ---
    graphics.resetTarget()
    return newSurface
end

registercallback("onPlayerHUDDraw", function(player, x, y)
    local i = 0
    for _, actor in ipairs(actors:findAll()) do
        if actor:isValid() then
            if actor:get("team") == player:get("team") and actor ~= player then
                if not surfaces[actor] or not surfaces[actor]:isValid() then
                    --If the actor doesn't have a surface, create one
                    surfaces[actor] = createTeamElement(actor)
                end
                --Draw surface if the surface is valid
                if surfaces[actor]:isValid() then
                    surfaces[actor]:draw(uiX, uiY + ((height + 2) * i))
                    -- Draw HP bar
                    graphics.color(Color.fromRGB(136,211,103))
                    if isa(actor, "PlayerInstance") and actor:countItem(Item.find("Infusion", "vanilla")) > 0 then
                        graphics.color(Color.fromRGB(169,63,66))
                    else
                        if Artifact.find("Glass", "vanilla").active and isa(actor, "PlayerInstance") then
                            graphics.color(Color.fromRGB(175,116,201))
                        end
                    end
                
                    local hpRatio = actor:get("hp") / actor:get("maxhp")
                    local xx = uiX + (portraitSize + 2)
                    local xMax = uiX + ((portraitSize + 2) + ((width - (portraitSize + 2)) - 3))
                    local yy = (uiY + ((height + 2) * i)) + (((graphics.textHeight("???", graphics.FONT_SMALL)) + 1))
                    local barLength = math.clamp(math.round((xMax) * hpRatio), 0, xMax)
                    graphics.rectangle(xx, yy, math.clamp(barLength, xx, xMax), yy + 5)
                    i = i + 1
                else
                    surfaces[actor]:free() --If the surface isn't valid, delete it and make a new one
                    surfaces[actor] = createTeamElement(actor)
                end
            end
        end
    end
end)

registercallback("onStageEntry", function()
    for _, surface in ipairs(surfaces) do
        surface:free()
    end
    surfaces = {}
end)

registercallback("onGameEnd", function()
    for _, surface in ipairs(surfaces) do
        surface:free()
    end
    surfaces = {}
end)