--RoR2 Demake Project
--Made by N4K0
--main.lua
--File created 2019/04/07

-- Picked up by Sivelos

local debugMode = modloader.checkFlag("NIKO_DEBUG_ENABLE")

Music = {
    MainTheme = Sound.load("MainTheme", "Sounds/BGM/main_theme.ogg"),
    Dehydrated = Sound.load("Dehydrated", "Sounds/BGM/dehydrated.ogg"),
    Disdrometer = Sound.load("Disdrometer", "Sounds/BGM/disdrometer.ogg"),
    Evatransportation = Sound.load("Evatransportation", "Sounds/BGM/evatransportation.ogg"),
    Hydrophobia = Sound.load("Hydrophobia", "Sounds/BGM/hydrophobia.ogg"),
    IntoTheDoldrums = Sound.load("IntoTheDoldrums", "Sounds/BGM/into_the_doldrums.ogg"),
    KoppenAsFuck = Sound.load("KoppenAsFuck", "Sounds/BGM/koppen_as_fuck.ogg"),
    NocturnalEmission = Sound.load("NocturnalEmission", "Sounds/BGM/nocturnal_emission.ogg"),
    Parjanya = Sound.load("Parjanya", "Sounds/BGM/parjanya.ogg"),
    PetrichorV = Sound.load("PetrichorV", "Sounds/BGM/petrichor_v.ogg"),
    RaindropThatFellToTheSky = Sound.load("RaindropThatFellToTheSky", "Sounds/BGM/raindrop_that_fell_to_the_sky.ogg"),
    TerraPluviam = Sound.load("TerraPluviam", "Sounds/BGM/terra_pluviam.ogg"),
    ThermodynamicEquilibrium = Sound.load("ThermodynamicEquilibrium", "Sounds/BGM/thermodynamic_equilibrium.ogg"),
    AGlacierEventuallyFarts = Sound.load("AGlacierEventuallyFarts", "Sounds/BGM/glacierEventuallyFarts.ogg"),
}

--[[if debugMode then
	require("debug")
end]]--

local empty = Sprite.load("Empty", "Graphics/empty", 1, 0,0)
-- Libraries

local achieveIcons = {}

