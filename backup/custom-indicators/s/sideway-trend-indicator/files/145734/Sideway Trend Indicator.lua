-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72101

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Sideway Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calulation");
   indicator.parameters:addInteger("Period", "Period", "", 14);	
   indicator.parameters:addDouble("Level", "Level", "", 20);		
	
	indicator.parameters:addGroup("Placement"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Up", "Up Label Color", "", core.rgb(0, 255, 0)); 
   indicator.parameters:addColor("Down", "Down Label Color", "", core.rgb(255, 0, 0));  
    indicator.parameters:addColor("Neutral", "Neutral Label Color", "", core.rgb(0, 0, 255));    
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 
local font;
local Neutral, Down, Up;
local Size;
local ShiftY;
local Period, Level;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Up=instance.parameters.Up;
	Down=instance.parameters.Down;  
	Neutral=instance.parameters.Neutral;
	ShiftY=instance.parameters.ShiftY;
	Size=instance.parameters.Size;   
	
	Period=instance.parameters.Period;
	Level=instance.parameters.Level;
    source = instance.source;

	DMI = core.indicators:create("DMI", source, Period);	
	ADX = core.indicators:create("ADX", source, Period);	
    first=ADX.DATA:first();	
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

ADX:update(mode);
DMI:update(mode); 
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 
	  then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size*15), context:pointsToPixels (Size*15), 0);
           context:createFont (2,  "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);		   
            init = true;
        end
	
			
    local period=source:size()-1;
	
	local Trend="";
	if ADX.DATA[period] > Level then
	Trend="Strong"

	else
	Trend="Weak";
	end
	
	
	 
	if DMI.DIP[period] >= DMI.DIM[period] then
	Color=Up;
	Trend=Trend.. " Up Trend"
	TrendSign="\233"	
	else
	Color=Down;
	TrendSign="\234"	
	Trend=Trend.. " Down Trend"	
	end
	 
	
	if ADX.DATA[period] < Level then
	TrendSign="\232"
    end	
	
 
    width1, height1 = context:measureText (2, Trend, 0);
   context:drawText (2,  Trend, Color, -1,   context:right()-100-width1 ,  context:top() +100+height1*ShiftY,  context:right()-100,  context:top()+100+height1*ShiftY +height1 , 0 );	
   
    width2, height2 = context:measureText (1, TrendSign, 0);
   context:drawText (1,   TrendSign, Color, -1,   context:right()-100-width2 ,  context:top() +100+height1*ShiftY ,  context:right()-100,  context:top()+100+height1*ShiftY +height2 , 0 );	
end		
 
 


 
 