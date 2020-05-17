--soulmelter

local icon = Sprite.load("SoulMelter", "Graphics/soulMelter", 3, 14, 14)

local exMode = Difficulty.new("difficultyEX")

exMode.displayName = "Soul Melter"
exMode.icon = icon
exMode.scale = 1
exMode.scaleOnline = 2
exMode.description = "&p&-SOUL MELTER-&!&\nThe ultimate challenge!\nWill you survive this ordeal?\n(Probably not.)"
exMode.enableMissileIndicators = false
exMode.forceHardElites = true
exMode.enableBlightedEnemies = true