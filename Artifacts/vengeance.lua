-- Artifact of Vengeance

local sprites = {
    menu = Sprite.load("Artifacts/vengeance", 2, 18, 18)
}

local shadowClone = Artifact.new("Vengeance")
shadowClone.unlocked = true
shadowClone.loadoutSprite = sprites.menu
shadowClone.loadoutText = "Your relentless doppelganger will invade every 10 minutes."