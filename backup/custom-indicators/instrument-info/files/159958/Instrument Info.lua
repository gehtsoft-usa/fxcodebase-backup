-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76163

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 

 function Init()
    indicator:name("Instrument Info");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
	
	
	indicator.parameters:addGroup("Calculatin"); 
	indicator.parameters:addInteger("SIZE", "Position Size (in Lots)", "", 1);
    indicator.parameters:addString("Account", "Account to trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	
	
 

	indicator.parameters:addInteger("size", "Font Size", "", 13);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0);
	indicator.parameters:addColor("Label", "Color of Label", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Positiv", "Pozitiv Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Negativ", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	
end

local SIZE;
local size;
local first;
local source = nil;
local font,bold;
local Instrument;
local Shift;
local Label;
local Wingdings;
local Account;
-- Routine
function Prepare(nameOnly)
     Label=instance.parameters.Label;
	host=   core.host;
    source = instance.source;
    first = source:first();	
	size=instance.parameters.size;
    Instrument= source:instrument ();
	Shift=instance.parameters.Shift;
	SIZE=instance.parameters.SIZE;
	Account=instance.parameters.Account;
   
    local name = profile:id() ;
	instance:name(name);
	if nameOnly then
		return;
	end
	Wingdings = core.host:execute("createFont", "Wingdings", size, false, false);
	 font = core.host:execute("createFont", "Courier", size, false, false);
	 bold = core.host:execute("createFont", "Courier", size, false, true);
	 bold2 = core.host:execute("createFont", "Courier", size*2, false, true);					   
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	if period ~= source:size() -1 then
	return;
	end	
	
  local L, S;
  L, S , MMR,PipCost,ContractSize,marketStatus =	DATA();
  DRAW(L,S,MMR,PipCost,ContractSize,marketStatus);
end



function DRAW(L,S,MMR,PipCost,ContractSize,marketStatus)

if L == nil then
return;
end

local Color= core.rgb(0, 0, 0);

if L > S then
Color= instance.parameters.Positiv;
elseif L< S then
Color= instance.parameters.Negativ;
else
Color= instance.parameters.Neutral;
end


core.host:execute("drawLabel1", 15 ,-200, core.CR_RIGHT, 25 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold2, Label,  source:instrument());
									  
 
		
core.host:execute("drawLabel1", 17 ,-100, core.CR_RIGHT, 25 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold2, Label,source:barSize());
									  
 
	 
core.host:execute("drawLabel1", 3 ,-200, core.CR_RIGHT, 75 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Long");
									  
core.host:execute("drawLabel1", 1 ,-200, core.CR_RIGHT, 100 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Positiv, string.format("%." .. 4 .. "f", L *SIZE));
		
core.host:execute("drawLabel1", 4 ,-100, core.CR_RIGHT, 75 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Short");
		
  core.host:execute("drawLabel1", 2 ,-100, core.CR_RIGHT, 100+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Negativ, string.format("%." .. 4 .. "f", S*SIZE ));
		

core.host:execute("drawLabel1", 5 ,-100, core.CR_RIGHT, 125 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "MMR");
		
  core.host:execute("drawLabel1", 6 ,-100, core.CR_RIGHT, 150+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 0 .. "f", MMR*SIZE ));
									  

core.host:execute("drawLabel1", 7 ,-200, core.CR_RIGHT, 125 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "PipCost");
		
  core.host:execute("drawLabel1", 8 ,-200, core.CR_RIGHT, 150+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 4 .. "f", PipCost*SIZE ));					



if ContractSize== 1 then

 core.host:execute("drawLabel1", 9 ,-100, core.CR_RIGHT, 175 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Position");
		
		
core.host:execute("drawLabel1", 10 ,-100, core.CR_RIGHT, 200+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 0 .. "f", source.close[source:size()-1]*SIZE ));
									  
else
 core.host:execute("drawLabel1", 9 ,-100, core.CR_RIGHT, 175 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Position");
		
		
core.host:execute("drawLabel1", 10 ,-100, core.CR_RIGHT, 200+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 0 .. "f", ContractSize*SIZE ));
end									  

core.host:execute("drawLabel1", 11 ,-200, core.CR_RIGHT, 175 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Leverage");
		
if ContractSize == 1 then		
core.host:execute("drawLabel1", 12 ,-200, core.CR_RIGHT, 200+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 4 .. "f",  source.close[source:size()-1] / MMR ));	
else
 		
core.host:execute("drawLabel1", 12 ,-200, core.CR_RIGHT, 200+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Label, string.format("%." .. 4 .. "f",  (ContractSize)/MMR ));	
end									  

if marketStatus then		

 core.host:execute("drawLabel1", 13 ,-100, core.CR_RIGHT, 225 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Market Status");
									  
  core.host:execute("drawLabel1", 14 ,-100, core.CR_RIGHT, 250+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Positiv, "Open");	
else
 core.host:execute("drawLabel1", 13 ,-100, core.CR_RIGHT, 225 + Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, Label, "Market Status");
									  
  core.host:execute("drawLabel1", 14 ,-100, core.CR_RIGHT, 250+ Shift, core.CR_TOP, core.H_Center, core.V_Center,
									  font, instance.parameters.Negativ, "Closed");	

end									  
 									  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font); 
	   core.host:execute("deleteFont", bold); 	 
        core.host:execute("deleteFont", Wingdings); 	   
end


function DATA()

		local Table=core.host:findTable("offers");
		local enum = Table:enumerator();
	    local S=nil;
		local L=nil;		
		local MMR=nil;	
        local PipCost=nil;
        local ContractSize;		
		local marketStatus;
		
	    while true do
		
	    local row = enum:next();	
	    
				if row == nil then
				break;
				end   
						
				if Instrument == row.Instrument then	
				  S =  row.IntrS;
				  L = row.IntrB;
				  MMR= row.MMR;
				  PipCost= row.PipCost;
				 
				  break;
				end
						
		end 
        ContractSize=core.host:execute("getTradingProperty", "baseUnitSize", source:instrument(), Account);
		marketStatus = core.host:execute("getTradingProperty", "canCreateMarketClose", source:instrument(), Account);

		
		return L, S, MMR,PipCost,ContractSize,marketStatus;
end

-- https://fxcodebase.com/code/viewtopic.php?f=17&t=76163

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 