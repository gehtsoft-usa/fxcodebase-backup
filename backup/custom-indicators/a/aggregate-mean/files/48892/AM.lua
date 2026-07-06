-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27871
-- Id: 8189

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name(" Aggregate Mean");
    indicator:description(" Aggregate Mean");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Slow", "Slow Period", "Slow Period", 252);
    indicator.parameters:addInteger("Fast", "Fast Period", "Fast Period", 10);
	indicator.parameters:addGroup("Syle");
    indicator.parameters:addColor("AM_color", "Color of AM", "Color of AM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0.7);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.2);
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
local Slow;
local Fast;
local MvalueBuffer;
local first;
local source = nil;
 local   after;
-- Streams block
local AM = nil;

-- Routine
function Prepare(nameOnly)
    Slow = instance.parameters.Slow;
    Fast = instance.parameters.Fast;
    source = instance.source;
    first = source:first()+math.max(Slow, Fast);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Slow) .. ", " .. tostring(Fast) .. ")";
    instance:name(name);

	
    if (not (nameOnly)) then
        MvalueBuffer = instance:addInternalStream(0, 0);
        AM = instance:addStream("AM", core.Line, name, "AM", instance.parameters.AM_color, first);
    AM:setPrecision(math.max(2, instance.source:getPrecision()));
		AM:setWidth(instance.parameters.width);
        AM:setStyle(instance.parameters.style);
		AM:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		AM:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	
	 local rank_long = PercentRank(Slow, period);
     local  double rank_short = 1 - PercentRank(Fast, period);
      MvalueBuffer[period] = (rank_long + rank_short)/2;
     
      AM[period] = (MvalueBuffer[period-1]*0.4) + (MvalueBuffer[period]*0.6);
	         
    
end

function  PercentRank(Length, period) 
   local  pcrank=0;
   local  rank;
   
   after ={};
  
   Copy (  period,Length);
   table.sort(after);

    rank = Find( source.close[period]);
   pcrank = rank /(Length * 3 -1);
   
   return (pcrank);   
end

function Find (data)
local i;
local  RETURN=0;

for i = 1, #after, 1 do
  
  if after[i]== data then
    RETURN = i;
  end
    
end
return RETURN;

end


function Copy ( period,Length)

local i;

   for i = period , period-Length+1,-1 do
   
   	table.insert(after,  source.high[i]);
    table.insert(after,  source.low[i]);
    table.insert(after,  source.close[i]);

   end

end