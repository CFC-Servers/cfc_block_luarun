-- A spawnflag constant for addons
SF_LUA_RUN_ON_SPAWN = 1

ENT.Type = "point"
ENT.DisableDuplicator = true

AccessorFunc( ENT, "m_bDefaultCode", "DefaultCode" )

function ENT:Initialize()
end

function ENT:KeyValue( key, value )
end

function ENT:SetupGlobals( activator, caller )
end

function ENT:KillGlobals()
end

function ENT:RunCode( activator, caller, code )
end

function ENT:AcceptInput( name, activator, caller, data )
	return false
end
