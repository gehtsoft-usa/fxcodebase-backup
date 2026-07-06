-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66101

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pips_spread");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("RiskPercentage", " Risk Percentage (as Equity Percentage)","" , 1);
	indicator.parameters:addDouble("Stop", " Stop (as Pips)","" , 100);
	indicator.parameters:addString("Account", "Account to trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 3);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
 local  RiskPercentage,Stop;
local font;
local Label;
local Size;
local ShiftY;
local X,Y;
local Account;
 
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	
	Account=instance.parameters.Account;
	
	RiskPercentage=instance.parameters.RiskPercentage;
	Stop=instance.parameters.Stop;
 
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
	PositionCapInstrument=instance.parameters.PositionCapInstrument;
	 
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
 
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
	local Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	local Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
    local Spread  = Ask  - Bid;	
	local Point= core.host:findTable("offers"):find("Instrument", source:instrument()).PointSize;	
    local PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;	
	
	local pipsSpread=0;
	
     if (source.close[source:size()-1] < source.open[source:size()-1]) then 
     pipsSpread= (source.high[source:size()-1] - source.close[source:size()-1]) / Point + Spread/ Point;
     else
      pipsSpread= (source.close[source:size()-1] - source.low[source:size()-1]) / Point + Spread/ Point;
	 end
	 
	
	local riskMoney =core.host:findTable("accounts"):find("AccountID", Account).Equity * RiskPercentage / 100; 
    local  riskPerLot = (pipsSpread + Stop) * PipCost;
    local  lots = riskMoney / riskPerLot;
		
        			 
			 Text= "Lots :".. win32.formatNumber(lots, false, 2); 
			  width, height = context:measureText (1, Text, 0);
			  context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,0,0) ,iX(context,width,0,2),iY(context,height,0,1), 0 );				 
  
  
              Text=" Pips + Spread :" ..  win32.formatNumber(pipsSpread, false, 2);
			  width, height = context:measureText (1, Text, 0);
			  context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1,0) ,iX(context,width,0,2),iY(context,height,1,1), 0 );		 

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 