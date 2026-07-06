-- Id: 9273

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=40640

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Smoothed Bid Ask Median");
    indicator:description("Smoothed Bid Ask Median."); 
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

	indicator.parameters:addString("Period", "Period", "", 14);
	
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	

     indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Type;
local first;
local source = nil;
local clr, style, width;
local bid, ask;
local Price;
local Method,Period;
local Raw;
local MA; 
local Out;
-- Routine
function Prepare(nameOnly) 
    clr = instance.parameters.clr;
	style = instance.parameters.style;
	width = instance.parameters.width;
	Type = instance.parameters.Type;
    source = instance.source;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Price = instance.parameters.Price; 

    local name = profile:id() .. "(" .. source:name().. ", " .. Price .. ", " .. Method.. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	if source:isBid() then
     bid = source;
     ask = core.host:execute("getAskPrice");
    else
     ask = source;
     bid = core.host:execute("getBidPrice");
    end
	
	Raw = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, Raw, Period);
	
	  first = MA.DATA:first();
	
	
	Out = instance:addStream("SBAM", core.Line, name, "SBAM", instance.parameters.color, MA.DATA:first());
   Out:setWidth(instance.parameters.width );
   Out:setStyle(instance.parameters.style );
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   
	
	Raw[period]= (bid[Price] [period] +ask[Price] [period])/2;
	MA:update(mode);
	
 if period < MA.DATA:first() then
 return;
 end
	 
	Out[period]= MA.DATA[period];
	 
end

