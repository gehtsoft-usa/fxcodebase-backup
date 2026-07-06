-- Id: 12644
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61278

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
    indicator:name("Tom Demark Moving Average");
    indicator:description("Tom Demark Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TrendPeriod", " Trend Period", "Period", 12);
	indicator.parameters:addInteger("MovingAveragePeriod", " Moving Average Period", "Period", 5);

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of TDMA Up", "Color of TDMA", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of TDMA Down", "Color of TDMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local TrendPeriod;
local MovingAveragePeriod;
local first;
local source = nil;
local High, Low;
-- Streams block
local TDMA = nil;
local Up,Down;
local Trend;
-- Routine
function Prepare(nameOnly)
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	
    TrendPeriod = instance.parameters.TrendPeriod;
	MovingAveragePeriod = instance.parameters.MovingAveragePeriod;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TrendPeriod) .. ", " .. tostring(MovingAveragePeriod).. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		Trend= instance:addInternalStream(0, 0);
		
		High=  core.indicators:create("MVA", source.high,  MovingAveragePeriod);
		Low=  core.indicators:create("MVA", source.low,  MovingAveragePeriod);
		first =math.max(High.DATA:first(), TrendPeriod);
        TDMA = instance:addStream("TDMA", core.Line, name, "TDMA", Up, first);
		TDMA:setWidth(instance.parameters.width);
        TDMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    High:update(mode);
	Low:update(mode);

    if period < first or not  source:hasData(period) then
	return;
	end
	
	local   max = mathex.max(source.low, period-1-TrendPeriod+1, period-1 );
	local   min = mathex.min(source.high, period-1-TrendPeriod+1, period-1 );
	
	
	if Trend[period-1] == 1 or Trend[period-1] == -1 then 
	Trend[period]=0;
	elseif Trend[period-1] > 1 then 
	Trend[period]=Trend[period-1]-1;
	elseif Trend[period-1] < -1 then
	Trend[period]=Trend[period-1]+1;
	end
	
	if source.low[period]>  max then
	Trend[period]= MovingAveragePeriod;
	elseif source.high[period] < min then
	Trend[period]= -MovingAveragePeriod;
	end
	
	
	
	    if Trend[period] == MovingAveragePeriod then
        TDMA[period] = Low.DATA[period];		 
		elseif Trend[period] == -MovingAveragePeriod then
		TDMA[period] = High.DATA[period];		 
		elseif Trend[period]~= 0 then
		TDMA[period]=TDMA[period-1];
		else
		TDMA[period]=nil;		
		end
		
		if Trend[period]  > 0 then
		TDMA:setColor(period, Up);
		elseif Trend[period]  < 0 then
		TDMA:setColor(period, Down);
		end
 
        if   (Trend[period] >0 and  Trend[period-1] <=0 )
		or  (Trend[period] <0 and  Trend[period-1] >=0 )
		then 	 
       TDMA:setBreak (period, true);
	   else
	    TDMA:setBreak (period, false);
	   end
	   
		
    
end

