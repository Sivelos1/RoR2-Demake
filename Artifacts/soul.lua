-- Artifact of Soul

local sprites = {
    menu = Sprite.load("Artifacts/soul", 2, 18, 18)
}

local ghostWisp = Artifact.new("Soul")
ghostWisp.unlocked = true
ghostWisp.loadoutSprite = sprites.menu
ghostWisp.loadoutText = "Wisps emerge from defeated monsters."