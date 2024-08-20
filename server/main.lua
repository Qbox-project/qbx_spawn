lib.callback.register('qbx_spawn:server:getLastLocation', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    return json.decode(MySQL.single.await('SELECT position FROM players WHERE citizenid = ?', {player.PlayerData.citizenid}).position), player.PlayerData.metadata.currentPropertyId
end)

lib.callback.register('qbx_spawn:server:getHouses', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    local houseData = {}
    local playerHouses = MySQL.query.await('SELECT house FROM player_houses WHERE citizenid = ?', {player.PlayerData.citizenid})
    for i = 1, #playerHouses do
        local name = playerHouses[i].house
        local locationData = MySQL.single.await('SELECT `coords`, `label` FROM houselocations WHERE name = ?', {name})
        houseData[#houseData + 1] = {
            label = locationData.label,
            coords = json.decode(locationData.coords).enter
        }
    end

    return houseData
end)
