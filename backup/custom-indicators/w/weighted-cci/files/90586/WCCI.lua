-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59805
-- Id: 10370

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
    indicator:name("Weighted CCI");
    indicator:description("Weighted CCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FastCCI", "Fast  CCI Period", "Fast  CCI Period", 7);
    indicator.parameters:addInteger("SlowCCI", "Slow CCI Period ", "Slow CCI Period ", 14);
    indicator.parameters:addInteger("Weight", "Weight", "Weight", 1);
	 indicator.parameters:addInteger("Period1", "Fast  ATR Period", "Fast  CCI Period", 7);
    indicator.parameters:addInteger("Period2", "Slow ATR Period ", "Slow CCI Period ", 50);

	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Fast_color", "Color of Fast", "Color of Fast", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Slow_color", "Color of Slow", "Color of Slow", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
	
    indicator.parameters:addDouble("overbought1", "Major Overbought Level","", 200);
    indicator.parameters:addDouble("oversold1","Major Oversold Level","", -200);
	
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("overbought2", "Minor Overbought Level","", 50);
    indicator.parameters:addDouble("oversold2","Minor Oversold Level","", -50);
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
	
	
	

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FastCCI;
local SlowCCI;
local Weight;
local Period1;
local Period2;
local fast, slow;
local first;
local source = nil;
local overbought2, overbought1;
local oversold2,oversold2;
-- Streams block
local Fast = nil;
local Slow = nil;
local ATR1,ATR2;
-- Routine
function Prepare(nameOnly)
    FastCCI = instance.parameters.FastCCI;
    SlowCCI = instance.parameters.SlowCCI;
    Weight = instance.parameters.Weight;
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	overbought2 = instance.parameters.overbought2;
	overbought1 = instance.parameters.overbought1;
	oversold1 = instance.parameters.oversold1;
	oversold2 = instance.parameters.oversold2;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FastCCI) .. ", " .. tostring(SlowCCI) .. ", " .. tostring(Weight) .. ", " .. tostring(Period1) .. ", " .. tostring(Period2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        fast = core.indicators:create("CCI", source,FastCCI );
        slow = core.indicators:create("CCI", source,AlowCCI );
        ATR1 = core.indicators:create("ATR", source,Period1 );
        ATR2 = core.indicators:create("ATR", source,Period2 );
        first = math.max( slow.DATA:first(), fast.DATA:first(), ATR1.DATA:first(), ATR2.DATA:first());
        Fast = instance:addStream("Fast", core.Line, name .. ".Fast", "Fast", instance.parameters.Fast_color, first);
    Fast:setPrecision(math.max(2, instance.source:getPrecision()));
		Fast:setWidth(instance.parameters.width1);
        Fast:setStyle(instance.parameters.style1);
        Slow = instance:addStream("Slow", core.Line, name .. ".Slow", "Slow", instance.parameters.Slow_color, first);
    Slow:setPrecision(math.max(2, instance.source:getPrecision()));
		Slow:setWidth(instance.parameters.width2);
        Slow:setStyle(instance.parameters.style2);
		
		Fast:addLevel(instance.parameters.oversold1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
		Fast:addLevel(instance.parameters.overbought1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);   
		Fast:addLevel(instance.parameters.oversold2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
		Fast:addLevel(instance.parameters.overbought2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	fast:update(mode);
	slow:update(mode);
	ATR1:update(mode);
	ATR2:update(mode);
		
    if period < first   then
	return;
	end
	
	local F,S,Kw;
	
	 if (Weight~=0) then      
     Kw=Weight* ATR1.DATA[period]/ATR2.DATA[period];
	 F=fast.DATA[period]*Kw;
	 S =slow.DATA[period]*Kw;	
     else
	 F=fast.DATA[period];
	 S=slow.DATA[period];   
     end
	 
	 
	  if(S>overbought1+50) then S=overbought1+50; end
      if(F>overbought1+50) then F=overbought1+50; end
      if(F<oversold1-50) then F=oversold1-50; end
      if(S<oversold1-50) then S=oversold1-50; end
	  
	
	 Fast[period]=F;
	 Slow[period]=S;
	
end

