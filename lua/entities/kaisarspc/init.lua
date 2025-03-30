AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("KaisarToggleRadar")

function ENT:Initialize()
    self:SetModel( "models/props_lab/monitor01a.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self.radarActive = false
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use( activator, caller )
    if activator:IsPlayer() then
        self.radarActive = not self.radarActive
        net.Start("KaisarToggleRadar")
        net.WriteEntity(self)
        net.WriteBool(self.radarActive)
        net.Send(activator)
    end
end