

local sprites = {
    fractureTiles = Sprite.load("TileEmpty1", "Graphics/tiles/A Moment Fractured", 1, 0, 0),
    wholeTiles = Sprite.load("TileEmpty2", "Graphics/tiles/A Moment Whole", 1, 0, 0),
    wholeBG = Sprite.load("WhiteNoise", "Graphics/backgrounds/aMomentWhole", 1, 0, 0),
    boulder = Sprite.load("MomentBoulder", "Graphics/momentBoulder", 1, 49, 49),
    boulderMask = Sprite.load("BoulderMask", "Graphics/boulderMask", 1, 49, 49),
}

local actors = ParentObject.find("actors", "vanilla")

local boulder = Object.new("MomentBoulder")
boulder.sprite = sprites.boulder

boulder:addCallback("create", function(this)
    local data = this:getData()
    this.angle = math.random(0, 360)
    this.mask = sprites.boulderMask
    this.xscale = 0
    this.yscale = 0
    data.active = 0
end)
boulder:addCallback("step", function(this)
    local data = this:getData()
    if data.active == 0 then
        local nearest = actors:findNearest(this.x,this.y)
        if nearest and nearest:isValid() then
            if Distance(this.x, this.y, nearest.x, nearest.y) <= 300 then
                misc.shakeScreen(5)
                data.active = 1
            end
        end
    elseif data.active == 1 then
        if this.xscale < 1 then
            this.xscale = math.approach(this.xscale, 1, 0.1)
            this.yscale = math.approach(this.xscale, 1, 0.1)
        end
        for _, actor in ipairs(actors:findAllEllipse(this.x - (sprites.boulderMask.width/2), this.y - (sprites.boulderMask.height/2),this.x + (sprites.boulderMask.width/2), this.y + (sprites.boulderMask.height/2) )) do
            if actor and actor:isValid() then
                if actor:collidesWith(this, actor.x, actor.y) then
                    if actor:isClassic() then
                        actor:set("pVspeed", 0)
                        actor:set("free", 0)
                    end
                end
            end
        end
    end
end)

-- A Moment, Fractured

local fractured = require("Stages.rooms.fractured")
fractured.displayName = "A Moment, Fractured"
fractured.music = Music.PetrichorV

--------------------------------

-- A Moment, Whole

local whole = require("Stages.rooms.whole")
whole.displayName = "A Moment, Whole"
whole.music = Music.PetrichorV


--------------------------------


local objects = {
    teleporter = Object.find("Teleporter", "vanilla"),
    teleporterFake = Object.find("TeleporterFake", "vanilla"),
    twistedScav = Object.find("ScavengerLunar", "RoR2Demake"),
    whiteFlash = Object.find("WhiteFlash", "vanilla")
}

local momentManager = Object.new("MomentManager")

momentManager:addCallback("create", function(this)
    local data = this:getData()
    data.init = false
    data.scav = false
end)

momentManager:addCallback("step", function(this)
    local data = this:getData()
    local stage = 0
    if Stage.getCurrentStage() == whole then
        stage = 1
    end
    if not data.init then
        for _, p in ipairs(misc.players) do
            if stage == 1 then
                p.x = 454
                p.y = 586
            else
                p.x = 377
                p.y = 426
            end
            p:set("ghost_x", p.x)
            p:set("ghost_y", p.y)
        end
        for _, t in ipairs(objects.teleporter:findAll()) do
            t:destroy()
        end
        for _, t in ipairs(objects.teleporterFake:findAll()) do
            t:destroy()
        end
        data.init = true
    end
    if stage == 0 then
        this:destroy()
        return
    else
        if not data.scav then
            for _, p in ipairs(misc.players) do
                if p.x > 800 then
                    local s = objects.twistedScav:create(1200, 586)
                    local f = objects.whiteFlash:create(p.x, p.y)
                    data.scav = true
                    break
                end
            end
        end

    end
end)

callback.register("onStageEntry", function()
    if Stage.getCurrentStage() == whole or Stage.getCurrentStage() == fractured then
        local m = momentManager:create(0, 0)
    else
        if misc.director:get("stages_passed") % 7 == 0 and misc.director:get("stages_passed") > 0 then
            local o, p = MakeOrb("celestial")
        end
    end
end)