-- A spawnflag constant for addons
SF_LUA_RUN_ON_SPAWN = 1

ENT.Type = "point"
ENT.DisableDuplicator = true

AccessorFunc( ENT, "m_bDefaultCode", "DefaultCode" )

function ENT:Initialize()

	-- If the entity has its first spawnflag set, run the code automatically
	if ( self:HasSpawnFlags( SF_LUA_RUN_ON_SPAWN ) ) then
		self:RunCode( self, self, self:GetDefaultCode() )
	end

end

function ENT:KeyValue( key, value )

	if ( key == "Code" ) then
		self:SetDefaultCode( value )
	end

end

function ENT:SetupGlobals( activator, caller )

	ACTIVATOR = activator
	CALLER = caller

	if ( IsValid( activator ) and activator:IsPlayer() ) then
		TRIGGER_PLAYER = activator
	end

end

function ENT:KillGlobals()

	ACTIVATOR = nil
	CALLER = nil
	TRIGGER_PLAYER = nil

end

function ENT:RunCode( activator, caller, code )

	local whitelist = util.JSONToTable( file.Read( "cfc_map_luarun_whitelist.json", "DATA" ) )
	
	if not whitelist.allowedMaps[game.GetMap()] or not whitelist.allowedLua[code] then return end

	self:SetupGlobals( activator, caller )
	RunString( code, "lua_run#" .. self:EntIndex() )
	self:KillGlobals()

end

function ENT:AcceptInput( name, activator, caller, data )

	if ( name == "RunCode" ) then self:RunCode( activator, caller, self:GetDefaultCode() ) return true end
	if ( name == "RunPassedCode" ) then self:RunCode( activator, caller, data ) return true end

	return false

end