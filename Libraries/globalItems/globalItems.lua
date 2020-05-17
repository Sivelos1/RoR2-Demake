
GlobalItem = {}

GlobalItem.items = {}

local actors = ParentObject.find("actors", "vanilla")
local AffectedActors = {}

GlobalItem.new = function(item)
    local newEntry = GlobalItem.items[item]
    newEntry = {}
    newEntry.apply = nil
    newEntry.step = nil
    newEntry.remove = nil
    newEntry.draw = nil
    newEntry.hit = nil
    newEntry.kill = nil
    newEntry.damage = nil
    return newEntry
end

local events = {
    ["apply"] = true,-- Takes in an instance and stack count. Applies the item to the instance.
    ["step"] = true,--Takes in an instance and stack count. Runs in postStep.
    ["remove"] = true,--Takes in an instance, a stack count, and a boolean. Removes a stack of the effects of the item from the instance. 
    -- If the boolean is true, completely removes all stacks of effects from the instance.
    ["draw"] = true,--Takes in an instance and stack count. Runs in onDraw.
    ["hit"] = true,--Takes in an instance, stack count, and the arguments for the onHit callback. Run when the instance hits something.
    ["kill"] = true,--Takes in an instance, stack count, and the arguments for the onHit callback. Run when the instance kills an actor.
    ["damage"] = true,--Takes in an instance, stack count, and how much damage the instance took. Run when the instance takes damage.
}
GlobalItem.setEvent = function(item, event, func)
    local entry = GlobalItem.items[item]
    if entry then
        if event == "apply" or event == "step" or event == "remove" or event == "draw" then
            entry[event] = func
        end
    end
end

-- Prepares the actor so it can use items.
GlobalItem.initActor = function(instance)
    if type(instance) == "PlayerInstance" then return
    elseif type(instance) == "ActorInstance" then
        table.insert(AffectedActors, instance)
        local data = instance:getData()
        data.items = {}
        local items = data.items
        for _, item in ipairs(Item.findAll("vanilla")) do
            items[item] = 0
        end
        for _, namespace in ipairs(modloader.getMods()) do
            for _, item in ipairs(Item.findAll(namespace)) do
                --items[item] = 0
            end
        end
    end
end

GlobalItem.addItem = function(instance, item, count)
    if not GlobalItem.items[item] then return end
    if instance:getData().items then
        if not count then count = 1 end
        local items = instance:getData().items
        if count > 0 then
            if GlobalItem.items[item].apply then
                GlobalItem.items[item].apply(instance, count)
            end
        elseif count < 0 then
            if GlobalItem.items[item].remove then
                GlobalItem.items[item].remove(instance, count, false)
            end
        end
        items[item] = items[item] + count
        if items[item] < 0 then
            items[item] = 0
        end
    end
end

GlobalItem.remove = function(instance, item)
    if not GlobalItem.items[item] then return end
    if instance:getData().items then
        local items = instance:getData().items
        if GlobalItem.items[item].remove then
            GlobalItem.items[item].remove(instance, items[item], true)
        end
        items[item] = 0
    end
end

GlobalItem.setItem = function(instance, item, count)
    if instance:getData().items then
        local items = instance:getData().items
        items[item] = count
        if items[item] < 0 then
            items[item] = 0
        end
    end
end

callback.register("postStep", function()
    for _, actor in ipairs(AffectedActors) do
        if actor and actor:isValid() then
            if actor:getData().items then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].step then
                                GlobalItem.items[item].step(actor, count)
                            end
                        end
                    end
                end
            end
        end
    end
end)


callback.register("onDraw", function()
    for _, actor in ipairs(AffectedActors) do
        if actor and actor:isValid() then
            if actor:getData().items then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].draw then
                                GlobalItem.items[item].draw(actor, count)
                            end
                        end
                    end
                end
            end
        end
    end
end)

callback.register("onHit", function(damager, hit, x, y)
    local parent = damager:getParent()
    if parent and parent:isValid() then
        for _, actor in ipairs(AffectedActors) do
            if actor and actor:isValid() and actor == parent then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].hit then
                                GlobalItem.items[item].hit(actor, count, damager, hit, x, y)
                            end
                            if hit:get("hp") - damager:get("damage") < 0 then
                                if GlobalItem.items[item].kill then
                                    GlobalItem.items[item].kill(actor, count, damager, hit, x, y)
                                end
                            end
                        end
                    end
                end
            elseif actor == hit then
                for item, count in pairs(actor:getData().items) do
                    if GlobalItem.items[item] then
                        if item and count > 0 then
                            if GlobalItem.items[item].damage then
                                GlobalItem.items[item].damage(actor, count, damager:get("damage"))
                            end
                        end
                    end
                end
            end
        end
    end
end)

require("Libraries.globalItems.vanilla")