
-- Initialization
function onInit()
    Comm.registerSlashHandler("rolld", processRoll);
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
	rRoll.aDice = {  };
	rRoll.nMod = 0;						
	ActionsManager.performAction(nil, nil, rRoll);	
end



function onRoll(rSource, rTarget, rRoll)
	rRoll.aDice = { "d6", "d6", "d6", "d6" };
	local rThrow = ActionsManager.buildThrow(rSource, vTargets, rRoll, false);
	Comm.throwDice(rThrow);

end