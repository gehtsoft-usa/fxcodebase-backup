-- Id: 25477
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68640

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Noro Indicator");
    indicator:description("");
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
	
    indicator.parameters:addInteger("Period1", "MA Period", "", 30, 2, 2000);
    indicator.parameters:addInteger("Period2", "ATR Period", "", 30, 2, 2000);
	
	
	
	
   
	
	indicator.parameters:addGroup("MA Line Style"); 	
    indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Line Color", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Price; 
local Period1,Period2,Method; 
local first;
local source = nil;
local Trend; 
local MA,ma;
local Up, Down,Neutral;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Method= instance.parameters.Method;
	Price= instance.parameters.Price;
 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	
	local Parameters=Price  ..", ".. Method ..", ".. Period1..", "..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period1+Period2);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method, source[Price], Period1);
    atr = core.indicators:create("ATR", source , Period2);
    Trend = instance:addInternalStream(0, 0);
	
	MA = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.Neutral, first );
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
    MA:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period < first then
	return;
	end
	
	ma:update(mode);
	atr:update(mode);
	 
    MA[period]=ma.DATA[period];
	
 
	if  source.low[period] > (MA[period] + atr.DATA[period]) then
	Trend[period]=1;
	MA:setColor(period, Up);
	elseif  source.high[period] < (MA[period] - atr.DATA[period]) then
	Trend[period]=-1;
	MA:setColor(period, Down);
	else
	Trend[period]=Trend[period-1];
	MA:setColor(period, Neutral);
	end
	
	
	 
	
end

 
