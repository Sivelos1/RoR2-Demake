-- Artifact of Swarms

local sprites = {
    menu = Sprite.load("Artifacts/swarms", 2, 18, 18)
}

local enemyToCards = {}

callback.register("postLoad", function()
    local namespaces = {}
    namespaces[1] = "vanilla"
    for _, namespace in ipairs(modloader.getMods()) do
        namespaces[#namespaces+1] = namespace
    end
    for i = 1, #namespaces do
        for _, card in ipairs(MonsterCard.findAll(namespaces[i])) do
            enemyToCards[card.object] = card
        end
    end
end)

local doubleMonsterSpawn = Artifact.new("Swarms")
doubleMonsterSpawn.unlocked = true
doubleMonsterSpawn.loadoutSprite = sprites.menu
doubleMonsterSpawn.loadoutText = "Monster spawns are doubled, but monster maximum health is halved."

callback.register("onGameStart", function(actor)
    if doubleMonsterSpawn.active then
        local director = misc.director
        local data = director:getData()
        data.swarmCD = -1
    end
end)

callback.register("onActorInit", function(actor)
    if doubleMonsterSpawn.active then
        if type(actor) == "PlayerInstance" or string.find(actor:get("team"), "player") then return end
        actor:set("maxhp", actor:get("maxhp") / 2)
        actor:set("hp", actor:get("maxhp"))
        local dir = misc.director
        local data = dir:getData()
        if data.swarmCD <= -1 then
            if enemyToCards[actor:getObject()] then
                local card = enemyToCards[actor:getObject()]
                dir:set("points", dir:get("points") + card.cost)
                dir:setAlarm(1, 0)
                data.swarmCD = 5
            end
        end
    end
end)

callback.register("postStep", function()
    if doubleMonsterSpawn.active then
        local director = misc.director
        local data = director:getData()
        if data.swarmCD and data.swarmCD > -1 then
            data.swarmCD = data.swarmCD - 1
        end
    end
end)