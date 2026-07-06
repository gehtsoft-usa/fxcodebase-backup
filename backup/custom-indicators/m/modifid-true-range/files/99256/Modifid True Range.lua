-- Id: 13788
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61999



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Modifid True Range");
    indicator:description("Modifid True Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Goal", "Goal (in Pips)", "Goal", 100);
    indicator.parameters:addInteger("PeriodLength", "PeriodLength", "PeriodLength", 40);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Achieved Color", "Achieved Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Unachieved Color", "Unachieved Color", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Goal;
local PeriodLength;

local first;
local source = nil;
local Up, Down;
-- Streams block
local MTR = nil;
local HitGoal;
-- Routine
function Prepare(nameOnly)
    Goal = instance.parameters.Goal;
    PeriodLength = instance.parameters.PeriodLength;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
    first = source:first()+PeriodLength+2;
    HitGoal= instance:addInternalStream(0, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Goal) .. ", " .. tostring(PeriodLength) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
        MTR = instance:addStream("MTR", core.Bar, name, "MTR", instance.parameters.Up, source:first());
    MTR:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	MTR[period]= math.max( math.abs( source.high[period] - source.close[period-1] ),  math.abs( source.low[period] -source.close[period-1] ) ) ;
	
    if period < first then
	return;
	end
	
	local AvgMTR = mathex.avg(MTR,period-PeriodLength+1,period);
    local StdDevMTR = mathex.stdev(MTR,period-PeriodLength+1,period) ;
	
    if  MTR[period]/source:pipSize() >= Goal then
	HitGoal[period]=1;
	MTR:setColor(period, Up);
	else
	HitGoal[period]=0;
	MTR:setColor(period, Down);
	end
	
	if period < first*2 or not  source:hasData(period) then
	return;
	end
	
	local GoalCount  = mathex.sum( HitGoal,period-PeriodLength+1 , period );
    local GoalPctAchieved=( GoalCount / PeriodLength)*100;
	
	local Text= " Goal Count : " .. GoalCount;
	Text= Text..  " Goal PCT : " ..  string.format("%." .. 2 .. "f", GoalPctAchieved);  
	Text= Text..  " Avg MTR : " ..  string.format("%." .. 2 .. "f", AvgMTR);  
	Text= Text..  " MTR Std Dev : " .. string.format("%." .. 2 .. "f",     StdDevMTR );
	core.host:execute ("setStatus", Text)
end
 