-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70851

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
    indicator:name("ATR Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("Multiplier", "ATR multiplier", "",1);
    indicator.parameters:addInteger("Period", "Period", "", 5);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Multiplier; 
local first;
local source = nil;
 
local Sell, Buy;  
local ATR;
local direction;
local longStop, shortStop;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Multiplier= instance.parameters.Multiplier;
	
	
	local Parameters= Multiplier..", "..Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	ATR = core.indicators:create("ATR", source, Period);
    first=ATR.DATA:first() ;
	
	direction= instance:addInternalStream(0, 0);
	
	longStop= instance:addInternalStream(0, 0);
	shortStop= instance:addInternalStream(0, 0);
   
 
	Buy = instance:addStream("Buy" , core.Line, " Buy"," Buy",instance.parameters.color, first );
	Buy:setWidth(instance.parameters.width);
    Buy:setStyle(instance.parameters.style);
    Buy:setPrecision(math.max(2, source:getPrecision()));
	
	
	Sell = instance:addStream("Sell" , core.Line, " Sell"," Sell",instance.parameters.color, first );
	Sell:setWidth(instance.parameters.width);
    Sell:setStyle(instance.parameters.style);
    Sell:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    ATR:update(mode);
	
	if period < first 
	then
	return;
	end
	
	local atr_value= ATR.DATA[period]*Multiplier;
	
	longStop[period] = source.median[period] - atr_value;
    shortStop[period] = source.median[period] + atr_value;
 
 
 
     if source.close[period-1] > longStop[period-1] then
	 longStop[period]= math.max(longStop[period], longStop[period-1]); 
	 end 

    
    if source.close[period-1] < shortStop[period-1] then
	shortStop[period]=math.min(shortStop[period], shortStop[period-1]);
	end





 --  direction[period] = direction[period-1];
 
   if direction[period] ~= 1 and source.close[period] > shortStop[period-1] then
   direction[period]=1;
   elseif direction[period] ~= -1 and  source.close[period] < longStop[period-1] then 
   direction[period]=-1;
   else
   direction[period] = direction[period-1];
   end

    
	Sell[period]=Sell[period-1];
    Buy[period]=Buy[period-1];
	 
	
   if direction[period]==1 and direction[period-1] ==-1 then
    Buy[period]=longStop[period];	
    end
   
    if direction[period]==-1 and direction[period-1] ==1 then
	Sell[period]=shortStop[period];
   end
	 
			  
end


--[[
CODE: SELECT ALL
barsBack = input(title="ATR Period", defval=1)
multiplierFactor = input(title="ATR multiplier", step=0.1, defval=0.4)
atr = multiplierFactor * atr(barsBack)

longStop = hl2 - atr
longStopPrev = nz(longStop[1], longStop)
longStop := close[1] > longStopPrev ? max(longStop, longStopPrev) : longStop

shortStop = hl2 + atr
shortStopPrev = nz(shortStop[1], shortStop)
shortStop := close[1] < shortStopPrev ? min(shortStop, shortStopPrev) : shortStop

direction = 1
direction := nz(direction[1], direction)
direction := direction == -1 and close > shortStopPrev ? 1 : direction == 1 and close < longStopPrev ? -1 : direction

buy=direction == 1 and direction[1] == -1 ? longStop : na
sell=direction == -1 and direction[1] == 1 ? shortStop : na
]]