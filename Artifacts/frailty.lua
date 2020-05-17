-- Artifact of Frailty

local sprites = {
    menu = Sprite.load("Artifacts/frailty", 2, 18, 18)
}

local weakassKnees = Artifact.new("Frailty")
weakassKnees.unlocked = true
weakassKnees.loadoutSprite = sprites.menu
weakassKnees.loadoutText = "Fall damage is doubled and lethal."