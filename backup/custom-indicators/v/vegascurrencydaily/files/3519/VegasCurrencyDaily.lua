-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1751

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

function Init()
    indicator:name("Vegas Currency");
    indicator:description("Vegas Currency");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Short", "Short EMA Period", "Short EMA Period", 144);
    indicator.parameters:addInteger("Long", "Long EMA Period", "Long EMA Period ", 169);
    indicator.parameters:addString("RISK", "Risk Model", "", "1");
	indicator.parameters:addStringAlternative("RISK", "1", "", "1");
	indicator.parameters:addStringAlternative("RISK", "2", "", "2");
	indicator.parameters:addStringAlternative("RISK", "3", "", "3");
	indicator.parameters:addStringAlternative("RISK", "4", "", "4");

    indicator.parameters:addColor("S1_color", "Color of EMA", "Color of EMA", core.rgb(0, 255, 0));
    indicator.parameters:addColor("S2_color", "Color of Central Line", "Color of Central Line", core.rgb(0, 0, 255));
    indicator.parameters:addColor("S3_color", "Color of Lines", "Color of Lines", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame=nil;
local LongFrame=nil;

local Short;
local Long;
local RISK;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;
local S3 = nil;
local S4 = nil;
local S5 = nil;
local S6 = nil;
local S7 = nil;
local S8 = nil;

local Point=nil;

-- Routine
function Prepare(nameOnly)
    ShortFrame = instance.parameters.Short;
    LongFrame = instance.parameters.Long;	
	
    RISK = instance.parameters.RISK;
    source = instance.source;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame .. ", RISK MODEL, ".. RISK .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	Short = core.indicators:create("EMA", source, ShortFrame);
	Long = core.indicators:create("EMA", source, LongFrame);
	
	first = math.max(Short.DATA:first(), Long.DATA:first());

    S1 = instance:addStream("S1", core.Line, name .. ".EMA", "EMA", instance.parameters.S1_color, first);
	S1:setWidth(instance.parameters.width);
    S1:setStyle(instance.parameters.style);

    S2 = instance:addStream("S2", core.Line, name .. ".Central Line", "Central Line", instance.parameters.S2_color, first);
	S2:setWidth(instance.parameters.width);
    S2:setStyle(instance.parameters.style);

    S3 = instance:addStream("S3", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S3:setWidth(instance.parameters.width);
    S3:setStyle(instance.parameters.style);

    S4 = instance:addStream("S4", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S4:setWidth(instance.parameters.width);
    S4:setStyle(instance.parameters.style);

    S5 = instance:addStream("S5", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S5:setWidth(instance.parameters.width);
    S5:setStyle(instance.parameters.style);

    S6 = instance:addStream("S6", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S6:setWidth(instance.parameters.width);
    S6:setStyle(instance.parameters.style);

    S7 = instance:addStream("S7", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S7:setWidth(instance.parameters.width);
    S7:setStyle(instance.parameters.style);

    S8 = instance:addStream("S8", core.Line, name .. "", "", instance.parameters.S3_color, first);
	S8:setWidth(instance.parameters.width);
    S8:setStyle(instance.parameters.style);
 
    Point = source:pipSize();
  
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	 Short:update(mode);
	 Long:update(mode);
	
	
        S1[period] = Short.DATA[period];
        S2[period] =Long.DATA[period];
		
		if RISK == "1" then
		
		     S3[period]=Long.DATA[period]+55*Point;
             S4[period]=Long.DATA[period]+89*Point;
             S5[period]=Long.DATA[period]+144*Point;
            
             S6[period]=Long.DATA[period]-55*Point;
             S7[period]=Long.DATA[period]-89*Point;
             S8[period]=Long.DATA[period]-144*Point; 		
		
		end
		
		if RISK == "2" then 
		
		    S3[period]=Long.DATA[period]+233*Point;
            S4[period]=Long.DATA[period]+377*Point;
			S5[period]=nil;
            
            S6[period]=Long.DATA[period]-233*Point;
            S7[period]=Long.DATA[period]-377*Point;
			S8[period]=nil;
		end
		
		if RISK == "3" then
		
		    S3[period]=Long.DATA[period]+233*Point;
            S4[period]=Long.DATA[period]+377*Point;
            S5[period]=Long.DATA[period]+610*Point;
            
            S6[period]=Long.DATA[period]-233*Point;
            S7[period]=Long.DATA[period]-377*Point;
            S8[period]=Long.DATA[period]-610*Point;  
		end
		
		if RISK == "4" then
		
		    S3[period]=Long.DATA[period]+377*Point;
            S4[period]=Long.DATA[period]+610*Point;
            S5[period]=Long.DATA[period]+987*Point;
            
            S6[period]=Long.DATA[period]-377*Point;
            S7[period]=Long.DATA[period]-610*Point;
            S8[period]=Long.DATA[period]-987*Point; 
			
		end
		
       
end

