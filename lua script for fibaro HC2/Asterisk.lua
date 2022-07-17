--[[
%% autostart
%% properties
%% weather
%% events
%% globals
--]]



-- *****************************************************************************************
-- *                               ACS | Advanced Control System                           *
-- *                    This Script Was written by developers In R&D department            *
-- *****************************************************************************************
-- *    Titel       :   asterisk script for time trigger                                   *
-- *    platform    :   Home Center 2                                                      *
-- *    vertion     :   V1.0                                                               *
-- *    date        :   July 10_th, 2022                                                   *
-- *    discretion  :   Script compatible with time Trigger                                *
-- *****************************************************************************************




function MyScript()
    -- *****************************************************************
    --                    write your script here                       *
    -- *****************************************************************

    local Empty = nil;
    --start writing
    

end


-- **********************************************************************
--                     Configuare Parameter                             *
--          set the Time and days for trigger the script                *
-- **********************************************************************
local TriggerTime = "01:30";
local Monday    =  1;   -- set value to nil or 1
local Tuesday   =  2;   -- set value to nil or 2
local Wednesday =  3;   -- set value to nil or 3
local Thursday  =  4;   -- set value to nil or 4
local Friday    =  5;   -- set value to nil or 5
local Saturday  =  6;   -- set value to nil or 6
local Sunday    =  7;   -- set value to nil or 7

--*********************************************************************************************************
--*************************************************C*******************************************************
--*************************************************o*******************************************************
--*************************************************d*******************************************************
--*************************************************e*******************************************************
--*********************************************************************************************************
local ToDay     = currentDate.wday;
local sourceTrigger = fibaro:getSourceTrigger();

function tempFunc()
    local currentDate = os.date("*t");
    local startSource = fibaro:getSourceTrigger();
    if (((
            (  ToDay == Monday 
            or ToDay == Tuesday
            or ToDay == Wednesday 
            or ToDay == Thursday 
            or ToDay == Friday 
            or ToDay == Saturday 
            or ToDay == Sunday  ) 

            and string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == TriggerTime)
        )
    ) 
    then
        MyScript();
    end

    setTimeout(tempFunc, 60*1000)
end

if (sourceTrigger["type"] == "autostart") then
    tempFunc()

else
    local currentDate = os.date("*t");
    local startSource = fibaro:getSourceTrigger();
    
    if (startSource["type"] == "other") then
        MyScript();
    end

end

--*********************************************************************************************************
--*************************************************C*******************************************************
--*************************************************o*******************************************************
--*************************************************d*******************************************************
--*************************************************e*******************************************************
--*********************************************************************************************************