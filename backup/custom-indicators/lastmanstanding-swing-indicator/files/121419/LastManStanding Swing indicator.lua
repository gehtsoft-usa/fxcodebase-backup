-- Id: 22418
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66709

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

function Init()
    indicator:name("LastManStanding Swing indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 55, 1, 2000);
 
	indicator.parameters:addString("Price", "MA Price", "", "close");
	indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
 
    indicator.parameters:addInteger("Major_Period", "Major Period", "", 13, 1, 2000);
	indicator.parameters:addInteger("Minor_Period", "Minor Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 14, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("minor_color", "Minor Color", "", core.rgb(100,149,237));
	indicator.parameters:addColor("major_color", "Major Color", "", core.rgb(128,0,128));
	
	  indicator.parameters:addInteger("Size", "Size", "", 10);

    indicator.parameters:addGroup("MA Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Price, Period;
local Major_Period, Minor_Period;
local first;
local source = nil;
local ATR_Period, ATR;
local Oscillator;  
local MA;
local minor_color, major_color;
local up1, down1, up2, down2;
local Size;
-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
    Price = instance.parameters.Price;
	
	Major_Period = instance.parameters.Major_Period;
	Minor_Period = instance.parameters.Minor_Period;
	ATR_Period = instance.parameters.ATR_Period;
	
	Size = instance.parameters.Size;
	
	
	local Parameters= Period ..  ", " .. Method ..  ", " .. Price..  ", " ..Major_Period ..  ", " .. Minor_Period..  ", " .. ATR_Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    ma= core.indicators:create(Method, source[Price], Period);
    ATR = core.indicators:create("ATR", source , ATR_Period);
    
    first=source:first()+math.max(Minor_Period*2, Major_Period*2,ATR_Period);
	
	 
    MA = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.color, ma.DATA:first());
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
	
	up1 = instance:createTextOutput ("MinorUp", "MinorUp", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.minor_color, 0);    
	down1 = instance:createTextOutput ("MajorDown", "MajorDown", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.minor_color, 0)   
	
	
	up2 = instance:createTextOutput ("MajorUp", "MajorUp", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.major_color, 0);    
	down2 = instance:createTextOutput ("MajorDown", "MajorDown", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.major_color, 0)   
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ma:update(mode);
	ATR:update(mode);
	
	if period > ma.DATA:first() then
	MA[period]=ma.DATA[period];
	end
	
	
    if period <= (source:first()+  math.max(Minor_Period*2, Major_Period*2,ATR_Period))  then
	return;
	end
	
 
	local min1, max1, minpos1, maxpos1 = mathex.minmax (source, period-Minor_Period*2+1,period);
	local min2, max2, minpos2, maxpos2 = mathex.minmax (source, period-Major_Period*2+1,period);
	
    
	
	  up1:setNoData(maxpos1);
      up2:setNoData(maxpos2);
	  down1:setNoData(minpos1);
      down2:setNoData(minpos2);
	
	if period-maxpos1==Minor_Period  then
    up1:set(maxpos1, source.high[maxpos1], "\108",   source.high[maxpos1]);
	end
	if period-minpos1==Minor_Period then
	 down1:set(minpos1, source.low[minpos1], "\108",   source.low[minpos1]); 
	end
	if period-maxpos2==Major_Period then
	 up2:set(maxpos2, source.high[maxpos2]+ATR.DATA[period], "\108",   source.high[maxpos2]+ATR.DATA[period]); 
	end
	if period-minpos2==Major_Period then
	 down2:set(minpos2, source.low[minpos2]-ATR.DATA[period], "\108",   source.low[minpos2]-ATR.DATA[period]); 
    end
	
	
	--  up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
    
				  
end
 