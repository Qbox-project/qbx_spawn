lib.versionCheck('Qbox-project/qbx_spawn')

lib.callback.register('qbx_spawn:server:getLastLocation', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    local queryResult = MySQL.single.await('SELECT position FROM players WHERE citizenid = ?', { player.PlayerData.citizenid })
    local position = json.decode(queryResult.position)
    local currentPropertyId = player.PlayerData.metadata.currentPropertyId

    return position, currentPropertyId
  end)

lib.callback.register('qbx_spawn:server:getProperties', function(source)
    if not GetResourceState('qbx_properties'):find('start') then
        return {}
    end

    local player = exports.qbx_core:GetPlayer(source)
    local houseData = {}
    local properties = MySQL.query.await('SELECT id, property_name, coords FROM properties WHERE owner = ?', { player.PlayerData.citizenid })

    for i = 1, #properties do
        local property = properties[i]

        houseData[#houseData + 1] = {
            label = property.property_name,
            coords = json.decode(property.coords),
            propertyId = property.id,
        }
    end

    return houseData
end)