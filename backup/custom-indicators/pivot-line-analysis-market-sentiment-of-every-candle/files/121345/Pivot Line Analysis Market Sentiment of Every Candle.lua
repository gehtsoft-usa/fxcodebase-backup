-- Id: 22380
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66694

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
    indicator:name("Pivot Line Analysis Market Sentiment of Every Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;
local open=nil;
local close=nil;
local high=nil;
local low=nil; 

-- Routine
 function Prepare(nameOnly)   
  
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	first=source:first();
    
   
 
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("ZONE", "ZONE", open, high, low, close);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)


if period < first then
	return;
end
	
 
local  H1 = source.high[period];
local L1 = source.low[period];
local C = source.close[period];
 
local HH1 = source.high[period-1];
local LL1 = source.low[period-1];
local CC = source.close[period-1];
 
local Pivot1 = (HH1 + LL1 + CC) / 3;
local R11 = 2*((HH1 + LL1 + CC) / 3)- LL1;
local S11 = 2*((HH1 + LL1 + CC) / 3)- HH1;
local Pivot = (H1 + L1 + C) / 3;
local R1 = 2*((H1 + L1 + C) / 3)- L1;
local S1 = 2*((H1 + L1 + C) / 3)- H1;
	
	
 
local R=nil;
local G=nil;
local B=nil;
 
local FlagUp=0;
local FlagDown=0; 

--Outside Pivot Up
if R1 > R11 and S1 < S11 and Pivot > Pivot1 then
 Flagup = 3;
 FlagDown = -2;
 R = 0;
 G = 0;
 B = 255;
end



--Outside Pivot Down
if R1 > R11 and S1 < S11 and Pivot < Pivot1 then
 FlagUp = 2;
 FlagDown = -3;
 R = 0;
 G = 0;
 B = 255;
end
 
--Inside Pivot Up
if R1 < R11 and S1 > S11 and Pivot > Pivot1 then
 FlagUp = 1.5;
 FlagDown = 0.5;
 R = 0;
 G = 0;
 B = 255;
end
 
--Inside Pivot Down
if R1 < R11 and S1 > S11 and Pivot < Pivot1 then 
 FlagUp = -0.5;
 FlagDown = -1.5;
 R = 0;
 G = 0;
 B = 255;
end
 
--Up Pivot
if R1 > R11 and S1 > S11 then
 FlagUp = 2;
 FlagDown = -2;
 R = 0;
 G = 255;
 B = 0;
end
 
--Down Pivot
if R1 < R11 and S1 < S11 then
 FlagUp = 2;
 FlagDown = -2;
 R = 255;
 G = 0;
 B = 0;
end		



    high[period]= FlagUp;
	low[period]= FlagDown;		   
	close[period] = FlagDown;
	open[period]  = FlagUp;	
     
	if R~= nil and G~= nil and B~= nil then
    open:setColor(period, core.rgb(R, G, B));
	end
				  
end

