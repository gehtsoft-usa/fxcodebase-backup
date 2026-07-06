-- Id: 22018
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66525

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Cumulated Volume Velocity");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14); 
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
   
   
    indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255,0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

 
local CumVolVel;
local EMA; 
local Period;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	
   Period = instance.parameters.Period;
   
	 

	source = instance.source;
	first=source:first()+1;
  
	 
  CumVolVel = instance:addStream("CumVolVel", core.Line, "Cumulated volume", "Cumulated volume", instance.parameters.color1, first);
  CumVolVel:setWidth(instance.parameters.width1);
  CumVolVel:setStyle(instance.parameters.style1);
  
  EMA = core.indicators:create("EMA", CumVolVel, Period);
  
  
  Signal = instance:addStream("Signal", core.Line, "Signal Line", "Signal Line", instance.parameters.color2, first+Period); 
  Signal:setWidth(instance.parameters.width2);
  Signal:setStyle(instance.parameters.style2);
  
  CumVolVel:setPrecision(math.max(2, instance.source:getPrecision()));
  Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		
end

-- Indicator calculation routine
function Update(period, mode)
	
  local sRange =source.high[period]-source.low[period];
  
  
  if period < first then
  return;
  end
  
  
if(source.high[period]<source.high[period-1] and source.low[period]<source.low[period-1]) then
CumVolVel[period] = CumVolVel[period-1]-sRange*source.volume[period];
elseif(source.high[period]>source.high[period-1] and source.low[period]>source.low[period-1]) then
CumVolVel[period] = CumVolVel[period-1]+sRange*source.volume[period];
else
CumVolVel[period] = CumVolVel[period-1];
end
 
 
  EMA:update(mode);
  
   if period < first+Period then
  return;
  end
  
  Signal[period]=EMA.DATA[period];		
 end

 