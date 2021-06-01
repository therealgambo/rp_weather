local clientLoopInterval = 15000
local freezeWeather = false
local weatherForecast = {}
local mainWeatherSets = {'clear', 'clear_cloudy', 'clouds', 'clouds_rain', 'rain'}
local weatherSets = {

    clear = {
        primary = {"CLEAR", "EXTRASUNNY"},
        modifiers = {"CLEAR", "EXTRASUNNY"}
    },

    clear_cloudy = {
        primary = {"CLEAR", "EXTRASUNNY", "CLOUDS"},
        modifiers = {"SMOG", "FOGGY", "OVERCAST"}
    },

    clouds = {
        primary = {"CLOUDS", "OVERCAST", "THUNDER"},
        modifiers = {"SMOG", "FOGGY", "CLEARING"}
    },

    clouds_rain = {
        primary = {"CLOUDS", "OVERCAST", "RAIN", "THUNDER"},
        modifiers = {"SMOG", "FOGGY", "CLEARING"}
    },

    rain = {
        primary = {"RAIN", "CLEARING", "THUNDER"},
        modifiers = {"SMOG", "FOGGY", "CLOUDS"}
    }

}


RegisterServerEvent("rp_weather:request_current_weather")
AddEventHandler("rp_weather:request_current_weather", function()
	TriggerClientEvent("rp_weather:server_sync_weather", source, clientLoopInterval, weatherForecast, freezeWeather)
end)


local function generateWeatherForecast(previousWeatherSet)
    local randomWeatherSet = mainWeatherSets[math.random(1, #mainWeatherSets)]
    local randomWeatherSetPrimary = weatherSets[randomWeatherSet]['primary'][math.random(1, #weatherSets[randomWeatherSet]['primary'])]
    local randomWeatherSetModifier = weatherSets[randomWeatherSet]['modifiers'][math.random(1, #weatherSets[randomWeatherSet]['modifiers'])]
    local modifierRatio = RandomDecimal(0.3, 0.7, 1)
    local rainRatio = 0
    local randomWindSpeed = math.random(0,100)
    local randomWindDirection = math.rad(RandomDecimal(0, 360, 1))

    if randomWeatherSetPrimary == "RAIN" then
        rainRatio = RandomDecimal(0.5, 1, 1)
    elseif randomWeatherSetPrimary == "THUNDER" then
        rainRatio = RandomDecimal(0.7, 1, 1)
        randomWeatherSetModifier = "RAIN"
    end

    return {
        primary = randomWeatherSetPrimary,
        modifier = randomWeatherSetModifier,
        ratio = modifierRatio,
        rain = rainRatio,
        wind = randomWindSpeed,
        windDirection = randomWindDirection
    }
end


Citizen.CreateThread(function()
    -- TODO: get time multiplier from rp_gametime so we can generate and map in-game hours to
    --       realtime hours. Implemented with the assumption that the server will be restarted
    --       at a frequent interval. eg: 12hrs (realtime)
    for i = 0,23,1 do -- 0,23 here indicates 24 hours of in-game time (1 whole day)
        table.insert(weatherForecast, generateWeatherForecast())
    end
end)

-- TODO: add ACE permissions
RegisterCommand('freezeweather', function()
    freezeWeather = not freezeWeather
    LogDebug(I18nTranslate('weather_frozen', {is_frozen=tostring(freezeWeather)}))
    TriggerClientEvent("rp_weather:server_sync_weather", -1, clientLoopInterval, weatherForecast, freezeWeather)
end, false)
