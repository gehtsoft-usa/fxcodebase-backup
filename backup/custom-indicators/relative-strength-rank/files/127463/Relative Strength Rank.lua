-- Id: 25585
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68691

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
    indicator:name("Relative Strength Rank");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period1", "Short Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period2", "Long Period", "", 140, 1, 2000);	
    indicator.parameters:addInteger("Period3", "ATR Period", "", 10, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(200, 0, 0));
	 indicator.parameters:addColor("DownUp", "Up in Down Trend Color", "", core.rgb(255, 0, 0));
	
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up, Down,UpDown, DownUp; 
local Price,Period1,Period2,Period3,Method; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Average;
local Short, Long,ATR;
local slope;
-- Routine
 function Prepare(nameOnly)   
 
    Price= instance.parameters.Price;
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Method= instance.parameters.Method;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	UpDown= instance.parameters.UpDown;
	DownUp= instance.parameters.DownUp;
	
	
	local Parameters=Price..", ".. Period1..", "..Period2..", "..Period3..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 

	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Short = core.indicators:create(Method, source[Price], Period1);
	Long = core.indicators:create(Method, source[Price],  Period2);
	ATR= core.indicators:create("ATR", source,  Period3);
	
	first=math.max(Short.DATA:first() ,Long.DATA:first(), ATR.DATA:first());
	slope= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Up, first ); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    Short:update(mode);
	Long:update(mode);
	ATR:update(mode);
	if period <  first  
	then
	return;
	end
	 
	 
	 if (ATR.DATA[period]~=0) then 
	 Oscillator[period] = ((source[Price][period]-Short.DATA[period])+(source[Price][period]-Long.DATA[period]))/(2.0*ATR.DATA[period])
	else  
	 Oscillator[period] = 0
	end
	 
	slope[period] = slope[period-1]
	
	if (Oscillator[period]> Oscillator[period-1]) then 
	 slope[period] =  1
	elseif (Oscillator[period]< Oscillator[period-1]) then 
	 slope[period] = -1
	end
	
	if Oscillator[period] > 0 then
		if slope[period] ==1 then
		Oscillator:setColor(period, Up);
		else
		Oscillator:setColor(period, UpDown);
		end
	else
	    if slope[period] ==-1 then
		Oscillator:setColor(period, Down);
		else
		Oscillator:setColor(period,  DownUp);
		end
	end

 
end

 