MakeAchievementIcon = function(sprite, subimage)
    local surface = Surface.new(sprite.width, sprite.height)
    graphics.setTarget(surface)
    graphics.drawImage{
    	image = sprite,
	    subimage = subimage,
    	x = 0,
	    y = 0
    }
    graphics.resetTarget()
    local dSprite = surface:createSprite(sprite.width/2, sprite.height/2)
    table.insert(achieveIcons, dSprite:finalize("achievementIcon"..#achieveIcons))
    return achieveIcons[#achieveIcons]
end


--Reskin title
require("misc.title")

--Other
require("Misc.teleporterSounds")
require("Misc.vignette")
require("Misc.flyingEnemy")
require("Misc.lunar")

-- Characters

local Actors = {
    -- Survivors
    "commando.commando",
    "huntress.huntress",
    "mercenary.merc",
    "engi.engi",
    "acrid.acrid",
    "loader.loader",
    "mult.mult",
    "artificer.artificer",
    "rex.rex",
    -- Allies / NPCs
    "playerBots",
    "tc280.tc280",
    "equipDrone.equipDrone",
    "newt.newt",
    -- Enemies
    "beetle.beetle",
    "beetleGuard.beetleGuard",
    "vulture.vulture",
    "templar.templar",
    "bell.bell",
    "reaver.reaver",
    -- Bosses
    "reliquary.reliquary",
    "scavenger.scavenger",
    "titan.titan",
    "vagrant.vagrant",
    "dunestrider.dunestrider",
    "roboball.roboball",
}
for _, char in ipairs(Actors) do
    local actor = require("Actors."..char)   
end

--Enemy Stuff
if not modloader.checkFlag("disable_enemy_changes") then
    require("Misc.enemyModifiers")
end
require("Misc.eliteModifiers")

-----------------------------------------------------------

local Items = {
    -- Rare
    "disc",
    "aegis",
    "novaOnHeal",
    "healingRack",
    "wakeOfVultures",
    "afterBurner",
    "catalyst",
    "meathook",
    "headstompers",
    "brainstalks",
    "clover",
    -- Uncommon
    "deathMark",
    "tome",
    "razorwire",
    "daisy",
    "guillotine",
    "warhorn",
    "stealthkit",
    "fireRing",
    "iceRing",
    "quail",
    "buckler",
    "fuelCell",
    "bandolier",
    "pauldron",
    -- Common
    "armorPlate",
    "meat",
    "crystal",
    "brooch",
    "shieldGen",
    "backupmag",
    "aprounds",
    "energyDrink",
    "key",
    -- Boss
    "knurl",
    "queensGland",
    "goldseed",
    "disciple",
    "genesisLoop",
    "pearl",
    -- Use Items
    "recycler",
    "elephant",
    "egg",
    "blastShower",
    "gateway",
    "hud",
    "chrysalis",
    "cube",
    "capacitor",
    "crowdfunder",
    "woodsprite",
    "bfg",
    "radar",
    "eliteAffix",
    "fuelArray",
}
for _, item in ipairs(Items) do
    local i = require("Items."..item)   
end
---------------------------------------
BossItems = ItemPool.new("boss")
BossItems.weighted = true
BossItems:add(Item.find("Burning Witness", "vanilla"))
BossItems:add(Item.find("Colossal Knurl", "vanilla"))
BossItems:add(Item.find("Ifrit's Horn", "vanilla"))
BossItems:add(Item.find("Imp Overlord's Tentacle", "vanilla"))
BossItems:add(Item.find("Legendary Spark", "vanilla"))
BossItems:add(Item.find("Nematocyst Nozzle", "vanilla"))
BossItems:add(Item.find("Queen's Gland", "RoR2Demake"))
BossItems:add(Item.find("Little Disciple", "RoR2Demake"))
BossItems:add(Item.find("Genesis Loop", "RoR2Demake"))
BossItems:add(Item.find("Halcyon Seed", "RoR2Demake"))
BossItems:setWeight(Item.find("Halcyon Seed", "RoR2Demake"), -99999)
BossItems:add(Item.find("Pearl", "RoR2Demake"))
BossItems:setWeight(Item.find("Pearl", "RoR2Demake"), -99999)
BossItems:add(Item.find("Irradiant Pearl", "RoR2Demake"))
BossItems:setWeight(Item.find("Irradiant Pearl", "RoR2Demake"), -99999)
BossItems:add(Item.find("Artifact Key", "RoR2Demake"))
BossItems:setWeight(Item.find("Artifact Key", "RoR2Demake"), -99999)
---------------------------------------

--Artifacts
local Artifacts = {
    "chaos",
    "death",
    "dissonance",
    "evolution",
    "frailty",
    "metamorphosis",
    "soul",
    "swarms",
    "vengeance",
}

for _, artifact in ipairs(Artifacts) do
    local a = require("Artifacts."..artifact)   
end

--Objects
local Objects = {
    "categoryChest",
    "mountainShrine",
    "obelisk",
    "printer",
    --"altarOfGold",
}
for _, obj in ipairs(Objects) do
    local o = require("Objects."..obj)   
end

--Stages
local Stages = {
    "roost",
    "plains",
    "void",
    "bazaar",
    "moment",
    "goldshores",
    "ambry",
}

for _, stage in ipairs(Stages) do
    local s = require("Stages."..stage)   
end

local enemiesByStage = {
    [Stage.find("Desolate Forest", "vanilla")] = {
        [0] = MonsterCard.find("Beetle", "RoR2Demake"),
        [1] = MonsterCard.find("Stone Titan", "RoR2Demake"),
    },
    [Stage.find("Dried Lake", "vanilla")] = {
        [0] = MonsterCard.find("Beetle", "RoR2Demake"),
    },
    [Stage.find("Titanic Plains", "RoR2Demake")] = {
        [0] = MonsterCard.find("Beetle", "RoR2Demake"),
        [1] = MonsterCard.find("Stone Titan", "RoR2Demake"),
    },
    -------------------------------------
    [Stage.find("Sky Meadow", "vanilla")] = {
        [0] = MonsterCard.find("Beetle", "RoR2Demake"),
        [1] = MonsterCard.find("Beetle Guard", "RoR2Demake"),
        [2] = MonsterCard.find("Brass Contraption", "RoR2Demake"),
    },
    [Stage.find("Damp Caverns", "vanilla")] = {
        [0] = MonsterCard.find("Stone Titan", "RoR2Demake"),
        [1] = MonsterCard.find("Brass Contraption", "RoR2Demake"),
    },
    -------------------------------------
    [Stage.find("Ancient Valley", "vanilla")] = {
        
    },
    [Stage.find("Sunken Tombs", "vanilla")] = {

    },
    -------------------------------------
    [Stage.find("Hive Cluster", "vanilla")] = {
        [0] = MonsterCard.find("Beetle Guard", "RoR2Demake"),
    },
    [Stage.find("Magma Barracks", "vanilla")] = {
        [0] = MonsterCard.find("Brass Contraption", "RoR2Demake"),
    },
    -------------------------------------
    [Stage.find("Risk of Rain", "vanilla")] = {
        [0] = MonsterCard.find("Beetle Guard", "RoR2Demake"),
        [1] = MonsterCard.find("Brass Contraption", "RoR2Demake"),
    },
}
for stage, list in pairs(enemiesByStage) do
    if stage then
        for i = 0, #list - 1 do
            if list[i] then
                stage.enemies:add(list[i])
            end
        end
    end
end

if modloader.checkFlag("ror2_debug") then
    local noEnemies = Artifact.new("Peace")
    noEnemies.unlocked = true
    noEnemies.loadoutSprite = Sprite.load("A","Artifacts/example artifact loadout", 2, 18, 18)
    noEnemies.loadoutText = "Disables enemy spawns."
    registercallback("onStep", function()
        if noEnemies.active then
            local director = misc.director
            director:set("points", 0)
        end
    end)

    local allEnemies = Artifact.new("Combat")
    allEnemies.unlocked = true
    allEnemies.loadoutSprite = Sprite.find("A", "RoR2Demake")
    allEnemies.loadoutText = "Encourages enemy spawns."
    registercallback("onStep", function()
        if allEnemies.active then
            local director = misc.director
            director:set("points", director:get("points") + 1)
        end
    end)
end