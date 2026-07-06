-- Id: 22369
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66683

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Trinity Impulse");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 5, 1, 2000);
	indicator.parameters:addDouble("Level", "Level", "", 34 );
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Price; 
local first;
local source = nil;
local CCI; 
local Oscillator,LWMA;  
local Period, Level;
local ForceIndex;
-- Routine
 function Prepare(nameOnly)   
 
 
    Profile_Label="";
   
    Period= instance.parameters.Period;
	Level= instance.parameters.Level;
     
	
	
	Profile_Label=Profile_Label.. ", " ..  Period .. ", " ..  Level
 
    local name = profile:id() .. "(" ..  instance.source:name() .. Profile_Label  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("TBCCI") ~= nil, "Please, download and install TBCCI.LUA indicator");
			
    source = instance.source;
	Price = instance:addInternalStream(0, 0);
	ForceIndex= instance:addInternalStream(0, 0);

    
  
    CCI = core.indicators:create("TBCCI", Price, Period);    
    first=CCI.DATA:first();
	
	LWMA= core.indicators:create("LWMA", ForceIndex, Period);     
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)


	Price[period]= (source.high[period] + source.low[period] + source.close[period] + source.close[period])/4;
	ForceIndex[period]=(Price[period]-Price[period-1])*source.volume[period];
	
    if period < first then
	return;
	end
	
	
	 CCI:update(mode);
	 LWMA:update(mode);
		
	Oscillator[period] = 0;
 
 if(CCI.DATA[period] * LWMA.DATA[period] >=Level) then
	 if(CCI.DATA[period] > 0 and  LWMA.DATA[period] > 0) then
	 Oscillator[period] = 1;
	 end 
	 if(CCI.DATA[period] < 0 and  LWMA.DATA[period] < 0) then
	 Oscillator[period] = -1;
	 end
 end
 
				  
end
 