--loadout.lua

require("Libraries.skill.main")

Loadout = {}

SkillSlots = {
    Passive = 0,
    Primary = 1,
    Secondary = 2,
    Utility = 3,
    Special = 4,
    Skin = 5,
}

SlotToName = {
    [0] = "Passive",
    [1] = "Primary",
    [2] = "Secondary",
    [3] = "Utility",
    [4] = "Special",
    [5] = "Skin",
}

SlotToSkill = {
    ["Primary"] = 1,
    ["Secondary"] = 2,
    ["Utility"] = 3,
    ["Special"] = 4,
}

local loadouts = {}

Loadout.findFromSurvivor = function(survivor)
    for _, loadout in pairs(loadouts) do
        if loadout.survivor == survivor then
            return loadout
        end
    end
    return nil
end

Loadout.findAll = function()
    return loadouts
end

----------------------------------------------------------------


local noPassive = Skill.new()

noPassive.displayName = "Disable Passive"
noPassive.icon = Sprite.find("MobSkills", "vanilla")
noPassive.iconIndex = 3
noPassive.cooldown = -1

local underConstruction = Skill.new()

underConstruction.displayName = "Under Construction"
underConstruction.description = "This is under construction and will be added in in a future update."
underConstruction.icon = Sprite.load("Graphics/underconstruction", 1, 0, 0)
underConstruction.iconIndex = 1
underConstruction.cooldown = -1


Loadout.PresetSkills = {
    NoPassive = noPassive,
    Unfinished = underConstruction,
}



---------------------------------------------------------------

-- Adds a new loadout to the Loadout system.
Loadout.new, loadout_mt = newtype("Loadout")

function loadout_mt:__init()
    loadouts[self] = {}
    loadouts[self].survivor = nil
    loadouts[self].description = "Information Unset"
    loadouts[self].slotCount = 0
    loadouts[self].iteration = {}
    loadouts[self].iteration.start = 0
    -- Prepare skills slots
    loadouts[self].skillSlots = {}
    for i = 0, 5 do
        loadouts[self].skillSlots[SlotToName[i]] = {}
        loadouts[self].skillSlots[SlotToName[i]].name = SlotToName[i]
        loadouts[self].skillSlots[SlotToName[i]].index = loadouts[self].slotCount
        loadouts[self].skillSlots[SlotToName[i]].displayOrder = loadouts[self].slotCount
        loadouts[self].skillSlots[SlotToName[i]].count = 0
        loadouts[self].skillSlots[SlotToName[i]].current = nil
        loadouts[self].skillSlots[SlotToName[i]].showInLoadoutMenu = true
        loadouts[self].skillSlots[SlotToName[i]].showInCharSelect = true
        loadouts[self].skillSlots[SlotToName[i]].skills = {}
        if SlotToName[i] == "Skin" then
            loadouts[self].skillSlots[SlotToName[i]].showInCharSelect = false
        elseif SlotToName[i] == "Passive" then
            loadouts[self].skillSlots[SlotToName[i]].showInCharSelect = false
            loadouts[self].skillSlots[SlotToName[i]].displayOrder = -1
            loadouts[self].skillSlots[SlotToName[i]].showInLoadoutMenu = false
        end
        loadouts[self].iteration.last = loadouts[self].slotCount
        loadouts[self].slotCount = loadouts[self].slotCount + 1
    end
    loadouts[self].icons = {}
    loadouts[self].iconCount = 0
end

-- Updates the character select screen to reflect the passed in loadout.
Loadout.Update = function(loadout)
    local ldData = loadout
    if loadouts[loadout] then ldData = loadouts[loadout] end
    ldData.icons[ldData.iconCount] = nil
    ldData.iconCount = ldData.iconCount + 1
    local slots = {}
    local count = 0
    for _, slot in pairs(ldData.skillSlots) do
        if slot then
            if slot.skills and slot.showInCharSelect then
                if not slot.current then
                    slot.current = slot.skills[1]
                end
                if slot.current.obj == Loadout.PresetSkills.NoPassive then
    
                else
                    table.insert(slots, slot)
                    count = count + 1
                end
            end

        end
    end
    table.sort(slots, function(a, b)
        if a.displayOrder < b.displayOrder then
            return true
        else
            return false
        end
    end)
    for i = 1, 4 do
        local slot = slots[i]
        local temp = nil
        if count > 4 then
            temp = Surface.new(18, 18 + (39 * count-4))
        else
            temp = Surface.new(18, 18)
        end
    
        graphics.setTarget(temp)
        graphics.alpha(1)
        graphics.drawImage{
            image = slot.current.icon,
            subimage = slot.current.subimage,
            x = 0,
            y = 0,
        }
        local name = slot.current.displayName or "Information Unset"
        local desc = slot.current.loadoutDescription or "Information Unset"
        if count > 4 and i == 4 then
            for z = i + 1, count do
                name = name .. ":\n\n\n" .. (slots[z].current.displayName or "Information Unset")
                desc = desc .. "\n\n" .. (slots[z].current.loadoutDescription or "Information Unset")
                graphics.setTarget(temp)
                graphics.alpha(1)
                graphics.drawImage{
                    image = slots[z].current.icon,
                    subimage = slots[z].current.subimage,
                    x = 0,
                    y = 39 * (z - i),
                }
            end
        end
        loadout.survivor:setLoadoutSkill(i, name, desc)
        graphics.resetTarget()
        if ldData.icons[ldData.iconCount] then
            ldData.icons[ldData.iconCount]:addFrame(temp)
        else
            ldData.icons[ldData.iconCount] = temp:createSprite(0, 0)
        end
    end
    if ldData.skillSlots["Skin"] and ldData.skillSlots["Skin"].current then
        for key, sprite in pairs(ldData.skillSlots["Skin"].current.sprites) do
            if sprite then
                if key == "loadout" then
                    loadout.survivor.loadoutSprite = sprite
                elseif key == "walk" then
                    loadout.survivor.titleSprite = sprite
                elseif key == "idle" then
                    loadout.survivor.idleSprite = sprite
                end
            end
        end
    end
    ldData.icons[ldData.iconCount] = ldData.icons[ldData.iconCount]:finalize(loadout.survivor:getName().."_LoadoutIcons"..ldData.iconCount)
    loadout.survivor:setLoadoutInfo(ldData.description, ldData.icons[ldData.iconCount])
