-- Id: 14053

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=228

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

--- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Customizable STARC Band");
    indicator:description("Indicates upper and lower limits of price movement.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
    indicator.parameters:addDouble("USM", "Multiplier", "The deviation multiplier", 2);
    indicator.parameters:addInteger("MA_N", "Number of MA periods", "The number of periods used in the Moving Average calculation", 6);
    indicator.parameters:addInteger("ATR_N", "Number of ATR periods", "The number of periods used in the Average True Range calculation", 14);
    
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UB_color", "Upper line color", "The color of the upper line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("LB_color", "Lower line color", "The color of the lower line", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("AL_color", "Average line color", "The color of the average line", core.rgb(192,192,192));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

end

-- Parameters block
local USM;

local first;
local source = nil;

-- internal indicators
local SMA = nil;
local ATR = nil;

-- Streams block
local UB = nil;
local LB = nil;
local AL = nil;
local Method;
local Price;
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    USM = instance.parameters.USM;
    source = instance.source;    
	Method = instance.parameters.Method;
	Price= instance.parameters.Price;
    local MA_N = instance.parameters.MA_N;
    local ATR_N = instance.parameters.ATR_N; 
    local name = profile:id() .. "(" .. source:name().. ", ".. Price.. ", ".. Method .. ", ".. USM .. ", ".. MA_N .. ", ".. ATR_N .. ")";
    instance:name(name);    
    
    if   (nameOnly) then
        return;
    end
    
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source[Price], MA_N);
    ATR = core.indicators:create("ATR", source, ATR_N);
    first = math.max(MA.DATA:first(), ATR.DATA:first());
    UB = instance:addStream("UB", core.Line, name, "Uppper Band", instance.parameters.UB_color, first);	
	UB:setWidth(instance.parameters.width1);
    UB:setStyle(instance.parameters.style1);
    LB = instance:addStream("LB", core.Line, name, "Lower Band", instance.parameters.LB_color, first);
	LB:setWidth(instance.parameters.width2);
    LB:setStyle(instance.parameters.style2);
    AL = instance:addStream("AL", core.Line, name, "Average", instance.parameters.AL_color, first);
	AL:setWidth(instance.parameters.width3);
    AL:setStyle(instance.parameters.style3);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    MA:update(mode);
    ATR:update(mode);

    if period >= first and source:hasData(period) then
        local smaVal = MA.DATA[period];
        local atrVal = USM * ATR.DATA[period];

        UB[period] = smaVal + atrVal;
        LB[period] = smaVal - atrVal;
        AL[period] = smaVal;
    end
end