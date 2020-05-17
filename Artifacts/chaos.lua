-- Artifact of Chaos

local sprites = {
    menu = Sprite.load("Artifacts/chaos", 2, 18, 18),
    pickup = Sprite.load("ArtifactChaos", "Artifacts/pickups/chaos", 1, 16, 16)
}

local friendlyFire = Artifact.new("Chaos")
friendlyFire.unlocked = true
friendlyFire.loadoutSprite = sprites.menu
friendlyFire.pickupSprite = sprites.pickup
friendlyFire.loadoutText = "Friendly fire is enabled for both survivors and monsters alike."

local actors = ParentObject.find("actors", "vanilla")

callback.register("onStep", function()
    for _, actor in ipairs(actors:findAll()) do
        if actor and actor:isValid() then
            local team = actor:get("team")
            local id = ("-"..tostring(actor.id))
            local var = string.find(team, id)
            if friendlyFire.active then
                if not var then
                    actor:set("team", team..id) --give actor unique team (base team + id)
                end
            else
                if var then
                    actor:set("team", string.gsub(actor:get("team"), id, "")) -- reset changes made by artifact
                end
            end
        end
    end
end)