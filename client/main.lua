local synced, weatherFreeze = false, false
local weatherHour, lastWeatherHour = 0, 1
local loopInterval = 1000

local weatherForecast = {}
local weatherHash = {
    clear      = 0x36A83D84,
    EXTRASUNNY = 0x97AA0A79,
    CLOUDY     = 0x30FDAF5C,
    OVERCAST   = 0xBB898D2D,
    RAIN       = 0x54A69840,
    CLEARING   = 0x6DB1A50D,
    THUNDER    = 0xB677829F,
    SMOG       = 0x10DCF4B5,
    FOGGY      = 0xAE737644,
    XMAS       = 0xAAC9C895,
    SNOWLIGHT  = 0x23FB812B,
    BLIZZARD   = 0x27EA2814,
}


Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    TriggerServerEvent("rp_weather:request_current_weather")
    while not synced do
        Citizen.Wait(0)
    end
    TriggerEvent("rp_weather:override_current_weather")

    TriggerEvent('chat:addSuggestion', '/freezeweather', 'Freeze / unfreeze weather.')
end)


RegisterNetEvent("rp_weather:server_sync_weather")
AddEventHandler("rp_weather:server_sync_weather", function(interval, weather, freeze)
    loopInterval = interval
    weatherForecast = weather
    weatherFreeze = freeze
    synced = true
end)


AddEventHandler("rp_weather:override_current_weather", function()
	Citizen.CreateThread(function()
		while true do
            weatherHour = GetClockHours() + 1

            if weatherHour ~= lastWeatherHour and weatherForecast[weatherHour] ~= nil and not weatherFreeze then
                LogDebug(I18nTranslate('weather_forecast', {
                    primary=string.lower(weatherForecast[weatherHour]['primary']),
                    modifier=string.lower(weatherForecast[weatherHour]['modifier']),
                    rain=weatherForecast[weatherHour]['rain'],
                    wind=weatherForecast[weatherHour]['wind'],
                    windDirection=math.deg(weatherForecast[weatherHour]['windDirection'])
                }))

                if weatherForecast[lastWeatherHour]['primary'] ~= weatherForecast[weatherHour]['primary'] then
                    SetWeatherTypeOvertimePersist(weatherForecast[weatherHour]['primary'], 15.0)
                    Citizen.Wait(15000)
                end

                ClearOverrideWeather()
                ClearWeatherTypePersist()
                SetWeatherTypePersist(weatherForecast[weatherHour]['primary'])
                SetWeatherTypeNow(weatherForecast[weatherHour]['primary'])
                SetWeatherTypeNowPersist(weatherForecast[weatherHour]['primary'])

                SetWeatherTypeTransition(
                    weatherHash[weatherForecast[weatherHour]['primary']],
                    weatherHash[weatherForecast[weatherHour]['modifier']],
                    weatherForecast[weatherHour]['ratio']
                )

                SetRainLevel(weatherForecast[weatherHour]['rain'])
                SetWind(weatherForecast[weatherHour]['wind'])
                SetWindDirection(weatherForecast[weatherHour]['windDirection'])
                lastWeatherHour = weatherHour
            end

            Citizen.Wait(loopInterval)
		end
	end)
end)
