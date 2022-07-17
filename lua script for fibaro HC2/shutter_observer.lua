local DeviceChange 						= false


-- Tables
local DeadNodesTableOld 				= {}
local DeadNodesTableNew 				= {}
local AliveNodes 						= {}


-- Email Message Strings
local DeadNodesStr 						= ''
local NewDeadNodesStr 					= ''
local NodesAliveStr 					= ''
local IgnoredDevicesStr 				= ''
local message 							= ''
local title 							= 'Dead Nodes Report'


-- HTML Strings for option e-mail in HTML
local HTMLInitiate						=
'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"><HTML><HEAD><TITLE>'..
title..'</TITLE></HEAD><BODY><H2>Dead nodes</H2><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="5">'

local HTMLStartStr						=
[[<TR>
<TH>Device ID</TH>
<TH>Device Name</TH>	
<TH>Room</TH>
</TR>]]

local HTMLEndStr						= "</TABLE></BODY></HTML>"


-------------------------- CODE --------------------------

-- Debug to see start table
if deBug == true then
  logbug("white", '--- SCENE INITIALISED ---')
  logbug("green", 'Table at Start:')
  logbug("green", fibaro:getGlobalValue('DeadNodes'))
end


-- Put Global Variable into Local Table
if type(json.decode(fibaro:getGlobalValue('DeadNodes'))) == 'table' then
  DeadNodesTableOld = json.decode(fibaro:getGlobalValue('DeadNodes'))
end


-- loop through existing table to see whether there are new nodes
-- which are not in the table yet
for CurNr,CurID in ipairs(fibaro:getDevicesId(
  											  {visible=true,
      										   properties={dead=true} 
    										  }
  						 )                   ) 
do
  for OldNr,OldID in ipairs(DeadNodesTableOld) 
  do
    if OldID == CurID then
      NodeAlreadyDead = true
    end
  end


  -- Check whether we already tried to wake the node before, 
  -- if not then try to wake it and add to Table of Dead Nodes
  if NodeAlreadyDead == false then

    IgnoreDeviceBoolean = false
    --Check if IgnoreDevices is used
    if IgnoreDevices then
      for IgnoreNr, IgnoreDevice in pairs(IgnoreDevices)
      do
        -- Set IgnoreDeviceBoolean to true if the device needs to be ignored
        if IgnoreDevice == CurID then
          IgnoreDeviceBoolean = true
        end
      end
    end
    -- If device should not be ignored, then wake it.
    if IgnoreDeviceBoolean == false then
      if deBug == true then
      	logbug("darkgrey", 'Wake Up Dead Device: ' .. CurID)
      end
      -- Check if user wants to wake devices
      -- If yes, then wake device
      if WakeDeadDevices == true then
        api.post("/devices/"..CurID.."/action/wakeUpDeadDevice")
      end
      table.insert(DeadNodesTableOld, CurID)
      table.insert(DeadNodesTableNew, CurID)
      RequestUpdate = true
      DeviceChange = true
    end

  else
    NodeAlreadyDead = false
  end

end


if DeviceChange == false then
  if deBug == true then
  	logbug("darkgrey",'No devices have been added to the list')
  end
else
  DeviceChange = false
end


--Check list after adding devices
if deBug == true then
  logbug("green",'Table After Adding Devices to List:')
  logbug("green",json.encode(DeadNodesTableOld))
end


-- Wait for 5 seconds before rechecking dead status
fibaro:sleep(5*1000)


-- Check whether there are devices in the table which were dead but might be alive again.
-- if alive, delete them from the table
for OldNr,OldID in ipairs(DeadNodesTableOld) 
do
  for CurNr,CurID in ipairs(fibaro:getDevicesId(
										        {visible=true,
        										 properties={dead=true} 
      											}
					       )				   ) 
  do
    if OldID == CurID then
      NodeAlreadyDead = true
    end
  end

  if NodeAlreadyDead == false then
    if deBug == true then
	  logbug("darkgrey",'Remove live device from list: ' .. OldID)
  	end
    DeadNodesTableOld[OldNr] = nil
    table.insert(AliveNodes, OldID)
    DeviceChange = true
  else 
    NodeAlreadyDead = false
  end 
