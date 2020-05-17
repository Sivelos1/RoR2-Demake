--horde.lua

local player = Object.find("P", "vanilla")
local enemy = ParentObject.find("enemies", "vanilla")


local enemiesByStage = {
    ["Desolate Forest"] = {
        
    },
}

local maximumHorde = 5

local horde = Object.base("EnemyClassic", "horde")
horde:addCallback("create", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    self.name = "???"
    self.name2 = "Horde of Many"
    self.prefix_type = 0
    self.pHmax = 0
    self.damage = 0
    self.maxhp = 100
    self.exp_worth = 0
    self.hp = self.maxhp
    self.show_boss_health = 0
    data.enemy = nil
    data.children = {}
    data.childIDs = {}
    data.parentTP = Object.find("Teleporter"):findNearest(this.x, this.y)
    data.prefix = -1
    data.elite = -1
    data.blight = -1
    local nearestEnemy = enemy:findNearest(data.parentTP.x, data.parentTP.y)
    if nearestEnemy then
        local acc = nearestEnemy:getAccessor()
        data.enemy = nearestEnemy:getObject()
        self.name = acc.name
        data.prefix = acc.prefix_type
        if data.prefix == 1 then
            data.elite = acc.elite_type
        elseif data.prefix == 2 then
            data.blight = acc.blight_type
        end
    else
        data.enemy = Object.find("Lizard", "vanilla")
    end
    this.mask = Sprite.find("Empty", "RoR2Demake")
    data.hordeStrength = math.clamp((Difficulty.getScaling("cost") * math.round(misc.director:get("enemy_buff") * ((misc.director:get("time_start") % 5) + 1))), 1, maximumHorde)
    print("Horde level: "..data.hordeStrength)
    data.spawn = 0
    data.progress = 0
    data.count = 0
end)
horde:addCallback("step", function(this)
    local data = this:getData()
    local self = this:getAccessor()
    this.alpha = 0
    self.invincible = 1
    if data.parentTP then
        this.x = data.parentTP.x
        this.y = data.parentTP.y
    end
    if data.spawn == 0 then
        for i = 0, data.hordeStrength do
            print(i .. " / " .. data.hordeStrength)
            local ground = Object.find("B", "vanilla"):findNearest(data.parentTP.x, data.parentTP.y)
            local prefix = 0
            local elite = -1
            local blight = -1
            if data.prefix > 0 then
                if data.count == 0 or data.hordeStrength == maximumHorde or math.random(0, data.hordeStrength) > 3  then
                    prefix = data.prefix
                    elite = data.elite
                    blight = data.blight
                end
            end
            local inst = data.enemy:create(ground.x + math.random(ground.xscale * 16), ground.y - 16)
            local flash = Object.find("EfFlash", "vanilla"):create(inst.x, inst.y)
            flash:getAccessor().parent = inst.id
            local e = inst:getAccessor()
            e.damage = e.damage * Difficulty.getScaling("damage")
            e.maxhp = e.maxhp * Difficulty.getScaling("hp")
            e.hp = e.maxhp
            if prefix then
                e.prefix_type = prefix
                if blight then
                    e.blight_type = blight
                elseif elite then
                    e.elite_type = elite
                end
            end
            data.children[i] = inst
        end 
        data.spawn = 1
    elseif data.spawn == 1 then
        data.progress = data.progress + 1
        local count = 0
        if count >= data.hordeStrength or data.progress >= 5*60 then
            Object.find("WhiteFlash"):create(0, 0)
            self.show_boss_health = 1
            data.spawn = 2
        end
    elseif data.spawn == 2 then
        local hp = 1
        local maxhp = 1
        for _, child in ipairs(data.children) do
            print(child)
            if child and child:isValid() then
                print("a")
                hp = hp + child:get("hp")
                maxhp = maxhp + child:get("maxhp")
            end
        end
        self.hp = hp
        self.maxhp = maxhp
    end
end)
horde:addCallback("destroy", function(this)
    local data = this:getData()
    local self = this:getAccessor()
end)