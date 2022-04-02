hook.Add( "AcceptInput", "CFC_BlockLuaRun", function( ent )
    if ent:GetClass() == "lua_run" then
        return true
    end
end )