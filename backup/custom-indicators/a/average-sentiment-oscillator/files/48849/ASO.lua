-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27860
-- Id: 8185

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Average Sentiment Oscillator");
    indicator:description("Average Sentiment Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	

    indicator.parameters:addInteger("Period1", "Range Period", "Period", 10);
	indicator.parameters:addInteger("Period2", "Smoothing Period", "Period", 10);
	indicator.parameters:addInteger("Mode", "Algoritam", "", 1);
	indicator.parameters:addIntegerAlternative("Mode"," Combined", "", 1);
    indicator.parameters:addIntegerAlternative("Mode", "Intra-bar algorithm", "", 2);
    indicator.parameters:addIntegerAlternative("Mode", "Group algorithm", "", 3);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
  
	indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Period2;
local Mode;
local first;
local source = nil;
local Method;
-- Streams block
local Bears = nil;
local Bulls = nil;

local BearsMA = nil;
local BullsMA = nil;

local TempBufferBulls,TempBufferBears;
-- Roultine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	 Period2 = instance.parameters.Period2;
	Mode= instance.parameters.Mode;
	Method= instance.parameters.Method;
    source = instance.source;
    first = source:first()+Period1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2).. ", " .. tostring(Mode) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        TempBufferBulls = instance:addInternalStream(0, 0);
        TempBufferBears = instance:addInternalStream(0, 0);
        BullsMA = core.indicators:create(Method, TempBufferBulls, Period2);
        BearsMA = core.indicators:create(Method, TempBufferBears, Period2);
         Bulls = instance:addStream("Bulls", core.Line, name .. ". Bulls", " Bulls", instance.parameters.Up_color, BullsMA.DATA:first() );
		 Bulls:setWidth(instance.parameters.width1);
         Bulls:setStyle(instance.parameters.style1);
        Bears = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.Down_color, BullsMA.DATA:first() );
		Bears:setWidth(instance.parameters.width2);
        Bears:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  then
	return;
	end
      local intrahigh=source.high[period];
      local intralow =source.low[period];
      local intraopen=source.open[period];
      local close =source.close[period];
      local intrarange = intrahigh-intralow;
      local grouplow = mathex.min(source.high,period-Period1+1, period )
      local grouphigh = mathex.max(source.low,period-Period1+1, period )
      local groupopen = source.open[ period-Period1];
      local grouprange = grouphigh-grouplow;
	  
	  
      if (intrarange==0) then intrarange=1;end
      if (grouprange==0)  then grouprange=1;end
	  
	  
      local intrabarbulls = ((((close-intralow)+(intrahigh-intraopen))/2)*100)/intrarange;
      local groupbulls = ((((close-grouplow)+(grouphigh-groupopen))/2)*100)/grouprange;
      local intrabarbears = ((((intrahigh-close)+(intraopen-intralow))/2)*100)/intrarange;      
      local groupbears = ((((grouphigh-close)+(groupopen-grouplow))/2)*100)/grouprange;   
	  
	     if (Mode==1) then  TempBufferBulls[period]=(intrabarbulls+groupbulls)/2; end
         if (Mode==1) then  TempBufferBears[period]=(intrabarbears+groupbears)/2; end
         if (Mode==2) then  TempBufferBulls[period]=intrabarbulls; end
         if (Mode==2) then  TempBufferBears[period]=intrabarbears; end
         if (Mode==3) then  TempBufferBulls[period]=groupbulls; end
         if (Mode==3) then  TempBufferBears[period]=groupbears; end
		 
		 
		 
      BullsMA:update(mode);
	  BearsMA:update(mode);
	  
	  if period < BullsMA.DATA:first() then
	  return;
	  end
	  
       Bulls[period] =  BullsMA.DATA[period];
       Bears[period] = BearsMA.DATA[period];
    
end

