
Portal = {}

local tpGateway = Object.new("Portal")
local gateFX = Sprite.load("TPGateway", "Graphics/tpGateway", 1, 22, 24)
local mask = Sprite.load("Graphics/gatewayMask", 1, 20.5, 20.5)

local tpSpark = ParticleType.find("TeleporterSpark", "RoR2Demake")

local player = Object.find("P", "vanilla")
local teleporter = Object.find("Teleporter", "vanilla")


tpGateway:addCallback("create", function(self)
    local data = self:getData()
    data.f = 0
    self.blendColor =  Color.fromRGB(math.random(255), math.random(255), math.random(255))
    data.blendMode = "additive"
    data.rate = 1
    data.destination = nil
    data.sizeRate = 0.01
    data.text = "&w&Press &y&'"..input.getControlString("enter").."'&w& to enter the Portal.&!&"
    if math.random() < 0.5 then
        data.rotateScale = -1
    else
        data.rotateScale = 1
    end
    self.mask = mask
    self.xscale = 0
    self.yscale = 0
    data.activity = 0
end)
tpGateway:addCallback("step", function(self)
    local data = self:getData()
    data.f = data.f + data.rate
    if data.f % 15 == 0 then
        tpSpark:burst("above", self.x + math.random(-gateFX.width/2, gateFX.width/2), self.y + math.random(-gateFX.width/2, gateFX.width/2), 1, self.blendColor)
    end
    if data.activity == 0 then
        if self.xscale < 1 then --Make my monster grow
            self.xscale = self.xscale + data.sizeRate
            self.yscale = self.yscale + data.sizeRate
        end
        if self.xscale >= 1 then
            data.activity = 1
        end
    elseif data.activity == 1 then
        local closestP = player:findNearest(self.x, self.y)
        if closestP and closestP:isValid() then
            if self:collidesWith(closestP, self.x, self.y) then
                data.displayText = true
                if input.checkControl("enter", closestP) == input.PRESSED then
                    local tpInst = teleporter:create(self.x, self.y)
                    tpInst.sprite = Sprite.find("Empty", "RoR2Demake")
                    tpInst:getData().noEffects = true
                    tpInst:set("active", 4)
                    data.activity = 2
                end
            else
                data.displayText = false
            end
        end

    end
end)
tpGateway:addCallback("draw", function(self)
    local data = self:getData()
    --Draw the actual portal
    graphics.alpha(0.7 + math.random() * 0.2)
    if data.sprite then
        if self.xscale >= 1 then
            graphics.drawImage{
                image = data.sprite,
                x = self.x,
                y = self.y,
                subimage = self.subimage,
                xscale = (math.sin(data.f/10)/10) + 1,
                yscale = (math.cos(data.f/10)/10) + 1,
            }
        else
            graphics.drawImage{
                image = data.sprite,
                x = self.x,
                y = self.y,
                subimage = self.subimage,
                xscale = self.xscale,
                yscale = self.yscale,
            }
        end
    else
        graphics.color(self.blendColor)
        graphics.circle(self.x - 1, self.y - 1, 18 * self.xscale, false)
    end
    
    graphics.alpha(1)
    graphics.drawImage{
        image = gateFX,
        x = self.x,
        y = self.y,
        color = self.blendColor,
        angle = ((data.f / 2) % 360) * -data.rotateScale,
        xscale = self.xscale * 0.9,
        yscale = self.yscale * 0.9,
    }
    graphics.setBlendMode(data.blendMode)
    graphics.drawImage{
        image = gateFX,
        x = self.x,
        y = self.y,
        color = self.blendColor,
        angle = (data.f % 360) * data.rotateScale,
        xscale = self.xscale,
        yscale = self.yscale,
    }
    graphics.setBlendMode("normal")
    if data.activity == 1 and data.displayText then
        local textFormatted =  data.text:gsub("&[%a%p%C]&", "")
        graphics.printColor(data.text, self.x - (graphics.textWidth(textFormatted, graphics.FONT_DEFAULT)/2), self.y - self.mask.height, graphics.FONT_DEFAULT)
    end
end)


local portalMask = Sprite.load("EfPortalMask", "Graphics/portalMask", 1, 5, 27)

local MapObject = require("Libraries.mapObjectLib")
local teleporter = Object.find("Teleporter", "vanilla")
local orbTravelRadius = 10
local portalRadius = 10 -- The distance from the teleporter that the game will pick suitable ground for the portal to be spawned.

local variables = {
    ["prefix"] = "string", -- The "name" of the portal and the orb. Example: "Blue" Portal, "Celestial" Orb.
    ["portalSprite"] = "Sprite", -- The portal's sprite.
    ["orbSprite"] = "Sprite", -- The orb's sprite.
    ["destination"] = "string", -- The display name of the stage the portal takes you to.
}

local groundTypes = {
    "B",
    "BNoSpawn",
    "BNoSpawn2",
    "BNoSpawn3",
}

Portal.new = function(variables)
    local newOrb = Object.new("Ef"..variables.prefix.."Orb")
    newOrb:addCallback("create", function(self)
        self.sprite = variables.orbSprite
        local boundTo = teleporter:findNearest(self.x, self.y)
        self.depth = boundTo.depth - 1
        self:set("i", 0)
        local data = self:getData()
        data.portal = newPortal
        data.madePortal = {}
    end)
    newOrb:addCallback("step", function(self)
        local data = self:getData()
        local boundTo = teleporter:findNearest(self.x, self.y)
        self:set("i", (self:get("i") + 1) % (2*((5*orbTravelRadius) * math.pi)))
        self.x = boundTo.x + ((orbTravelRadius*math.sin(self:get("i")/(orbTravelRadius*5))))
        self.y = boundTo.y - (boundTo.sprite.height / 2)
        if boundTo:get("time") == boundTo:get("maxtime") and not data.madePortal[self] then
            local spawn
            local choices = {}
            for _, groundType in ipairs(groundTypes) do
                for _, groundInst in ipairs(Object.find(groundType, "vanilla"):findAllEllipse(boundTo.x - portalRadius, boundTo.y - portalRadius, boundTo.x + portalRadius, boundTo.y + portalRadius)) do
                    table.insert(choices, groundInst)
                end
            end
            if choices then
                spawn = table.random(choices)
            end
        end
    end)
    return newOrb
end

export("Portal")
return Portal