end

--Applies the loadout to a player instance.
-- Parameters:
    -- loadout: The loadout to apply.
    -- player: The player instance to apply to. The player's survivor must match the loadout's survivor.
    -- targetSlot: Optional. The name of a slot you wish to apply to. Only applies to the given slot.
Loadout.Apply = function(loadout, player, targetSlot)
    if type(player) == "PlayerInstance" then
        local l = loadout
        if loadouts[loadout] then l = loadouts[loadout] end
        if player:getSurvivor() == loadout.survivor then
            local data = player:getData()
            data.Loadout = {}
            if targetSlot then
                if l.skillSlots[targetSlot] then
                    local slot = l.skillSlots[targetSlot]
                    -- Reset any effects carried over from past applications
                    for _, skill in ipairs(slot.skills) do
                        if skill.remove then
                            skill.remove(player, true)
                        end
                    end
                    --...then apply the current effects
                    if slot.current.apply then
                        slot.current.apply(player)
                    end
                    if SlotToSkill[targetSlot] then
                        Skill.set(player, SlotToSkill[targetSlot], l.skillSlots[targetSlot].current.obj)
                    end
                    if targetSlot == "Skin" and l.skillSlots["Skin"] and l.skillSlots["Skin"].current then
                        for key, sprite in pairs(l.skillSlots["Skin"].current.sprites) do
                            if sprite then
                                if key == "loadout" then
                                    loadout.survivor.loadoutSprite = sprite
                                elseif key == "walk" then
                                    loadout.survivor.titleSprite = sprite
                                    player:setAnimation(key, sprite)
                                elseif key == "idle" then
                                    loadout.survivor.idleSprite = sprite
                                    player:setAnimation(key, sprite)
        
                                else
                                    player:setAnimation(key, sprite)
                                end
                            end
                        end
                    end
                else
                    error("Invalid slot.")
                end
            else
                for _, slot in pairs(l.skillSlots) do
                    if slot.name ~= "Skin" then
                        if slot.current then
                            -- Reset any effects carried over from past applications        
                            for _, skill in ipairs(slot.skills) do
                                if skill.remove then
                                    skill.remove(player, true)
                                end
                            end
                            --...then apply the current effects
                            if slot.current.apply then
                                slot.current.apply(player)
                            end
                        end
    
                    end
                end
                -- Set player's Z, X, C, and V skills
                for i = 1, 4 do
                    Skill.set(player, i, l.skillSlots[SlotToName[i]].current.obj)
                end
                -- Set player's skin
                if l.skillSlots["Skin"] and l.skillSlots["Skin"].current then
                    for key, sprite in pairs(l.skillSlots["Skin"].current.sprites) do
                        if sprite then
                            if key == "loadout" then
                                loadout.survivor.loadoutSprite = sprite
                            elseif key == "walk" then
                                loadout.survivor.titleSprite = sprite
                                player:setAnimation(key, sprite)
                            elseif key == "idle" then
                                loadout.survivor.idleSprite = sprite
                                player:setAnimation(key, sprite)
    
                            else
                                player:setAnimation(key, sprite)
                            end
                        end
                    end
                end
            end
            
        else
            error("Incorrect survivor.")
        end
    else
        error("Invalid type for loadout:apply player - player must be a PlayerInstance")
    end
end

-- Runs the remove function for the current skill in a player's given slot.
-- Hard-remove is ran upon applying the loadout to a player.
Loadout.Remove = function(loadout, player, slot, hardRemove)
    if loadout.skillSlots[slot].current.remove then
        loadout.skillSlots[slot].current.remove(player, hardRemove)
    end
end


