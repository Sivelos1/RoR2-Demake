-- Titanic Plains

local sprites = {
    tileset = Sprite.load("TilePlains", "Graphics/tiles/titanic plains", 1, 0, 0),
    bg1 = Sprite.load("tPlainsBG1", "Graphics/backgrounds/tPlains1", 1, 0, 0),
    bg2 = Sprite.load("tPlainsBG2", "Graphics/backgrounds/tPlains2", 1, 0, 0),
}

local plains = require("Stages.rooms.plains")
plains.displayName = "Titanic Plains"
plains.subname = "Ground Zero"
plains.music = Music.Disdrometer

Stage.progression[1]:add(plains)

------------------------------------