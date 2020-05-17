-- Distant Roost

local sprites = {
    sky = Sprite.load("RoostSky", "Graphics/backgrounds/Sky", 1, 0, 0),
    skyNoSun = Sprite.load("RoostSky2", "Graphics/backgrounds/skyNoSun", 1, 0, 0),
    clouds1 = Sprite.load("RoostClouds1", "Graphics/backgrounds/RoostClouds", 1, 0, 0),
    clouds2 = Sprite.load("RoostClouds2", "Graphics/backgrounds/RoostClouds2", 1, 0, 0),
    clouds3 = Sprite.load("RoostClouds3", "Graphics/backgrounds/whiteClouds", 1, 0, 0),
}

local roost = require("Stages.rooms.roost")
roost.displayName = "Distant Roost"
roost.subname = "Ground Zero"
roost.music = Music.Disdrometer

Stage.progression[1]:add(roost)

------------------------------------