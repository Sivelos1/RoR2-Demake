-- Artifact of Evolution

local sprites = {
    menu = Sprite.load("Artifacts/evolution", 2, 18, 18)
}

local monstersGetItems = Artifact.new("Evolution")
monstersGetItems.unlocked = true
monstersGetItems.loadoutSprite = sprites.menu
monstersGetItems.loadoutText = "Monsters gain items between stages."

local Items = {}
local itemGUIWidth = 5 -- Displaying the inventory of enemies; the inventory will be X items wide.
local itemGUIHeight = 2 -- Displaying the inventory of enemies; if there are more than X rows, items will begin to be scaled down to fit more on screen.


local Pools = {
    common = ItemPool.find("common", "vanilla"),
    uncommon = ItemPool.find("uncommon", "vanilla"),
    rare = ItemPool.find("rare", "vanilla")
}

local SyncItemGain = net.Packet.new("Sync Evolution Item Gain", function(s, item)
    local i = Item.find(item)
    if i then
        Items[#Items+1] = i
    end
end)

local RollNewMonsterItem = function()
    if net.host then
        local s = misc.director:get("stages_passed")
        local limit = Stage.progressionLimit() - 1
        local pool = nil
        local stages = (s+1)%(limit)
        if ((s+1)/limit)%1 == 0 then
            pool = Pools.rare
        elseif stages / limit > 0.5 then
            pool = Pools.uncommon
        else
            pool = Pools.common
        end
        local item = pool:roll()
        Items[#Items+1] = item
        if net.online then
            SyncItemGain:sendAsHost(net.ALL, nil, item:getName())
        end
        return
    end
end

callback.register("onStageEntry", function()
    if monstersGetItems.active then
        RollNewMonsterItem()
    end
end)

callback.register("onActorInit", function(actor)
    if monstersGetItems.active then
        if type(actor) == "PlayerInstance" or string.find(actor:get("team"), "player") then return end
        if not GlobalItem.actorIsInit(actor) then GlobalItem.initActor(actor) end
        for i = 0, #Items do
            if Items[i] then
                GlobalItem.addItem(actor, Items[i])
            end
        end
    end
end)

callback.register("onHUDDraw", function()
    if monstersGetItems.active then
        local w, h = graphics.getGameResolution()
        local tempItems = {}
        local stacks = 0
        for i = 0, #Items do --Establish item counts
            if Items[i] then
                if tempItems[Items[i]] then
                    tempItems[Items[i]] = tempItems[Items[i]] + 1
                else
                    stacks = stacks + 1
                    tempItems[Items[i]] = 1
                end
            end
        end
        -------------------------
        local x = w - ((32 * itemGUIWidth) + 16)
        local y = h / 2
        local rows = 0
        local maxRows = math.ceil(math.ceil(stacks/itemGUIWidth) / itemGUIHeight)
        local scale = 1
        if maxRows > itemGUIHeight then
            scale = (itemGUIHeight / maxRows)
        end
        ----------------------------
        graphics.alpha(0.5)
        graphics.color(Color.BLACK)
        graphics.rectangle(x-16, y-16, x + 16 + (32 * (itemGUIWidth-1)), y + 16 + (32 * math.max(maxRows, rows)))
        graphics.color(Color.WHITE)
        graphics.rectangle(x-16, y-16, x + 16 + (32 * (itemGUIWidth-1)), y + 16 + (32 * math.max(maxRows, rows)), true)
        graphics.alpha(1)
        graphics.color(Color.LIGHT_GRAY)
        graphics.print("Monsters' Items", x + ((32 * itemGUIWidth) * 0.5), y - (16), graphics.FONT_SMALL, graphics.ALIGN_MIDDLE, graphics.ALIGN_BOTTOM)
        local i = 0
        for item, count in pairs(tempItems) do
            if (i % itemGUIWidth == 0) and i > 0 then
                rows = rows + 1
            end
            graphics.drawImage{
                image = item.sprite,
                x = x + ((32*scale)*(i%itemGUIWidth)),
                y = y + ((32*scale)*(rows)),
                xscale = scale,
                yscale = scale,
                alpha = 0.5,
            }
            if tempItems[item] > 1 then
                graphics.color(Color.LIGHT_GRAY)
                graphics.print(count, x + ((32*scale)*(i%itemGUIWidth)) - (16*scale), y + ((32*scale)*(rows)) + (16*scale), graphics.FONT_DAMAGE, graphics.ALIGN_LEFT, graphics.ALIGN_BOTTOM)
            end
            i = i + 1
        end

    end    
end)

callback.register("onGameStart", function()
    Items = {}
end)