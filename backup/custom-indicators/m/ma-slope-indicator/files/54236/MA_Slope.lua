-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1122

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
    indicator:name("MA Slope indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA_Period", "No description", 50);
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addDouble("Slope", "Slope", "pip/period", 0);
    indicator.parameters:addInteger("Bars", "Bars", "", 1);
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NO", "Color of Flat", "Color of Flat", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local MA_Period;
local MA_Method;
local Slope;
local Bars;


local first;
local source = nil;

local MASO=nil;
local MA;
 

function Prepare(nameOnly)
    
    MA_Period = instance.parameters.MA_Period;
    MA_Method = instance.parameters.Method;
    Slope = instance.parameters.Slope;
    Bars = instance.parameters.Bars;
    source = instance.source;	
	
	assert(core.indicators:findIndicator(MA_Method) ~= nil, "Please, download and install "  .. MA_Method .." indicator");	
    local name = profile:id() .. "(" .. source:name() .. ", " .. MA_Period .. ", " .. MA_Method .. ", " .. Slope .. ", " .. Bars .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end	
    MA=core.indicators:create(MA_Method, source, MA_Period);
    first = MA.DATA:first();

    MASO = instance:addStream("MASO", core.Line, name .. ".MASO", "MASO", instance.parameters.NO, first);
	MASO:setWidth(instance.parameters.width);
    MASO:setStyle(instance.parameters.style);
  
end

function Update(period, mode)
 
     MA:update(mode);
	 
	 if period < MA.DATA:first() then	 
	 return;
	 end
	 
	 
	 
	  MASO[period]=MA.DATA[period];
	  
	  if period <  MA.DATA:first()+ Bars then 
	  return;
	  end

     local Sl=(MA.DATA[period]-MA.DATA[period-Bars])/(source:pipSize())

     if Sl>Slope then
     
     MASO:setColor(period,  instance.parameters.UP);
        
     elseif Sl<-Slope then
     MASO:setColor(period,  instance.parameters.DN);  
  
     else     
     MASO:setColor(period,  instance.parameters.NO);
     end
  
end

