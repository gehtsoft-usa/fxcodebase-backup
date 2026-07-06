-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31212
-- Id: 8370

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
    indicator:name("Pivot Money Flow");
    indicator:description("Pivot Money Flow");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	
	
  indicator.parameters:addInteger("Type", "Algorithm Selection", "", 1);
    indicator.parameters:addIntegerAlternative("Type", "(Close-Typical)*Volume", "", 1);
    indicator.parameters:addIntegerAlternative("Type", "(Price-Price[-1])*Volume", "", 2);
	
	
	indicator.parameters:addString("Price", "Price Source", "", "typical");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addBoolean("Cumulative", "Cumulative", "", false);
	
	
	indicator.parameters:addString("Method", "Smoothing Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period", "Smoothing Period", "", 14);
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("PMF_color", "Color of PMF", "Color of PMF", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("Signal_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Signal_style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Signal_style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method, Period;
local first;
local source = nil;
local Price;
local Cumulative;
-- Streams block
local PMF = nil;
local Diff;
local Type;
local MA, Signal;

-- Routine
function Prepare(nameOnly)
    Price= instance.parameters.Price;
	Type= instance.parameters.Type;
	Method= instance.parameters.Method;
	Perio= instance.parameters.Period;
	Cumulative= instance.parameters.Cumulative;
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Price .. ", " .. Method .. ", " .. Price.. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Diff = instance:addInternalStream(0, 0);
        PMF = instance:addStream("PMF", core.Line, name, "PMF", instance.parameters.PMF_color, first);
    PMF:setPrecision(math.max(2, instance.source:getPrecision()));
		PMF:setWidth(instance.parameters.width);
        PMF:setStyle(instance.parameters.style);
		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method,PMF, Period);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.Signal_width);
        Signal:setStyle(instance.parameters.Signal_style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if period < first   then
	return;
	end
	
	if Type == 1 then
	Diff[period]=(source["close"][period]-source["typical"][period]) * source.volume[period];
	else	
	Diff[period]=(source[Price][period]-source[Price][period-1]) * source.volume[period];
	end
	
	if period < first+1   then
	return;
	end
	
	if Cumulative then
	 PMF[period] = PMF[period-1] + Diff[period] ;
	else
    PMF[period] =  Diff[period-1]+Diff[period] ;
	end
	
	MA:update(mode);
	
	if period < MA.DATA:first() then
	return;
	end
	
	Signal[period]= MA.DATA[period];
	
end

