--[[
%% properties
(Motion_sensor_id) value
(Motion_sensor_id) value
(Motion_sensor_id) value
(Motion_sensor_id) value
(Motion_sensor_id) value
%% weather
%% events
%% globals
--]]

-- *****************************************************************************************
-- *                               ACS | Advanced Control System                           *
-- *                    This Script Was written by developers In R&D department            *
-- *****************************************************************************************
-- *    Titel       :   MS_autoLights                                                      *
-- *    platform    :   Home Center 2                                                      *
-- *    vertion     :   V1.0                                                               *
-- *    date        :   July 10_th, 2022                                                   *
-- *    discretion  :   Turn oFF and Turn On light in any area based on your motion        *
-- *****************************************************************************************

--*********************************************************************************************************
--*************************************************C*******************************************************
--*************************************************o*******************************************************
--*************************************************d*******************************************************
--*************************************************e*******************************************************
--*********************************************************************************************************
local MSValue
local TurnOnTime = 5
local motionSensorList [5] = {100,101,102,103,105}
local lightList [4] = {10,20,30,40}
local trigger = fibaro:getSourceTrigger()

if trigger["type"] == "other" then
	fibaro:debug("The Scene is Invoked manually.")
	fibaro:abort()
end


for MS in motionSensorList do
    MSValue = fibaro:getValue(MS, 'value')
    if (MSValue == '1') then
        for Light in lightList do
            fibaro:call(Light, 'turnOn')
        end
        fibaro:debug("lights is on")
        
        fibaro:sleep(TurnOnTime*60*1000)
        
        for Light in lightList do
            fibaro:call(Light, 'turnOff')
        end
        fibaro:debug("lights is off")
        fibaro:abort()
    end
end

--*********************************************************************************************************
--*************************************************C*******************************************************
--*************************************************o*******************************************************
--*************************************************d*******************************************************
--*************************************************e*******************************************************
--*********************************************************************************************************