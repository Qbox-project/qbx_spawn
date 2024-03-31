lib.callback.register('qbx_spawn:callback:getLastLocation', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    return json.decode(MySQL.single.await('SELECT position FROM players WHERE citizenid = ?', {player.PlayerData.citizenid}).position)
end)