local loadout_lookup = {
    survivor = {
        get = function(self)
            return loadouts[self].survivor
        end,
        set = function(self, var)
            if not type(var) == "Survivor" then error("Invalid type for loadout.survivor, must be a Survivor.") end
            loadouts[self].survivor = var
        end
    },
    description = {
        get = function(self)
            return loadouts[self].description
        end,
        set = function(self, var)
            if not type(var) == "string" then error("Invalid type for loadout.description, must be a string.") end
            loadouts[self].description = var
        end
    },
    -- Adds a new slot to the loadout.
    -- Returns the newly created slot.
    -- Parameters:
        -- name: The new name of the slot.
    addSlot = function(s, name)
        loadouts[s].skillSlots[name] = {}
        loadouts[s].skillSlots[name].name = name
        loadouts[s].skillSlots[name].index = loadouts[s].slotCount + 1
        loadouts[s].skillSlots[name].displayOrder = loadouts[s].slotCount + 1
        loadouts[s].iteration.last = loadouts[s].iteration.last + 1
        loadouts[s].slotCount = loadouts[s].slotCount + 1
        loadouts[s].skillSlots[name].count = 0
        loadouts[s].skillSlots[name].current = nil
        loadouts[s].skillSlots[name].showInLoadoutMenu = true
        loadouts[s].skillSlots[name].showInCharSelect = true
        loadouts[s].skillSlots[name].skills = {}
        return loadouts[s].skillSlots[name]
    end,
    -- Returns a skill slot based on the passed in slot parameter. Returns nil if nothing is found.
    -- Parameters:
        -- slot: The slot to return. Can either be a number or a string:
            -- passing in a string will search based on the slot's name.
            -- passing in an int will search based on two variables, controlled by the parameter searchBy (see below).
        -- searchBy: Optional. Pass in to specify which variable you want to use when looking for a slot.
            -- 0: Searches by the slot's index. Defaults to this if not specified.
            -- 1: Searches by the slot's displayOrder.
    getSlot = function(s, slot, searchBy)
        if type(slot) == "string" then
            return loadouts[s].skillSlots[slot]
        elseif type(slot) == "number" then
            local var = "index"
            if searchBy and searchBy == 1 then
                var = "displayOrder"
            end
            local result = nil
            for _, s in pairs(loadouts[s].skillSlots) do
                for v, k in pairs(s) do
                    if k == var then
                        if v == slot then
                            return s
                        end
                    end
                end
            end
        end
        return nil
    end,
    -- Returns all the skill slots for the loadout.
    getAllSlots = function(s)
        return loadouts[s].skillSlots
    end,
    --Adds a skill to the specified slot. 
    -- If the slot doesn't have a current skill, then the added skill will be set as the slot's currently selected skill.
    -- Returns the newly created skill entry.
    -- Parameters:
        -- slot: The slot to add the skill to.
        -- obj: The skill object to add.
        -- info: A table of variables. Used for things like menus and visual feedback.
            -- Not passing anything in to this will use the skill's matching info instead.
            -- displayName: The name displayed for the skill.
            -- icon: The sprite used for the skill's icon.
            -- subimage: The subimage of the skill's icon.
            -- hudDescription: The description of the skill shown when the player hovers over it in the game's HUD.
            -- loadoutDescription: The description of the skill shown in the character select screen and loadout menu. Supports colored text.
            -- hidden: Whether or not the skill should be hidden on the loadout menu. Defaults to false.
            -- locked: Whether or not the skill should start off locked. Defaults to false.
            -- apply: A function that takes in a player instance. Ran when the skill is applied to the player. Useful for initializing variables.
            -- remove: A function that takes in a player instance, and an optional bool. Ran if the skill is removed from a player. 
                --The optional bool determines if the function should hard-remove the effects. This is useful if you want to set a variable to a specific
                --value without worrying about its current value.
                --Useful for cleaning up any variables set by the skill.
            -- upgrade: A skill entry that the skill "upgrades" to - i.e, Ancient Scepter.
    addSkill = function(s, slot, skill, info)
        if loadouts[s].skillSlots[slot] then
            local s = loadouts[s].skillSlots[slot]
            local skillEntry = {}
            skillEntry.obj = skill
            skillEntry.index = s.count
            skillEntry.locked = false
            skillEntry.hidden = false
            skillEntry.displayName = skill.displayName
            skillEntry.icon = skill.icon
            skillEntry.subimage = skill.iconIndex
            skillEntry.loadoutDescription = skill.description
            skillEntry.hudDescription = skill.description
            if info then
                if info.displayName then skillEntry.displayName = info.displayName end
                if info.icon then skillEntry.icon = info.icon end
                if info.subimage then skillEntry.subimage = info.subimage end
                if info.hudDescription then skillEntry.hudDescription = info.hudDescription end
                if info.loadoutDescription then skillEntry.loadoutDescription = info.loadoutDescription end
                if info.locked then skillEntry.locked = info.locked end
                if info.hidden then skillEntry.hidden = info.hidden end
                if info.apply then skillEntry.apply = info.apply end
                if info.remove then skillEntry.remove = info.remove end
                if info.upgrade then skillEntry.upgrade = info.upgrade end
            end
            table.insert(s.skills, s.count, skillEntry)
            s.count = s.count + 1
            if not s.current and not skillEntry.hidden and not skillEntry.locked then
                s.current = skillEntry
            end
            return skillEntry
        else
            error("Loadout slot is invalid.")
        end
    end,
    --Adds a skin to the loadout.
    --Behaves similarly to loadout:addSkill(), but doesn't return anything.
    -- Parameters:
        -- Uses similar parameters to loadout:addSkill(), but with some changes.
        -- No slot.
        -- sprites: An array of sprites for the skin to use.
            -- Make sure these sprites are keyed based on the actor's animation keys!
        -- info: A table of variables. Takes the same arguments as loadout:addSkill()'s info.
    addSkin = function(s, obj, sprites, info)
        if loadouts[s].skillSlots["Skin"] then
            local slot = loadouts[s].skillSlots["Skin"]
            local skinEntry = {}
            skinEntry.obj = obj
            skinEntry.locked = false
            skinEntry.sprites = sprites
            skinEntry.displayName = obj.displayName
            skinEntry.icon = obj.icon
            skinEntry.subimage = obj.iconIndex
            skinEntry.loadoutDescription = obj.description
            skinEntry.hudDescription = obj.description
            if info then
                if info.displayName then skinEntry.displayName = info.displayName end
                if info.icon then skinEntry.icon = info.icon end
                if info.subimage then skinEntry.subimage = info.subimage end
                if info.hudDescription then skinEntry.hudDescription = info.hudDescription end
                if info.loadoutDescription then skinEntry.loadoutDescription = info.loadoutDescription end
                if info.locked then skinEntry.locked = info.locked end
                if info.hidden then skinEntry.hidden = info.hidden end
                if info.apply then skinEntry.apply = info.apply end
                if info.remove then skinEntry.remove = info.remove end
                if info.upgrade then skinEntry.upgrade = info.upgrade end
            end
            table.insert(slot.skills, slot.count, skinEntry)
            slot.count = slot.count + 1
            if not slot.current then
                slot.current = skinEntry
            end
        else
            error("Loadout slot \"Skin\" is invalid.")
        end
    end,
    -- Returns a Skill Entry based on the passed in skill. Returns nil otherwise.
    getSkillEntry = function(s, skill)
        for _, slot in pairs(loadouts[s].skillSlots) do
            for _, skillEntry in ipairs(slot.skills) do
                if skillEntry.obj and skillEntry.obj == skill then
                    return skillEntry
                end
            end
        end
        return nil
    end,
    -- Returns all Skill Entries for a given slot.
    getAllSkillEntries = function(s, slot)
        return loadouts[s].skillSlots[slot].skills
    end,
    -- Sets the current skill entry for a slot.
    -- Parameters:
        -- slot: The slot to set.
        -- skill: The skill to set to.
    setCurrentSkill = function(s, slot, skill)
        loadouts[s].skillSlots[slot].current = s:getSkillEntry(s, skill)
    end,
    -- Returns the current skill entry of the passed in slot.
    getCurrentSkill = function(s, slot)
        return loadouts[s].skillSlots[slot].current
    end,
}