end

if DeviceChange == false then
  if deBug == true then
    logbug("darkgrey",'No devices have come back to life')
  end
else
  DeviceChange = false
end


--Check list after deleting devices
if deBug == true then
  logbug("green",'Table After Deleting Devices From List:')
  logbug("green",json.encode(DeadNodesTableOld))
end

-- Fill Global Variable with current set of dead nodes
fibaro:setGlobal("DeadNodes", json.encode(DeadNodesTableOld))

--Make String for Dead Device Table
if EmailType == 0 then
  DeadNodesStr = ''
else
  DeadNodesStr = '<TR><TH COLSPAN="4">--- THE FOLLOWING DEVICES ARE DEAD ---</TH></TR>' .. HTMLStartStr
end

if #DeadNodesTableOld > 0 then
  for NewNr,NewID in ipairs(DeadNodesTableOld) 
  do
    if EmailType == 0 then      
      DeadNodesStr = DeadNodesStr .. fibaro:getName(NewID) .. ' (DeviceID: ' .. NewID .. ') in Room ' .. fibaro:getRoomNameByDeviceID(NewID) .. ' is dead.' .. "\n"
    else
      DeadNodesStr = DeadNodesStr .. '<TR><TD>' .. NewID .. '</TD><TD>' .. fibaro:getName(NewID) .. '</TD><TD>'	.. fibaro:getRoomNameByDeviceID(NewID) ..'</TD></TR>' .. "\n"
    end
  end
else
  if EmailType == 0 then	
    DeadNodesStr = DeadNodesStr .. 'No Dead Devices.' .. "\n"
  else
    DeadNodesStr = DeadNodesStr .. '<TR><TD>' .. 'None' .. '</TD><TD>' .. 'None' .. '</TD><TD>' .. 'None' ..'</TD></TR>' .. "\n"
  end 
end


-- Make String for New Dead Device Table
if EmailType == 0 then
  NewDeadNodesStr = '' 
else
  NewDeadNodesStr = '<TR><TH COLSPAN="4">--- THE FOLLOWING DEVICES HAVE GONE DEAD ---</TH></TR>' .. HTMLStartStr
end

if #DeadNodesTableNew > 0 then
  for NewNr,NewID in ipairs(DeadNodesTableNew) 
  do
    if EmailType == 0 then
      NewDeadNodesStr = NewDeadNodesStr .. fibaro:getName(NewID) .. ' (DeviceID: ' .. NewID .. ') in Room ' .. fibaro:getRoomNameByDeviceID(NewID) .. ' has gone dead.' .. "\n"
    else
      NewDeadNodesStr = NewDeadNodesStr .. '<TR><TD>' .. NewID .. '</TD><TD>' .. fibaro:getName(NewID) .. '</TD><TD>'	.. fibaro:getRoomNameByDeviceID(NewID) ..'</TD></TR>' .. "\n"
    end
  end
else
  if EmailType == 0 then	
    NewDeadNodesStr = NewDeadNodesStr .. 'No New Dead Devices.' .. "\n"
  else
    NewDeadNodesStr = NewDeadNodesStr .. '<TR><TD>' .. 'None' .. '</TD><TD>' .. 'None' .. '</TD><TD>' .. 'None' ..'</TD></TR>' .. "\n"
  end
end


-- Make String For Devices That Came Back To Life Table
if EmailType == 0 then
  NodesAliveStr = ''
else
  NodesAliveStr = '<TR><TH COLSPAN="4">--- THE FOLLOWING DEVICES CAME BACK TO LIFE ---</TH></TR>' .. HTMLStartStr
end

