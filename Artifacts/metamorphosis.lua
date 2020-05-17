-- Artifact of Metamorphosis

local sprites = {
    menu = Sprite.load("Artifacts/metamorphosis", 2, 18, 18)
}

local characterSwap = Artifact.new("Metamorphosis")
characterSwap.unlocked = true
characterSwap.loadoutSprite = sprites.menu
characterSwap.loadoutText = "Players always spawn as a random survivor."