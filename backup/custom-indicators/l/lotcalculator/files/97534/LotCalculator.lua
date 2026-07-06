-- Id: 13221
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61576

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("LotCalculator");
    indicator:description("LotCalculator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Account Info");	
	indicator.parameters:addString("Account", "Account to trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	
    indicator.parameters:addInteger("Equity", "Manual Account size", "Account size", 10000,0,1000000000);	
    indicator.parameters:addString("Type", "Balance/Equity", "", "Balance");
    indicator.parameters:addStringAlternative("Type", "Equity", "", "Equity");
    indicator.parameters:addStringAlternative("Type", "Balance", "", "Balance");
	indicator.parameters:addStringAlternative("Type", "Manual", "" , "Manual");
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("StopDistanceInPips", "Stop Distance In Pips", "Stop Distance In Pips", 30);	
	indicator.parameters:addDouble("StopLevel", "Stop Level", "Stop Level", 0);	
	indicator.parameters:addDouble("Risk", "Risk", "Risk", 2);		
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Label", "Label", "Label", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15);
 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Size,Label,Type,Equity,PipCost,Account;
local StopDistanceInPips;
local StopLevel;
local Risk;
local PipCost;
function Prepare(nameOnly)
    Type = instance.parameters.Type;
	Size = instance.parameters.Size;
	Label = instance.parameters.Label;
    Equity = instance.parameters.Equity;
	Account = instance.parameters.Account;
	Risk = instance.parameters.Risk;
	StopDistanceInPips= instance.parameters.StopDistanceInPips;
	StopLevel= instance.parameters.StopLevel;
	 
    source = instance.source;
    first = source:first();
	
	
	name = profile:id() .. "(" .. source:name() ..") ";
	instance:name(name);
	if nameOnly then
		return;
	end
	PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
	
	instance:ownerDrawn(true);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  
end

local init = false;
function Draw(stage, context)
   
   
    if stage~= 2 then
	return;
	end
	
	if not  init then
	init = true;
	context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
	end
   
	
	if StopLevel == 0 then 
	local Text1= "StopLevel has been set to zero";
	width, height = context:measureText (1, Text1, 0);
	x1=context:left ();
	x2=context:left ()+ width;
	y1=context:bottom ()-5*height;
	y2=context:bottom ()-4*height;
	context:drawText (1, Text1, Label, -1, x1, y1, x2, y2, 0)
	end
	
	local StopDistance=StopDistanceInPips;
	
	if(StopLevel == 0 and StopDistance == 0)  then
         
         Text4 = "No stoploss values have been set";
		 
		width, height = context:measureText (1, Text4, 0);
		x1=context:left ();
		x2=context:left ()+ width;
		y1=context:bottom ()-6*height;
		y2=context:bottom ()-5*height;
		context:drawText (1, Text4, Label, -1, x1, y1, x2, y2, 0)
	end	 
	 
	local AccountEquity;
	
	if Type == "Equity" then
	AccountEquity=core.host:findTable("accounts"):find("AccountID", Account).Equity;
	elseif Type ==  "Balance" then
	AccountEquity=core.host:findTable("accounts"):find("AccountID", Account).Balance;
	else
	AccountEquity=Equity;
	end
	
    local Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	local Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
	
	local StopDistanceFromLevel;
	
	if StopLevel < Bid then  StopDistanceFromLevel = Ask - StopLevel;  end
    if StopLevel > Bid  then StopDistanceFromLevel = StopLevel - Bid;  end
	
	

	
	local LotsByDistance= ((AccountEquity/100)*Risk)/(StopDistance*PipCost);
	local ActualRiskByDistance =  ((StopDistance*PipCost)*LotsByDistance)/(AccountEquity/100);
	
    if StopDistance   ~= 0 then		 	
	local  Text2 = "Lots by SL distance of " .. string.format("%." .. 0 .. "f", StopDistanceInPips)   .. " pips is " ..  string.format("%." .. 2 .. "f", LotsByDistance)  .. ". Risk would be " ..  string.format("%." .. 2 .. "f", ActualRiskByDistance)  .. " %";
    
	width, height = context:measureText (1, Text2, 0); 
    x1=context:left ();
	x2=context:left ()+ width;
	y1=context:bottom ()-3*height;
	y2=context:bottom ()-2*height;
	context:drawText (1, Text2, Label, -1, x1, y1, x2, y2, 0)
	end
	
	
	if StopLevel ~= 0 and  StopDistanceFromLevel ~= 0 then		 	
	
	local LotsByLevel= ((AccountEquity/100)*Risk)/((StopDistanceFromLevel/source:pipSize())*PipCost);
	local ActualRiskByLevel = (((StopDistanceFromLevel/source:pipSize())*PipCost)*LotsByLevel)/(AccountEquity/100);
	
	 
	 local  Text3 =  "Lots by SL level of "  .. string.format("%." .. source:getPrecision () .. "f", StopLevel) .. " is " ..  string.format("%." .. 2 .. "f", LotsByLevel) .. ". Risk would be " .. string.format("%." .. 2 .. "f", ActualRiskByLevel) .. " %";
	 
	  
	width, height = context:measureText (1, Text3, 0); 
    x1=context:left ();
	x2=context:left ()+ width;
	y1=context:bottom ()-2*height;
	y2=context:bottom ()-1*height;
	context:drawText (1, Text3, Label, -1, x1, y1, x2, y2, 0)
	 
	end
end

