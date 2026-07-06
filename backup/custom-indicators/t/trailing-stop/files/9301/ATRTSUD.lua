-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1434

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("ATR U/D Trailing Stop");
    indicator:description("ATR U/D Trailing Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    --indicator.parameters:addDouble("P", "Percentage ", "Percentage ", 3);
	indicator.parameters:addInteger("AP", "ATR period ", "ATR Period ", 14);
	indicator.parameters:addDouble("AM", "ATR multiplicator ", "ATR multiplicator ", 3.5);
    indicator.parameters:addColor("UP_color", "Up Color of PTS", "Color of PTS", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Down Color of PTS", "Color of PTS", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplicator=nil;
local Frame=nil;

local first;
local source = nil;

-- Streams block
local PTS = nil;
local STOP;
local ATR=nil;


-- Routine
 function Prepare(nameOnly)   
    Multiplicator = instance.parameters.AM;
	Frame = instance.parameters.AP;
	source = instance.source;
    first = source:first();
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. Multiplicator .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, Frame);
	
    UP = instance:addStream("UP", core.Line, name, ".UP", instance.parameters.UP_color, first);
    DN = instance:addStream("DN", core.Line, name, ".DN", instance.parameters.DN_color, first);
    PTS = instance:addInternalStream (0, 0)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= Frame and source:hasData(period) then
        ATR:update(mode);

        STOP = ATR.DATA[period] * Multiplicator;
    
        if source.close[period] < PTS[period-1] and  source.close[period-1] > PTS[period-1] then
            UP[period] = source.close[period]+STOP;
            PTS[period] = UP[period]
        elseif source.close[period] < PTS[period-1] and  source.close[period-1] < PTS[period-1] then
            UP[period]= math.min(PTS[period-1],source.close[period]+STOP);					
            PTS[period] = UP[period]
        end	

        if source.close[period] > PTS[period-1] and  source.close[period-1] < PTS[period-1] then
            DN[period] = source.close[period]-STOP;
            PTS[period] = DN[period]
        elseif source.close[period]  > PTS[period-1] and   source.close[period-1] > PTS[period-1] then
            DN[period]= math.max(PTS[period-1],source.close[period]-STOP);		
            PTS[period] = DN[period]
        end			
    end	
end