-- Id: 14652
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62526

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
    indicator:name("Simple Decycler");
    indicator:description("Simple Decycler");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation"); 
 
	indicator.parameters:addDouble("HPPeriod", "HPPeriod ", "HPPeriod", 125); 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Decycler Oscillator ", "Color of Decycler Oscillator", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("color1", "Color of Top Line", "Color of Top Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("color2", "Color of Bottom Line ", "Color of Bottom Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first1;
local source = nil;
local HPPeriod;
-- Streams block
local alpha1;
local HP;
local Decycle;
local Top, Bottom;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first1 = source:first()+2;
    
	HPPeriod=instance.parameters.HPPeriod;
	 
	 
	 local PI = 3.1415926;
	 local angle1 = 0.707 * 2 * PI / HPPeriod;
     local angle2 = 0.707 * 2 * PI / ( 0.5 * HPPeriod );
	 alpha1 = ( math.cos( angle1 ) + math.sin( angle1 ) - 1 ) / math.cos( angle1 );
 
 
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
 
     HP = instance:addInternalStream(first1, 0);
	 
	 
     Decycle  = instance:addStream("Decycle", core.Line, name, "Decycle", instance.parameters.color, first1);
    Decycle:setPrecision(math.max(2, instance.source:getPrecision()));
	 Decycle:setWidth(instance.parameters.width);
     Decycle:setStyle(instance.parameters.style);
  
  
     Top  = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first1);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
	 Top:setWidth(instance.parameters.width1);
     Top:setStyle(instance.parameters.style1);
	 
	 Bottom  = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first1);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	 Bottom:setWidth(instance.parameters.width2);
     Bottom:setStyle(instance.parameters.style2);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first1 or not source:hasData(period) then
	return;
	end
 
    HP[period] = (1 - alpha1 / 2)*(1 - alpha1 / 2)*(source[period] - 2*source[period-1] + source[period-2]) + 2*(1 - alpha1)*HP[period-1] - (1 - alpha1)*(1 - alpha1)*HP[period-2];
	Decycle[period] = source[period] - HP[period];
	Top[period] = Decycle[period]*1.005;
	Bottom[period] = Decycle[period]*0.995;
    
 
end