if #AliveNodes > 0 then
  for NewNr,NewID in ipairs(AliveNodes) 
  do
    if EmailType == 0 then
      NodesAliveStr = NodesAliveStr .. fibaro:getName(NewID) .. ' (DeviceID: ' .. NewID .. ') in Room ' .. fibaro:getRoomNameByDeviceID(NewID) .. ' is alive again.' .. "\n"
    else
      NodesAliveStr = NodesAliveStr .. '<TR><TD>' .. NewID .. '</TD><TD>' .. fibaro:getName(NewID) .. '</TD><TD>'	.. fibaro:getRoomNameByDeviceID(NewID) ..'</TD></TR>' .. "\n"
    end
  end
else
  if EmailType == 0 then
    NodesAliveStr = NodesAliveStr .. 'No Devices came to life.' .. "\n"
  else
    NodesAliveStr = NodesAliveStr .. '<TR><TD>' .. 'None' .. '</TD><TD>' .. 'None' .. '</TD><TD>' .. 'None' ..'</TD></TR>' .. "\n"
  end
end


-- Make String For Devices That Need to be Ignored
if EmailType == 0 then
  IgnoredDevicesStr = ''
else
  IgnoredDevicesStr = '<TR><TH COLSPAN="4">--- THE FOLLOWING DEVICES ARE IGNORED ---</TH></TR>' .. HTMLStartStr 
end

-- Check if IgnoreDevices is used and/or bigger then 0 
if IgnoreDevices and #IgnoreDevices > 0 then
  for NewNr,NewID in ipairs(IgnoreDevices) 
  do
    if EmailType == 0 then
      IgnoredDevicesStr = IgnoredDevicesStr .. fibaro:getName(NewID) .. ' (DeviceID: ' .. NewID .. ') in Room ' .. fibaro:getRoomNameByDeviceID(NewID) .. 'is ignored.' .. "\n"
    else
      IgnoredDevicesStr = IgnoredDevicesStr .. '<TR><TD>' .. NewID .. '</TD><TD>' .. fibaro:getName(NewID) .. '</TD><TD>'	.. fibaro:getRoomNameByDeviceID(NewID) ..'</TD></TR>' .. "\n"
    end
  end
else
  if EmailType == 0 then
    IgnoredDevicesStr = IgnoredDevicesStr .. 'No Devices ignored.' .. "\n"
  else
    IgnoredDevicesStr = IgnoredDevicesStr .. '<TR><TD>' .. 'None' .. '</TD><TD>' .. 'None' .. '</TD><TD>' .. 'None' ..'</TD></TR>' .. "\n"
  end
end


-- Compile E-mailstring
if EmailType == 0 then
  message = '--- THE FOLLOWING DEVICES ARE DEAD ---'.. '\n' .. DeadNodesStr .. '\n\n' .. '--- THE FOLLOWING DEVICES HAVE BECOME DEAD ---'.. '\n' ..  NewDeadNodesStr .. '\n\n' .. '--- THE FOLLOWING DEVICES HAVE COME BACK TO LIFE ---'.. '\n' .. NodesAliveStr .. '\n\n' .. '--- THE FOLLOWING DEVICES WERE IGNORED---'.. '\n' .. IgnoredDevicesStr
else
  message =  HTMLInitiate .. DeadNodesStr .. '<br><br>' .. NewDeadNodesStr .. '<br><br>' .. NodesAliveStr .. '<br><br>' .. IgnoredDevicesStr .. HTMLEndStr
end


-- Send E-mail
if EmailNotification then
-- Allow users to enter a single user as a number, like this: UserID = 2
  if type(UserID)=="number" then
    UserID={UserID}
  end

  if #UserID > 0 then
    -- Option to send mail even when 0 dead nodes found
    if #DeadNodesTableNew > 0 or sendMailIfAllOK == true then
      for k, v in pairs(UserID) do
        fibaro:call(v, "sendEmail", title, message); -- Send message to flagged users
        if deBug == true then 
          logbug("orange", "e-mail notification sent to user "..fibaro:getName(v)) 
        end
      end
    else
      if deBug == true then
      	logbug("orange", "No new devices have gone dead, no e-mail send")
      end
    end
  else
    logbug("red", "ERROR - No users defined. Please define users to receive e-mail")
  end
end

if deBug == true then
  logbug("white", '--- SCENE ENDED ---')
end