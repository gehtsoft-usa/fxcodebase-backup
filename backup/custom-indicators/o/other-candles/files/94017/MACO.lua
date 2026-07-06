-- Id: 11744
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2949

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Market Action & Contrast Oscillator (MACO)");
    indicator:description("Market Action & Contrast Oscillator (MACO)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addInteger("Trigger", "Trigger", "", 2);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb( 0, 255, 0));
	indicator.parameters:addColor("Down", "Down Candle Color", "", core.rgb( 255, 0, 0));
end

local first;
local source = nil; 
local Count,Direction;
local Up, Down;
local MACO;
local Trigger;
function Prepare(nameOnly)
    source = instance.source;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Trigger= instance.parameters.Trigger;
    local name = profile:id() .. "(" .. source:name().. "," .. Trigger  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first();
	
	Direction = instance:addInternalStream(0, 0);
	Count = instance:addInternalStream(0, 0);
	 
    MACO = instance:addStream("MACO", core.Bar, name, "MACO", Up, first)
    MACO:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

function Update(period, mode)

  
   
   if (period<=first) then
    if source.close[period]> source.open[period] then   
	Direction[period]=1;
	Count[period]=1;
	else
	Direction[period]=-1;
	Count[period]=-1;
	end
   return;   
   end 
   
   
   if source.close[period]> source.open[period] then   
	   if Count[period-1]<= 0 then
	   Count[period]=1;
	   else
	   Count[period]=Count[period-1] +1;
	   end
 
    elseif source.close[period]< source.open[period] then
       if Count[period-1]>= 0 then
	   Count[period]=-1;
	   else
	   Count[period]=Count[period-1] -1;
	   end
   else
    Count[period]=0;
   end
   
   
   
     if Count[period]>= Trigger then
	 Direction[period] = 1
	 elseif Count[period]<= -Trigger then
	 Direction[period] = -1	 
     else
     Direction[period]= Direction[period-1];   
     end
   
   local Candle= (source.high[period]-source.low[period]);
   if Direction[period] == 1  then
   MACO[period]= 0+ Candle;
   elseif Direction[period] == -1  then
   MACO[period]= 0- Candle;
   end
   
   
	
   if MACO[period]> 0 then
   MACO:setColor(period, Up);
   else
   MACO:setColor(period, Down);
   end
   
end

