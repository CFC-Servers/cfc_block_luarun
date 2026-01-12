local hasLogger = false
if file.Exists( "includes/modules/logger.lua", "LUA" ) then
    require( "logger" )
    hasLogger = true
end

-- A spawnflag constant for addons
SF_LUA_RUN_ON_SPAWN = 1

ENT.Type = "point"
ENT.DisableDuplicator = true

AccessorFunc( ENT, "m_bDefaultCode", "DefaultCode" )

local ALLOWED_LUA, ALLOWED_MAPS = include( "cfc_block_luarun/config.lua" )
local CURRENT_MAP_ALLOWED = ALLOWED_MAPS[game.GetMap()]
local LOGGER = hasLogger and Logger( "CFC_BlockLuaRun" )
local MD5 = util.MD5

function ENT:Initialize()
    -- If the entity has its first spawnflag set, run the code automatically
    if self:HasSpawnFlags( SF_LUA_RUN_ON_SPAWN ) then
        self:RunCode( self, self, self:GetDefaultCode() )
    end
end

function ENT:KeyValue( key, value )
    if key == "Code" then
        self:SetDefaultCode( value )
    end
end

function ENT:SetupGlobals( activator, caller )
    ACTIVATOR = activator
    CALLER = caller

    if IsValid( activator ) and activator:IsPlayer() then
        TRIGGER_PLAYER = activator
    end
end

function ENT:KillGlobals()
    ACTIVATOR = nil
    CALLER = nil
    TRIGGER_PLAYER = nil
end

function ENT:RunCode( activator, caller, code )
    local hash = MD5( code )
    if not CURRENT_MAP_ALLOWED or not ALLOWED_LUA[hash] then
        if SERVER then
            if LOGGER then
                LOGGER:warn( "Blocked " .. game.GetMap() .. ' ' .. hash .. ' "' .. code .. '"' )
            else
                print( "[CFC_BlockLuaRun] Blocked " .. game.GetMap() .. ' ' .. hash .. ' "' .. code .. '"' )
            end
        end

        ErrorNoHaltWithStack( "[CFC_BlockLuaRun] Blocked " .. game.GetMap() .. ' ' .. hash .. ' "' .. code .. '"' )

        return
    end

    self:SetupGlobals( activator, caller )
    RunString( code, "lua_run#" .. self:EntIndex() )
    if LOGGER then
        LOGGER:debug( game.GetMap() .. ' <' .. hash .. '> "' .. code .. '"' )
    end
    self:KillGlobals()
end

function ENT:AcceptInput( name, activator, caller, data )
    if name == "RunCode" then self:RunCode( activator, caller, self:GetDefaultCode() ) return true end
    if name == "RunPassedCode" then self:RunCode( activator, caller, data ) return true end

    return false
end
