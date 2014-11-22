
-- Initialization
function onInit()
    Comm.registerSlashHandler("rolld", processRoll);
	GameSystem.actions["rolld"] = { bUseModStack = false };
	ActionsManager.registerResultHandler("rolld", onRoll);

	ActionsManager.print("Drop Lowest Init");

		
	-- send launch message
	local msg = {sender = "", font = "emotefont"};
	msg.text = "DMFirmy's Drop Lowest loaded...";
	ChatManager.registerLaunchMessage(msg);
end
	
function processRoll(sCommand, sParams)
	local rRoll = {};
	rRoll.sType = "rolld";
	rRoll.aDice = {"d6", "d6", "d6", "d6"};
	rRoll.nMod = 0;
	rRoll.sUser = User.getUsername();
	ActionsManager.roll(nil, nil, rRoll);
	
end

function onRoll(rSource, rTarget, rRoll)
	
	local i = 1;
	local lowest = 999;
	local lowestIndex = 0;
	while i < 5 do
		if rRoll.aDice[i].result < lowest then
			lowest = rRoll.aDice[i].result;
			lowestIndex = i;
		end
		i = i + 1;
	end

	i = 1;
	local dice = {};
	for _,v in ipairs(rRoll.aDice) do
		if(i ~= lowestIndex) then
			table.insert(dice,v);
		end
		i = i + 1;
	end

	-- Build the basic message to deliver
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
	rMessage.type = rRoll.sType;
	rMessage.text = rMessage.text .. "A " .. lowest .. " was dropped";
	rMessage.dice = dice;
	rMessage.diemodifier = rRoll.nMod;

	Comm.deliverChatMessage(rMessage);
end