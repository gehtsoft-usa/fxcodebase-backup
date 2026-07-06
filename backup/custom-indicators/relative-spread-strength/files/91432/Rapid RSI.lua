-- Id: 10690
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60079

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
    indicator:name("Rapid RSI");
    indicator:description("Rapid RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("RSI", "RSI Period", "RSI Period", 5);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSS_color", "Color of RRSI", "Color of RRSI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local RSI ;
local first;
local source = nil;
local Up, Down;
-- Streams block
local RSS = nil;
 
-- Routine
function Prepare(nameOnly)
   
    RSI = instance.parameters.RSI;
    source = instance.source;
	 
    first = source:first()+RSI+1;
	
    local name = profile:id() .. "(" .. source:name() .. ", " ..tostring(RSI) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Up = instance:addInternalStream(0, 0);
        Down = instance:addInternalStream(0, 0); 
        RSS = instance:addStream("RRSI", core.Line, name, "RRSI", instance.parameters.RSS_color,first);
    RSS:setPrecision(math.max(2, instance.source:getPrecision()));
		RSS:setWidth(instance.parameters.width);
        RSS:setStyle(instance.parameters.style);
		
        RSS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


      Up[period]=0;
	 Down[period]=0;

     if source[period] > source[period-1] then
	 Up[period]=source[period] - source[period-1];	
	 else
	 Down[period]=source[period-1] - source[period];	
	 end
	 
    
	
    if period < first  then
	return;
	end
	
	
	local UpSum = mathex.sum( Up, period-RSI+1, period );
    local DnSum = mathex.sum( Down, period-RSI+1, period  );
	 
	
	local RS;
 
	    if DnSum ~= 0 then
        RS = UpSum / DnSum;
		else
		RS = 100;
		end
		
		
   RSS[period]= 100 - 100 / ( 1 + RS );
end
 