loadout_mt.__index = function(t, k)
	local s = loadout_lookup[k]
	if s then
		if type(s) == "table" then
			return s.get(t)
		else
			return s
		end
	else
		error(string.format("Loadout does not contain a field '%s'", tostring(k)), 2)
	end
end

loadout_mt.__newindex = function(t, k, v)
	local s = loadout_lookup[k]
	if type(s) == "table" then
		s.set(t, v)
	else
		error(string.format("Loadout does not contain a field '%s'", tostring(k)), 2)
	end
end

--Saves the loadout to the player's file.
Loadout.Save = function(loadout)
    if loadouts[loadout] then loadout = loadouts[loadout] end
    --debugPrint("Saving loadout for survivor "..loadout.survivor:getName().." ("..loadout.survivor:getOrigin()..")")
    for _, slot in pairs(loadout.skillSlots) do
        if slot.current then
            save.write(loadout.survivor:getName().."_Loadout_"..slot.name, slot.current.displayName or "")
            --debugPrint(" - Successfully saved Slot "..slot.name.." ("..slot.current.displayName..") at \'"..loadout.survivor:getName().."_Loadout_"..slot.name.."\'.")
        end
        for _, skill in pairs(slot.skills) do
            save.write(loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked", skill.locked)
            --debugPrint("    - Successfully saved unlock status of Skill "..skill.displayName.." at \'"..loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked".."\'")
        end
    end
    
end
--Loads the loadout from the player's file.
-- Returns the newly loaded loadout.
Loadout.Load = function(loadout)
    local ldData = loadouts[loadout]
    --debugPrint("Loading loadout for survivor "..loadout.survivor:getName().." ("..loadout.survivor:getOrigin()..")")
    for _, slot in pairs(loadout.skillSlots) do
        local saveData = save.read(loadout.survivor:getName().."_Loadout_"..slot.name)
        if saveData then
            for _, skill in pairs(slot.skills) do
                if skill.displayName == saveData then
                    slot.current = skill
                    --debugPrint(" - Successfully loaded Slot "..slot.name..": "..slot.current.displayName)
                end
            end
        end
        for _, skill in pairs(slot.skills) do
            local locked = save.read(loadout.survivor:getName().."_Loadout_"..skill.displayName.."_Locked")
            if locked then
                if locked == "true" then
                    skill.locked = true
                else
                    skill.locked = false
                end
            end
            --debugPrint("    - Successfully loaded unlock status of "..skill.displayName..": "..tostring(skill.locked))
        end
    end
    Loadout.Update(loadout)
    return loadout
end

-- Sets the skill of a given slot to its "upgraded" variant for the given player. Does nothing if no upgrade is defined (see loadout:addSkill()).
Loadout.Upgrade = function(loadout, player, slot)
    if loadouts[loadout] then loadout = loadouts[loadout] end
    if loadout.skillSlots[slot].current.upgrade then
        loadout.skillSlots[slot].current = loadout.skillSlots[slot].current.upgrade
        Loadout.Apply(loadout, player, slot)
    else
        return
    end
end


local menu = Object.new("LoadoutMenu")

local pod = Sprite.load("LoadoutPod", "Graphics/UI/loadoutPod", 1, 42, 81)
local button1 = Sprite.find("Launch", "vanilla")
local button2 = Sprite.find("Ready", "vanilla")
local sound = Sound.find("Pickup", "vanilla")
local mobSkills = Sprite.find("MobSkills", "vanilla") 
local lockedIn = Sprite.find("LockedInSmall", "vanilla") 

local actors = ParentObject.find("actors", "vanilla")

local playerLoadouts = {}

callback.register("onGameEnd", function()
    playerLoadouts = {}
end)

local SyncLoadoutChange = net.Packet.new("Sync Loadout Change", function(player, slot, new)
    if player then
        if playerLoadouts[player] then
            local loadout = playerLoadouts[player]
            local skill = nil
            for _, skillEntry in pairs(loadout:getAllSlots()) do
                if new == skillEntry.displayName then
                    skill = skillEntry
                end
            end
            loadout:setCurrentSkill(slot, skill)
            if not playerLoadouts[player] then
                playerLoadouts[player] = loadout
            end
            Loadout.Apply(loadout, player, slot)
        end
    end
end)

local SyncLaunchButtonClick = net.Packet.new("Sync Launch Click", function(player, locked, proceed2)
    if player then
        local m = menu:find(1)
        local data = m:getData()
        data.locked[player] = locked
        if proceed2 then
            data.proceed2 = proceed2
        end
    end
end)

menu:addCallback("create", function(self)
    local data = self:getData()
    local players = 0
    playerLoadouts = {}
    for _, player in ipairs(misc.players) do
        if Loadout.findFromSurvivor(player:getSurvivor()) then
            playerLoadouts[player] = Loadout.findFromSurvivor(player:getSurvivor())
            if player == net.localPlayer then
                playerLoadouts[player] = Loadout.Load(playerLoadouts[player])
            else
                for _, slot in pairs(playerLoadouts[player]:getAllSlots()) do
                    if net.host then
                        SyncLoadoutChange:sendAsHost("all", nil, player.id, slot.name, slot.current.displayName)
                    else
                        SyncLoadoutChange:sendAsClient(player.id, slot.name, slot.current.displayName)
                    end
                end
            end
        end
    end
    self.x = 0
    self.y = 0
    data.f = 0
    data.phase = 0
    data.loadout = nil
    data.ready = false
    data.playersReady = 0
    local w, h = graphics.getGameResolution()
    data.podX = (w - (w/4)) + 60
    data.podY = h/2
    data.podRumble = 1
    data.playerSprite = nil
    data.boxX = 25
    data.boxY = 100
    data.boxW = (w - w/4) - 50
    data.boxH = 24
    data.tooltipW = 150
    data.tooltipH = 64
    data.locked = {}
    for _, player in ipairs(misc.players) do
        data.locked[player] = false
    end
    if net.online then
        data.button = button1
    else
        data.button = button2
    end
    data.buttonSubimage = 1
    data.launchX = w/2
    data.launchY = h - (h/6)
    data.lockedInX = 20
    data.lockedInY = 20
    data.alpha = 1
    data.subimage = 2
    
    data.proceed = false
    data.proceed2 = false
end)
menu:addCallback("step", function(self)
    local data = self:getData()
    local player = nil
    if net.online then
        player = net.localPlayer
    else
        player = misc.players[1]
    end
    
    local count = 0
    local proceed = 0
    for _, player in ipairs(misc.players) do
        if Loadout.findFromSurvivor(player:getSurvivor()) then
            count = count + 1
            if data.locked[player] then
                proceed = proceed + 1
            end
        end
    end
    if proceed >= count then
        data.proceed = true
        if net.online and not data.proceed2 then
            data.proceed = false
        end
    end
    if count <= 0 then
        self:destroy()
        return
    end
    -------------------------------------------------
    if data.phase < 2 then
        -- "Freeze" game
        misc.hud:set("title_alpha", 0)
        misc.hud:set("show_skills", 0)
        misc.hud:set("show_gold", 0)
        misc.hud:set("show_time", 0)
        misc.hud:set("show_items", 0)
        misc.setTimeStop(2)
        misc.director:set("time_start", 0)
        misc.hud:set("second", 0)
        misc.hud:set("minute", 0)
        Sound.find("Watch", "vanilla"):stop()
        for _, player in ipairs(misc.players) do
            player:set("activity", 99)
            player:set("activity_type", 99)
            player.alpha = 0
        end
        ----------------
        data.f = data.f + 1
        if player and Loadout.findFromSurvivor(player:getSurvivor()) then
            if not data.color then
                data.color = player:getSurvivor().loadoutColor
                local avg = (data.color.red + data.color.blue + data.color.green)/3
                if avg > 200 then
                    data.color = Color.fromRGB(data.color.red * 0.85, data.color.blue * 0.85, data.color.green * 0.85)
                end
            end
            if not data.playerSprite then
                data.playerSprite = player:getSurvivor().loadoutSprite
            else
                if data.f > 30 then
                    if data.subimage < data.playerSprite.frames then
                        data.subimage = data.subimage + 0.2
                        if data.phase == 0 then
                            data.phase = 1
                        end
                    end
                end
            end
            if not data.loadout then
                data.loadout = playerLoadouts[player] or Loadout.findFromSurvivor(player:getSurvivor())
                Loadout.Load(data.loadout)
                local count = 0
                Loadout.Apply(data.loadout, player)
                for _, s in pairs(data.loadout.skillSlots) do
                    if s.showInLoadoutMenu then
                        count = count + 1
                    end
                end
                data.boxY = data.boxY - (data.boxH * (count/5))
            end
        else
            data.ready = true
            data.locked[player] = true
            --data.proceed = true
        end
        if data.proceed then
            local readyCount = 0
            local playerCount = 0
            for _, p in ipairs(misc.players) do
                if p:isValid() then
                    playerCount = playerCount + 1
                    if data.locked[p] then
                        readyCount = readyCount + 1
                    end

                end
            end
            if readyCount >= playerCount then
                data.f = 0
                data.phase = 2
                data.alpha = 1
            end
        end
    else
        if not data.temp then
            if player and Loadout.findFromSurvivor(player:getSurvivor()) then
                Loadout.Update(data.loadout)
            end
            for _, player in ipairs(misc.players) do
                player:set("activity", 0)
                player:set("activity_type", 0)
                player.alpha = 1
            end
            data.temp = true
        end
        misc.hud:set("title_alpha", 2)
        misc.hud:set("show_skills", 1)
        misc.hud:set("show_gold", 1)
        misc.hud:set("show_time", 1)
        misc.hud:set("show_items", 1)
        data.alpha = data.alpha - 0.015
        if data.alpha <= 0 then
            self:destroy()
        end
    end
    
end)
menu:addCallback("destroy", function(self)
    local data = self:getData()
    misc.setTimeStop(0)
end)

local reference = nil

callback.register("onGameEnd", function()
	reference = os.time()
end)

callback.register("onGameStart", function()
	-- This enables the menu if the game is not being started as part of a "retry"
	local timefrom = nil
	if reference then
		timefrom = os.difftime(os.time(), reference)
	end
	if timefrom and timefrom > 1 or not timefrom then
        local i = menu:create(0, 0)
	end
end)

local DrawSelectionBox = function(data, slot, index)
    local xx = data.boxX
    local yy = (data.boxY) + (data.boxH * 1.2) * index
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(xx, yy, xx + data.boxW, yy + data.boxH)
    graphics.alpha(1)
    graphics.color(Color.fromRGB(30, 17, 17))
    graphics.rectangle(xx, yy, xx + data.boxW, yy + data.boxH, true)
    graphics.color(data.color)
    graphics.rectangle(xx, yy, xx + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) + 4), yy + data.boxH)
    graphics.color(Color.WHITE)
    graphics.print(slot.name or "Information Unset", xx + 6, yy + (data.boxH / 2), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_CENTER)
    local loadout = data.loadout
    local skills = {}
    if loadout then
        local i = 0
        for _, skill in pairs(slot.skills) do
            if not skill.hidden then
                local sX = xx + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (i))
                local sY = yy + 3
                local image = mobSkills
                local subimage = 1
                if skill.icon and skill.subimage then
                    if skill.locked == false then
                        image = skill.icon
                        subimage = skill.subimage
                    else
                        subimage = 2
                    end
                else
                    subimage = 3
                end
                graphics.drawImage{
                    image = image,
                    x = sX,
                    y = sY,
                    subimage = subimage,
                }
                i = i + 1
            end
        end
    end
