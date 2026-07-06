-- Id: 14612

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Winner with Real volume/Transactions");
    indicator:description("Winner with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
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
local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    SmoothingPeriod = instance.parameters.SmoothingPeriod;
    source = instance.source;	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(SmoothingPeriod) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
	 first = source:first()+SmoothingPeriod;
	  
	COST  = instance:addInternalStream(0, 0);
	pa5  = instance:addInternalStream(0, 0);
	rsv  = instance:addInternalStream(0, 0);
	
	MA1 = core.indicators:create("EMA", rsv, Period);
	
	pak  = instance:addInternalStream(0, 0);
	pad  = instance:addInternalStream(0, 0);
	
	MA2 = core.indicators:create("EMA", pak, Period);
	
	
   
	FIRST= math.max(MA1.DATA:first(),MA2.DATA:first());
	

    

    if (not (nameOnly)) then
      HH = instance:addInternalStream(0, 0);
	  LL = instance:addInternalStream(0, 0);
	  instance:createFromToBarGroup ("Winer", "Winer", HH, LL, Up)
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 if period < first  then
        return;	
    end
	
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
    
	COST[period]= ((2*source.close[period]+source.high[period]+source.low[period])/4)*Ind.DATA[period];
 
 local scost5 = mathex.sum(COST,period -SmoothingPeriod+1, period );
 local svolume5 = mathex.sum(Ind.DATA,period -SmoothingPeriod+1, period );
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













