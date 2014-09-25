
-- Initialization
function onInit()
    Comm.registerSlashHandler("rolld", processRoll);
	ActionsManager.registerResultHandler("rolld", onRoll);


	print("Drop Lowest Init");

		
	-- send launch message
	local msg = {sender = "", font = "emotefont"};
	msg.text = "DMFirmy's Drop Lowest loaded...";
	ChatManager.registerLaunchMessage(msg);
end
	
function processRoll(sCommand, sParams)
	local rRoll = {};
	rRoll.sType = "rolld";
	rRoll.aDice = { "d6" };
	rRoll.nMod = 0;						
	ActionsManager.performAction(nil, nil, rRoll);					
	--Comm.throwDice(sDragType, aDice, iModifier, sDescription);
end



function onRoll(rSource, rTarget, rRoll)
	print("Yo")
end