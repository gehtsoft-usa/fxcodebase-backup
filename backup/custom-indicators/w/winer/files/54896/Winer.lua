-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32203
-- Id: 8519

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Winner");
    indicator:description("Winner");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
    indicator.parameters:addInteger("SmoothingPeriod", "Smoothing period", "Smoothing period", 5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb( 255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local SmoothingPeriod;
local Up, Down;
local first, FIRST;
local source = nil;
local OO, HH, CC, LL;
-- Streams block
local COST,pa5, rsv, pak, pad;
local MA1, MA2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    SmoothingPeriod = instance.parameters.SmoothingPeriod;
    source = instance.source;	
	 first = source:first()+SmoothingPeriod;
	  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(SmoothingPeriod) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

        assert(source:supportsVolume(), "The source must have volume");
        
        COST  = instance:addInternalStream(0, 0);
        pa5  = instance:addInternalStream(0, 0);
        rsv  = instance:addInternalStream(0, 0);
        
        MA1 = core.indicators:create("EMA", rsv, Period);
        
        pak  = instance:addInternalStream(0, 0);
        pad  = instance:addInternalStream(0, 0);
        
        MA2 = core.indicators:create("EMA", pak, Period);
        
        
       
        FIRST= math.max(MA1.DATA:first(),MA2.DATA:first());
        
      HH = instance:addInternalStream(0, 0);
	  LL = instance:addInternalStream(0, 0);
	  instance:createFromToBarGroup ("Winer", "Winer", HH, LL, Up)
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	COST[period]= ((2*source.close[period]+source.high[period]+source.low[period])/4)*source.volume[period];
 
 
 
 if period < first  then
        return;	
    end
	
 local scost5 = mathex.sum(COST,period -SmoothingPeriod+1, period );
 local svolume5 = mathex.sum(source.volume,period -SmoothingPeriod+1, period );
  pa5[period] = scost5/svolume5;
  
   if period < first +Period  then
        return;	
    end
 
 rsv[period] = (pa5[period]-mathex.min(pa5,period- Period+1, period ))/(mathex.max(pa5,period- Period+1, period)-mathex.min(pa5,period- Period+1, period))*100;

 MA1:update(mode); 
 pak[period]= MA1.DATA[period];
 
 MA2:update(mode);
 
 if period < MA2.DATA:first() then
 return;
 end
 
 
 pad[period]= MA2.DATA[period];
 
 if period < FIRST then
 return;
 end
 
 HH[period]= math.max(pak[period], pad[period]); 
 LL[period]= math.min(pak[period], pad[period]); 
 core.host:execute ("setStatus", "High : " .. HH[period] .. ", Low : " .. LL[period] )
 
	 if  pak[period] >  pad[period] then
	 HH:setColor(period, Up);
	 else
	 HH:setColor(period, Down);
	 end
 end













