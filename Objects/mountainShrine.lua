--RoR2 Demake Project
--Made by Sivelos
--mountainShrine.lua
--File created 2019/06/02

local sprites = {
    idle = Sprite.load("mountainShrine", "Graphics/mountainShrine", 7, 16, 26),
    mask = Sprite.load("mountainMask", "Graphics/mountainMask", 1, 16, 26),
    icon = Sprite.load("Efmountain", "Graphics/mountain", 1, 5, 5)
}

local teleporter = Object.find("Teleporter", "vanilla")

local mountainShrine = MapObject.new({
    name = "Shrine of the Mountain",
    sprite = sprites.idle,
    baseCost = 0,
    currency = "gold",
    costIncrease = 0,
    affectedByDirector = false,
    mask = sprites.mask,
    useText = "&w&Press &y&'A'&w& to pray to the Shrine of the Mountain&!&",
    activeText = "",
    maxUses = 1,
    triggerFireworks = true,
})
local mountainController = Object.new("MountainController")
mountainController.sprite = sprites.icon

mountainController:addCallback("create", function(self)
    local data = self:getData()
    data.life = 0
    data.parent = nil
    data.level = 1
    data.activated = false
end)

mountainController:addCallback("step", function(self)
    local data = self:getData()
    self:set("life", (self:get("life") + 0.01) % (2*math.pi))
    self.alpha = (0.5 + (math.sin(data.life)/5))
    if data.parent then
        if data.parent:get("active") == 1 and data.parent:get("time") < data.parent:get("maxtime") then
            misc.director:set("boss_drop", 0)
        end
        if data.parent:get("active") == 1 and not data.activated then
            misc.hud:set("objective_text", "Let the Challenge of the Mountain... begin!")
            misc.director:set("bonus_rate", misc.director:get("bonus_rate") + (2.5 * data.level))
            data.activated = true
        end
        if data.parent:get("active") >= 3 and data.activated then
            misc.director:set("bonus_rate", misc.director:get("bonus_rate") - (2.5 * data.level))
            data.activated = false
        end
    end
end)

registercallback("onObjectActivated", function(objectInstance, frame, player, x, y)
    if objectInstance:getObject() == mountainShrine then
        if frame == 1 then
            Sound.find("Shrine1", "vanilla"):play(1 + math.random() * 0.01)
            misc.shakeScreen(5)            
            local text = PopUpText.new("You have invited the Challenge of the Mountain...", 60*3, 5, objectInstance.x, objectInstance.y)
            local inst = mountainController:findNearest(x, y)
            if inst and inst:isValid() then
                inst:getData().level = inst:getData().level + 1
            else
                local tpInst = teleporter:findNearest(x, y)
                if tpInst then
                    inst = mountainController:create(tpInst.x, tpInst.y - (tpInst.sprite.height/2))
                    inst:getData().parent = tpInst
                end
            end
        end
    end
end)

local mountain = Interactable.new(mountainShrine, "Shrine of the Mountain")
mountain.spawnCost = 100

for _, stage in ipairs(Stage.findAll("vanilla")) do
    if stage.displayName ~= "Risk of Rain" then
        stage.interactables:add(mountain)
    end
end