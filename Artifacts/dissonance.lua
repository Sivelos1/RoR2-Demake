-- Artifact of Dissonance

local sprites = {
    menu = Sprite.load("Artifacts/dissonance", 2, 18, 18)
}

local globalMonsterSpawn = Artifact.new("Dissonance")
globalMonsterSpawn.unlocked = true
globalMonsterSpawn.loadoutSprite = sprites.menu
globalMonsterSpawn.loadoutText = "Monsters can appear outside of their usual environments."

local monsterCache = {
    stage = nil,
    cards = {}
}

local cardAmounts = {
    boss = 3,
    enemy = 5,
}

local blacklist = { --These guys, for one reason or another, should stay in their respective stages.
    [MonsterCard.find("Ifrit", "vanilla")] = true,
    [MonsterCard.find("Cremator", "vanilla")] = true,
}

local enemies = {}
local bosses = {}

callback.register("postLoad", function()
    for _, c in ipairs(MonsterCard.findAll("vanilla")) do
        if blacklist[c] then break end
        if c.isBoss then
            bosses[#bosses+1] = c
        else
            enemies[#enemies+1] = c
        end
    end
    for _, namespace in ipairs(modloader.getMods()) do
        for _, c in ipairs(MonsterCard.findAll(namespace)) do
            if blacklist[c] then break end
            if c.isBoss then
                bosses[#bosses+1] = c
            else
                enemies[#enemies+1] = c
            end
        end
    end
end)

local RemoveMonsterCards = function()
    local current = Stage.getCurrentStage()
    monsterCache.cards = {}
    monsterCache.stage = current
    for i = 1, current.enemies:len() do
        if current.enemies[i] then
            monsterCache.cards[i] = current.enemies[i]
            current.enemies:remove(current.enemies[i])
        end
    end
end

local RestorePreviousStage = function()
    if monsterCache.stage then --if monsterCache is already full, clean it out and restore previous stage
        local cache = monsterCache
        for i = 1, cache.stage.enemies:len() do
            if cache.stage.enemies[i] then
                local card = cache.stage.enemies[i]
                cache.stage.enemies:remove(card)
            end
        end
        for i = 1, #cache.cards do
            if cache.cards[i] then
                local card = cache.cards[i]
                print("Returning card "..card:getName().." to stage "..cache.stage.displayName..".")
                cache.stage.enemies:add(card)
            end
        end
        cache.stage = nil
        cache.cards = {}
    end
end

local GenerateDissonanceCards = function()
    local current = Stage.getCurrentStage()
    local enemyTemp = enemies
    local bossesTemp = bosses
    for i = 1, cardAmounts.enemy do
        local index = math.random(1, #enemyTemp - 1)
        local roll = enemyTemp[index]
        if roll then
            current.enemies:add(roll)
            print("Adding enemy "..roll:getName().." to stage "..current.displayName..".")
            table.remove(enemyTemp, index)
        else
            i = i - 1
        end
    end
    for i = 1, cardAmounts.boss do
        local index = math.random(1, #bossesTemp - 1)
        local roll = bossesTemp[index]
        if roll then
            current.enemies:add(roll)
            print("Adding boss "..roll:getName().." to stage "..current.displayName..".")
            table.remove(bossesTemp, index)

        else
            i = i - 1
        end
    end
end

callback.register("onStageEntry", function()
    local director = misc.director
    local data = director:getData()
    if globalMonsterSpawn.active then
        data.dissonanceComplete = false
    end
end)

callback.register("postStep", function()
    local director = misc.director
    local data = director:getData()
    if globalMonsterSpawn.active then
        if not data.dissonanceComplete then --Artifact enabled, but process not done
            RestorePreviousStage()
            RemoveMonsterCards()
            GenerateDissonanceCards()
            data.dissonanceComplete = true
        end
    else
        if data.dissonanceComplete then --Artifact disabled, but process already done
            RestorePreviousStage()
            data.dissonanceComplete = false
        end
    end
end)