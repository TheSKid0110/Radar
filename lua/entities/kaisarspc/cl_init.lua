include("shared.lua")

local function ReturnAngle(v1, v2, entityAng)
    local localPos = WorldToLocal(v2, Angle(0, 0, 0), v1, entityAng)
    local angle = math.deg(math.atan2(localPos.y, localPos.x))
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

local redDots = {}

function ENT:Draw()
    self:DrawModel()
    local pos = self:GetPos() + self:GetForward() * 12.38 + self:GetUp() * 3
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(), 94)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 180)

    cam.Start3D2D(pos, ang, 0.09)
        local radarAngle = ((CurTime() * 100)) % 360
        surface.SetMaterial(Material("radar.jpg"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(-100, -110, 200, 200)
        surface.SetMaterial(Material("radar_sweep.png"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(0, -10, 200, 180, radarAngle)

        for _, v in pairs(ents.FindInSphere(self:GetPos(), 3000)) do
            if v:IsPlayer() and v:Alive() then
                local playerPos = v:GetPos()
                local radarPos = self:GetPos()
                local radarAng = self:GetAngles()

                local localPos = WorldToLocal(playerPos, Angle(0, 0, 0), radarPos, radarAng)

                local scale = 200 / 3000
                local x = localPos.y * scale
                local y = localPos.x * scale

                local playerAngle = (ReturnAngle(radarPos, playerPos, radarAng) + 180) % 360

                local sweepWidth = 10
                if math.abs(math.AngleDifference(radarAngle, playerAngle)) <= sweepWidth then
                    if math.abs(x) <= 100 and math.abs(y) <= 100 then
                        local exists = false
                        for _, dot in ipairs(redDots) do
                            if dot.x == x and dot.y == y then
                                exists = true
                                break
                            end
                        end

                        if not exists then
                            table.insert(redDots, {x = x, y = y, alpha = 255})
                            local distance = LocalPlayer():GetPos():Distance(self:GetPos())
                            if distance <= 300 then
                                local volume = 1 - (distance / 3000)
                                surface.PlaySound("common/warning.wav", volume)
                            end
                        end
                    end
                end
            end
        end

        for i = #redDots, 1, -1 do
            local dot = redDots[i]
            dot.alpha = dot.alpha - 5
            if dot.alpha <= 0 then
                table.remove(redDots, i)
            end
        end
        
        for _, dot in ipairs(redDots) do
            surface.SetMaterial(Material("red_dot.png"))
            surface.SetDrawColor(255, 0, 0, dot.alpha)
            surface.DrawTexturedRect(dot.x - 4, dot.y - 4, 8, 8)
        end
    cam.End3D2D()
end