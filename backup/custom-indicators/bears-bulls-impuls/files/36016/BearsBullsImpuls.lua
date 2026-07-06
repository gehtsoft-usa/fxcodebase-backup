-- Id: 6888
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20561

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
    indicator:name("Bears Bulls Impuls");
    indicator:description("The oscillators measures the buying and selling pressure in the market");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
     indicator.parameters:addInteger("Frame", "Period", "", 13, 2 , 2000);
	 indicator.parameters:addString("Type", "Close", "", "close");
    indicator.parameters:addStringAlternative("Type", "Open", "", "open");
    indicator.parameters:addStringAlternative("Type", "High", "", "high");
    indicator.parameters:addStringAlternative("Type", "Low", "", "low");
    indicator.parameters:addStringAlternative("Type","Close", "", "close");
    indicator.parameters:addStringAlternative("Type", "Median", "", "median");
    indicator.parameters:addStringAlternative("Type", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("Type", "Weighted", "", "weighted");
     indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Type;
local first;
local source = nil;

-- Streams block

local EMA=nil;
local Bull, Bear;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    source = instance.source;
   
	Type = instance.parameters.Type;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	EMA=core.indicators:create("EMA", source[Type], Frame);
	 first = EMA.DATA:first();	
    Bull = instance:addStream("Bulls", core.Line, name, "Bulls", instance.parameters.Bulls_color, first);
	Bear = instance:addStream("Bears", core.Line, name, "Bears", instance.parameters.Bears_color, first);
	
	Bull:setPrecision(math.max(2, instance.source:getPrecision()));
	Bear:setPrecision(math.max(2, instance.source:getPrecision()));
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	  EMA:update(mode);
	  
	  local Bulls = nil;
      local Bears = nil;
	
        Bulls = source.high[period] - EMA.DATA[period];
		Bears = source.low[period] - EMA.DATA[period];
		
		if Bulls + Bears > 0 then
		Bull[period]=1;
		Bear[period]=-1;
		else
		Bull[period]=-1;
		Bear[period]=1;
		end
		
   
    end

end