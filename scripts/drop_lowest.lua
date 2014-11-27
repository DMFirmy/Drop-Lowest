---
--- Initialization
---
function onInit()
	Comm.registerSlashHandler("rolld", processRoll);
	GameSystem.actions["rolld"] = { bUseModStack = false };
	ActionsManager.registerResultHandler("rolld", onRoll);

	-- send launch message
	local msg = {sender = "", font = "emotefont"};
	msg.text = "DMFirmy's Drop Lowest loaded. Type \"/rolld ?\" for usage.";
	ChatManager.registerLaunchMessage(msg);
end

---
---	This is the function that is called when the rolld slash command is called.
--- The default value for sParams is equal to "4d6 1"
---
function processRoll(sCommand, sParams)
	if not sParams or sParams == "" then 
		sParams = "4d6 1";
	end

	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();		
	else
		local rRoll = createRoll(sParams);
		ActionsManager.roll(nil, nil, rRoll);
	end		
end

---
--- This function creates the roll object based on the parameters sent in
---
function createRoll(sParams)
	local rRoll = {};
	rRoll.sType = "rolld";
	rRoll.nMod = 0;
	rRoll.sUser = User.getUsername();
	rRoll.aDice = {};
	rRoll.aDropped = {};
	
	-- If no number to drop is specified, we will assume it is 0
	if(not sParams:match("(%d+)d([%dF]*)%s(%d+)") and sParams:match("(%d+)d([%dF]+)")) then
		sParams = sParams .. " 0"
	end
	
	-- Now we check that we have a properly formatted parameter, or we set the sDesc for the roll with a message.
	if not sParams:match("(%d+)d([%dF]*)%s(%d+)") then
		rRoll.sDesc = "Parameters not in correct format. Should be in the format of \"#d# #\"";
		return rRoll;
	end

	local sNum, sSize, sDrop = sParams:match("(%d+)d([%dF]+)%s(%d+)");
	local count = tonumber(sNum);
	local drop = tonumber(sDrop);

	if (drop > count) then
		rRoll.sDesc = "You cannot drop more results than the number of dice being rolled.";
		return rRoll;
	end

	while count > 0 do
		table.insert(rRoll.aDice, "d" .. sSize);
		
		-- For d100 rolls, we also need to add a d10 dice for the ones place
		if sSize == "100" then
			table.insert(rRoll.aDice, "d10");
		end
		count = count - 1;
	end
	
	rRoll.nDrop = drop;

	return rRoll;
end

---
--- This function first sorts the dice rolls in ascending order, then it splits
--- the dice results into kept and dropped dice, and stores them as rRoll.aDice
--- and rRoll.aDropped.
---
function dropDiceResults(rRoll)
	if #(rRoll.aDice) < 2 then return rRoll end
	local len = #(rRoll.aDice) or 0;
	local drop = tonumber(rRoll.nDrop) or 0;
	local dropped = {};
	local kept = {};
	
	table.sort(rRoll.aDice, function(a,b) return a.result < b.result end);
	local count = 1;
	while count <= len do
		if count <= drop then
			table.insert(dropped, rRoll.aDice[count]);
		else
			table.insert(kept, rRoll.aDice[count]);
		end
		count = count + 1;
	end

	rRoll.aDice = kept;
	rRoll.aDropped = dropped;
	return rRoll;
end

---
--- This function creates a chat message that displays the results.
---
function createChatMessage(rSource, rRoll)	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	if #(rRoll.aDice) > 0 then
		rMessage.text = rMessage.text .. "[KEPT]";
		for _,v in ipairs(rRoll.aDice) do
			rMessage.text = rMessage.text .. " " .. v.result;
		end
	end
	if #(rRoll.aDice) > 0 and #(rRoll.aDropped) > 0 then
		rMessage.text = rMessage.text .. "\n";
	end
	if #(rRoll.aDropped) > 0 then
		rMessage.text = rMessage.text .. "[DROPPED]";
		for _,v in ipairs(rRoll.aDropped) do
			rMessage.text = rMessage.text .. " " .. v.result;
		end
	end
	
	return rMessage;
end

---
--- This function creates the help text message for output.
---
function createHelpMessage()	
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "The \"/rolld\" command is used to roll a set of dice, removing a number of the lowest results.\n"; 
	rMessage.text = rMessage.text .. "You can specify the number of dice to roll, the type of dice, and the number of results to be dropped "; 
	rMessage.text = rMessage.text .. "by supplying the \"/rolld\" command with parameters in the format of \"#d# #\", where the first # is the "; 
	rMessage.text = rMessage.text .. "number of dice to be rolled, the second number is the number of dice sides, and the number following the "; 
	rMessage.text = rMessage.text .. "space being the number of results to be dropped.\n"; 
	rMessage.text = rMessage.text .. "If no parameters are supplied, the default parameters of \"4d6 1\" are used."; 
	Comm.deliverChatMessage(rMessage);
end

---
--- This is the callback that gets triggered after the roll is completed.
---
function onRoll(rSource, rTarget, rRoll)
	rRoll = dropDiceResults(rRoll);
	rMessage = createChatMessage(rSource, rRoll);
	rMessage.type = "dice";
	Comm.deliverChatMessage(rMessage);
end