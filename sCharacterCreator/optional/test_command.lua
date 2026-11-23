--[[
    Optional test command.
    Add this line to meta.xml to enable it:
        <script src="optional/test_command.lua" type="server" />
    Requires an ACL group that has the "function.banPlayer" permission
    (Admins usually do).
]]

addCommandHandler("cc", function(player)
    if not hasObjectPermissionTo(player, "function.banPlayer", false) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end

    triggerClientEvent(player, "cc:start", player)
end)
