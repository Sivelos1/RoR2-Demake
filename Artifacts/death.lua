-- Artifact of Death

local sprites = {
    menu = Sprite.load("Artifacts/death", 2, 18, 18)
}

local teamKO = Artifact.new("Death")
teamKO.unlocked = true
teamKO.loadoutSprite = sprites.menu
teamKO.loadoutText = "When one player dies, everyone dies.\nEnable only if you want to truly put your teamwork\nand individual skill to the ultimate test."

callback.register("onPlayerDeath", function(player)
    if teamKO.active then
        for _, p in pairs(misc.players) do
            if p ~= player then
                p:set("hp", 0)
            end
        end
    end
end)