-- Id: 22701
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66916

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
    indicator:name("ATR Candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "Type", "Type" , "Candle");
    indicator.parameters:addStringAlternative("Type", "Candle", "Candle" , "Candle");
    indicator.parameters:addStringAlternative("Type", "Line", "Line" , "Line");
	
	indicator.parameters:addGroup(" MA Calculation"); 
	
    indicator.parameters:addInteger("Period1", "Period", "", 50, 2, 2000);
 
	indicator.parameters:addString("Price1", "Power Price", "", "open");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("ATR Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 50, 2, 2000);
 
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Type;

local Method1, Price1, Period1;
local Period2; 
local first;
local source = nil;
 
local Oscillator;  
local MA1,ATR;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    Price1 = instance.parameters.Price1;
	
	Period2= instance.parameters.Period2;
	
	Type= instance.parameters.Type;
    
	
	
	local Parameters= Period1 ..  ", " .. Method1 ..  ", " .. Price1..  ", " ..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source[Price1], Period1);
    ATR = core.indicators:create("ATR", source , Period2);
    
    first=math.max(MA1.DATA:first(), ATR.DATA:first());
	
	 
   
    if Type== "Candle" then
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	open:setPrecision(math.max(2, instance.source:getPrecision()));
	high:setPrecision(math.max(2, instance.source:getPrecision()));
	low:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
	else	
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    end
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    ATR:update(mode);
	
	
    if period < first then
	return;
	end
	
	 if Type== "Candle" then
	 close[period]=(source.close[period]-MA1.DATA[period])/((ATR.DATA[period])/100);
	 open[period]=(source.open[period]-MA1.DATA[period])/((ATR.DATA[period])/100);
	 high[period]=(source.high[period]-MA1.DATA[period])/((ATR.DATA[period])/100);
	 low[period]=(source.low[period]-MA1.DATA[period])/((ATR.DATA[period])/100);
     else	 
     Oscillator[period]=(source.close[period]-MA1.DATA[period])/((ATR.DATA[period])/100);
	 end			  
end

