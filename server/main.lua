lib.versionCheck('Qbox-project/qbx_spawn')

local lastRequests = {}

local function isRateLimited(source, callbackName)
    local now = os.time()
    local requests = lastRequests[source]

    if not requests then
        requests = {}
        lastRequests[source] = requests
    elseif requests[callbackName] == now then
        return true
    end

    requests[callbackName] = now
    return false
end

local function isFiniteNumber(value)
    return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
end

local function decodeCoords(encodedCoords)
    if type(encodedCoords) ~= 'string' then return end

    local success, coords = pcall(json.decode, encodedCoords)
    if not success or type(coords) ~= 'table' then return end
    if not isFiniteNumber(coords.x) or not isFiniteNumber(coords.y) or not isFiniteNumber(coords.z) then return end
    if coords.w ~= nil and not isFiniteNumber(coords.w) then return end

    return coords
end

lib.callback.register('qbx_spawn:server:getLastLocation', function(source)
    if isRateLimited(source, 'lastLocation') then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local queryResult = MySQL.single.await('SELECT position FROM players WHERE citizenid = ?', { player.PlayerData.citizenid })
    if not queryResult then return end

    local position = decodeCoords(queryResult.position)
    if not position then return end

    local currentPropertyId = player.PlayerData.metadata.currentPropertyId

    return position, currentPropertyId
end)

lib.callback.register('qbx_spawn:server:getProperties', function(source)
    if not GetResourceState('qbx_properties'):find('start') then
        return {}
    end

    if isRateLimited(source, 'properties') then return {} end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {} end

    local houseData = {}
    local properties = MySQL.query.await('SELECT id, property_name, coords FROM properties WHERE owner = ?', { player.PlayerData.citizenid }) or {}

    for i = 1, #properties do
        local property = properties[i]
        local coords = decodeCoords(property.coords)

        if coords then
            houseData[#houseData + 1] = {
                label = property.property_name,
                coords = coords,
                propertyId = property.id,
            }
        end
    end

    return houseData
end)

AddEventHandler('playerDropped', function()
    lastRequests[source] = nil
end)
