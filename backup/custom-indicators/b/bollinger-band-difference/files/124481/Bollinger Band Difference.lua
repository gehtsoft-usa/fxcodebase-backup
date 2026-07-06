-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67459

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Bollinger Band Difference");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
	indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 0, 100);
	
	
 
	
	indicator.parameters:addGroup("Top / Bottom Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top / Central Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period;
local Deviation;

local first;
local source = nil;
 
local TLBL, TLAL ;  
local BB;

-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period;
	Deviation= instance.parameters.Deviation;
	
	
	local Parameters= Period ..  ", " .. Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    BB = core.indicators:create("BB", source, Period, Deviation);
    
    first=BB.DATA:first();
	
	 
   
 
	TLBL = instance:addStream("TLBL" , core.Line, " TLBL"," TLBL",instance.parameters.color1, first);
	TLBL:setWidth(instance.parameters.width1);
    TLBL:setStyle(instance.parameters.style1);
    TLBL:setPrecision(math.max(2, source:getPrecision()));
	
	TLAL = instance:addStream("TLAL" , core.Line, " TLAL"," TLAL",instance.parameters.color2, first);
	TLAL:setWidth(instance.parameters.width2);
    TLAL:setStyle(instance.parameters.style2);
    TLAL:setPrecision(math.max(2, source:getPrecision()));
	
 
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    BB:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     TLBL[period]=(BB.TL[period]-BB.BL[period])/source:pipSize();
	 TLAL[period]=(BB.TL[period]-BB.AL[period])/source:pipSize();
 
				  
end