end

local DrawToolTip = function(data, skill, x, y)
    local yy = y + 10
    local desc = skill.loadoutDescription
    if not skill.loadoutDescription then
        desc = "Information Unset"
    end
    local descriptionFormatted = desc:gsub("&[%a%p%C]&", "")
    local tooltipW = math.clamp(graphics.textWidth(descriptionFormatted, graphics.FONT_DEFAULT) + 2, graphics.textWidth(skill.displayName, graphics.FONT_DEFAULT) + 2, graphics.textWidth(descriptionFormatted, graphics.FONT_DEFAULT) + 2)
    local tooltipH = (graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 4) + math.clamp(graphics.textHeight(descriptionFormatted, graphics.FONT_DEFAULT) + 2, graphics.textHeight(skill.displayName, graphics.FONT_DEFAULT) + 2, graphics.textHeight(descriptionFormatted, graphics.FONT_DEFAULT) + 2)
    graphics.color(Color.BLACK)
    graphics.alpha(0.5)
    graphics.rectangle(x, yy, x + tooltipW, yy + tooltipH)
    if skill.obj == Loadout.PresetSkills.Unfinished then
        
        graphics.color(Color.ORANGE)
    else
        graphics.color(data.color)

    end
    graphics.alpha(1)
    graphics.rectangle(x, yy, x + tooltipW, yy + graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 2)
    graphics.color(Color.WHITE)
    graphics.print(skill.displayName or "Information Unset", x + 5, yy + 4, graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
    local cooldown = ((skill.obj.cooldown or 0) / 60)
    if math.floor(cooldown) > 0 then
        graphics.print(math.round(cooldown) .. " sec. cooldown", x + tooltipW, yy + 4, graphics.FONT_DEFAULT, graphics.ALIGN_RIGHT, graphics.ALIGN_TOP)
    end
    graphics.print(descriptionFormatted, x + 5, yy + ((graphics.textHeight(skill.displayName or "Information Unset", graphics.FONT_DEFAULT) + 2) * 1.5), graphics.FONT_DEFAULT, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
end




callback.register("onHUDDraw", function()
    local self = menu:findNearest(0, 0)
    if self then
        local player = nil
        if net.online then
            player = net.localPlayer
        else
            player = misc.players[1]
        end
        local data = self:getData()
        local loadout = data.loadout
        local w, h = graphics.getGameResolution()
        graphics.color(Color.BLACK)
        graphics.alpha(data.alpha / 2)
        graphics.rectangle(0, 0, w, h)
        if data.phase < 2 then
            ----------------------------------------------------------
            graphics.color(Color.BLACK)
            graphics.alpha(1)
            graphics.rectangle(0, 0, w, h * 0.2)
            graphics.rectangle(0,h * 0.8, w, h)
            ----------------------------------------------------------
            graphics.color(Color.WHITE)
            graphics.print("Choose Your Loadout", w/2, h/10, graphics.FONT_LARGE, graphics.ALIGN_MIDDLE, graphics.ALIGN_CENTER)
            ---------------------------------------------------------
            if Loadout.findFromSurvivor(player:getSurvivor()) then
                graphics.drawImage{
                    image = pod,
                    x = data.podX,
                    y = data.podY,
                }
                if player:getSurvivor().loadoutWide then
                    graphics.drawImage{
                        image = data.playerSprite,
                        x = data.podX - 24,
                        y = data.podY - 51,
                        subimage = data.subimage
                    }
                else
                    graphics.drawImage{
                        image = data.playerSprite,
                        x = data.podX - 12,
                        y = data.podY - 51,
                        subimage = data.subimage
                    }
                end
                local slots = {}
                local count = 0
                for _, slot in pairs(loadout.skillSlots) do
                    if slot.showInLoadoutMenu then
                        table.insert(slots, slot)
                        count = count + 1
                    end
                end
                table.sort(slots, function(a, b)
                if a.displayOrder < b.displayOrder then
                        return true
                    else
                        return false
                    end
                end)
                local i = 1
                for _, slot in pairs(slots) do
                    graphics.alpha(1)
                    DrawSelectionBox(data, slot, i)
                    local z = 1
                    for _, skill in pairs(slot.skills) do
                        if not skill.hidden then
                            local sX = data.boxX + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (z-1))
                            local sY = (data.boxY + (data.boxH * 1.2) * i) + 3
                            if slot.current ~= skill and not MouseHoveringOver(sX, sY, sX + 18, sY + 18) then
                                graphics.color(Color.BLACK)
                                graphics.alpha(0.5)
                                graphics.rectangle(sX, sY, sX+18, sY+18)
                            end
                            z = z + 1

                        end
                    end
                    i = i + 1
                end
                -----------------------------------------------------------
                if not data.locked[player] then
                    i = 1
                    for _, slot in pairs(slots) do -- Draw tooltips / take input for skills
                        local z = 0
                        for _, skill in pairs(slot.skills) do
                            if not skill.hidden then
                                local sX = data.boxX + (graphics.textWidth("Secondary", graphics.FONT_DEFAULT) * 1.25) + (22 * (z))
                                local sY = (data.boxY + (data.boxH * 1.2) * i) + 3
                                if MouseHoveringOver(sX, sY, sX + 18, sY + 18) then
                                    local mx, my = input.getMousePos(true)
                                    if not skill.locked then
                                        DrawToolTip(data, skill, mx, my)
                                    end
                                    if input.checkMouse("left") == input.PRESSED then
                                        if not skill.locked and skill.obj ~= underConstruction then
                                            if slot.name == "Passive" and slot.current and slot.current.remove then
                                                slot.current.remove(player)
                                            end
                                            slot.current = skill
                                            Loadout.Apply(data.loadout, player)
                                            if net.online then
                                                if net.host then
                                                    SyncLoadoutChange:sendAsHost("all", nil, player.id, slot.name, slot.current.displayName)
                                                else
                                                    SyncLoadoutChange:sendAsClient(player.id, slot.name, slot.current.displayName)
                                                end
                                            end
                                            if slot.name == "Skin" then
                                                data.playerSprite = skill.sprites["loadout"]
                                                data.subimage = 4
                                            end
                                            Loadout.Save(data.loadout)
                                        end
                                    end
                                end
                                z = z + 1

                            end
                        end
                        i = i + 1
                    end
                end
                
                -----------------------------------------------------------
                if data.phase == 1 then
                    if MouseHoveringOver(data.launchX - ((button1.width) / 2), data.launchY - ((button1.height) / 2), data.launchX + ((button1.width) / 2), data.launchY + ((button1.height)/ 2)) then
                        if not data.ready then
                            data.button = button2
                            if input.checkMouse("left") == input.HELD then
                                data.buttonSubimage = 3
                            elseif input.checkMouse("left") == input.RELEASED then
                                data.ready = true
                                sound:play()
                                for _, player in ipairs(misc.players) do
                                    if playerLoadouts[player] then
                                        Loadout.Apply(playerLoadouts[player], player)
                                    end
                                end
                                if net.online and net.host then
                                    data.buttonSubimage = 3
                                    data.locked[player] = true
                                    SyncLaunchButtonClick:sendAsHost("all", nil, player.id, data.locked[player])
                                else
                                    data.locked[player] = true
                                    if net.online and not net.host then
                                        SyncLaunchButtonClick:sendAsClient(player.id, data.locked[player])
                                    end
                                    data.buttonSubimage = 4
                                end
                            else
                                data.buttonSubimage = 2
                            end
                        else
                            data.button = button1
                            if net.host then
                                if input.checkMouse("left") == input.HELD then
                                    data.buttonSubimage = 3
                                elseif input.checkMouse("left") == input.RELEASED then
                                    data.locked[player] = true
                                    if net.online then
                                        data.proceed2 = true
                                        SyncLaunchButtonClick:sendAsHost("all", nil, player.id, data.locked[player], data.proceed2)
                                    end
                                else
                                    data.buttonSubimage = 2
                                end
                            else
                                data.buttonSubimage = 4
                            end
                        end
                    else
                        if not data.ready then
                            data.button = button2
                            data.buttonSubimage = 1
                        else
                            data.button = button1
                            if net.host then
                                data.buttonSubimage = 1
                            else
                                data.buttonSubimage = 4
                            end
                        end
                    end
                end
            end
            ---------------------------------------------------------
            graphics.drawImage{ --Draw the button
                image = data.button,
                x = data.launchX,
                y = data.launchY,
                subimage = data.buttonSubimage
            }
            ---------------------------------------------------------
            if net.online then
                for i, player in ipairs(misc.players) do
                    graphics.color(Color.BLACK)
                    graphics.alpha(0.5)
                    graphics.rectangle(data.lockedInX, data.lockedInY + (lockedIn.height * 1.5) * i, data.lockedInX + 100, (data.lockedInY + (lockedIn.height * 1.5) * i) + lockedIn.height + 4)
                    graphics.color(Color.WHITE)
                    graphics.alpha(1)
                    graphics.print(player:get("user_name"), data.lockedInX + 2, (data.lockedInY + (lockedIn.height * 1.5) * i) + 2, graphics.FONT_SMALL, graphics.ALIGN_LEFT, graphics.ALIGN_TOP)
                    if data.locked[player] then
                        graphics.drawImage{
                            image = lockedIn,
                            x = (data.lockedInX + 100) - (lockedIn.width + 2),
                            y = (data.lockedInY + (lockedIn.height * 1.5) * i) + 2,
                            subimage = 2,
                        }
                    else
                        graphics.drawImage{
                            image = lockedIn,
                            x = (data.lockedInX + 100) - (lockedIn.width + 2),
                            y = (data.lockedInY + (lockedIn.height * 1.5) * i) + 2,
                            subimage = 1,
                        }
                    end
                end
            end
            ---------------------------------------------------------
            -- Launch button graphics / functionality
            
        end
    else

    end
end)