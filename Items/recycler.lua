--RoR2 Demake Project
--Made by Sivelos
--recycler.lua
--File created 2020/05/12

local recycler = Item("Recycler")
recycler.pickupText = "Transform an Item or Equipment into a different one. Can only recycle once."

recycler.sprite = Sprite.load("Items/recycler.png", 2, 14, 16)

recycler.isUseItem = true
recycler.useCooldown = 45

recycler:setTier("use")
recycler:setLog{
    group = "use",
    description = "&b&Transform&!& an Item or Equipment into a different one. &b&Can only be converted into the same tier one time.&!&",
    story = "---",
    destination = "---,\n---\n---",
    date = "--/--/2056"
}

local items = ParentObject.find("items", "vanilla")
local range = 100
local procEffect = Sprite.find("EfRepair", "vanilla")
local sparks = Object.find("EfSparks", "vanilla")
local sound = Sound.find("Drill", "vanilla")
local pulse = Object.find("EfCircle", "vanilla")

local recycledItems = {}

callback.register("onGameStart", function()
    recycledItems = {}
end)
callback.register("onGameEnd", function()
    recycledItems = {}
end)

local bannedPools = {
    ["enigma"] = true,
    ["medcab"] = true,
    ["gunchest"] = true,
    ["SpecialtyUtil"] = true,
    ["SpecialtyDamage"] = true,
    ["SpecialtyHealing"] = true,
}

local SyncItem = net.Packet.new("Sync Recycler Item", function(item, x, y, embryo)
    local i = Item.find(item)
    if i then
        local drop = i:create(x, y)
        local spark = sparks.create(item.x, item.y - 32)
        spark.sprite = procEffect
        spark.spriteSpeed = 0.2
        spark.yscale = 1
        if not embryo then recycledItems[drop.id] = true end
    end
end)

local GetPool = function(item)
    local namespaces = {}
    namespaces[1] = "vanilla"
    for _, namespace in ipairs(modloader.getMods()) do
        namespaces[#namespaces+1] = namespace
    end
    for i = 1, #namespaces - 1 do
        local namespace = namespaces[i]
        print("Searching namespace "..namespace.." for Item Pools.")
        for _, itemPool in pairs(ItemPool.findAll(namespace)) do
            print("Found item pool "..itemPool:getName()..". Searching...")
            if not bannedPools[itemPool:getName()] then 
                if itemPool:contains(item) then
                    print("Item pool "..itemPool:getName().." contains item "..item:getName().."!")
                    return itemPool
                end
            end
        end
    end
end

local UseRecycler = function(user, embryo)
    local p = pulse:create(user.x, user.y)
    sound:play(1)
    p:set("radius", range)
    local item = items:findNearest(user.x, user.y)
    if item and item:isValid() then
        if item:get("used") and item:get("used") == 1 then return end
        if Distance(user.x, user.y, item.x, item.y) <= range then
            if recycledItems[item.id] then return end
            local i = Item.fromObject(item:getObject())
            local pool = GetPool(i)
            if pool then
                if net.host then
                    local newRoll = pool:roll()
                    local newObj = newRoll:create(item.x, item.y)
                    local spark = sparks:create(item.x, item.y - 32)
                    spark.sprite = procEffect
                    spark.spriteSpeed = 0.2
                    spark.yscale = 1
                    if not embryo then recycledItems[newObj.id] = true end
                    if net.online then
                        SyncItem:sendAsHost(net.ALL, nil, newRoll:getName(), item.x, item.y, embryo)
                    end
                end
                item:destroy()
                return
            end
        end
    end
end

recycler:addCallback("use", function(player, embryo)
    UseRecycler(player, embryo)
end)