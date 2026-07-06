-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63380

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
    indicator:name("Elder Impulse System Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addGroup("EMA Calculation");
	indicator.parameters:addInteger("MA_Period", "EMA Period", "", 13, 2, 1000);
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN, LN, IN= nil;
local MA_Period;
local MACD;
local MA;

 


function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
    
    
    IN = instance.parameters.IN;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	MA_Period = instance.parametersMA_Period;
	
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	

	source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	MACD=core.indicators:create("MACD",  source.close, SN, LN, IN);
	MA=core.indicators:create("EMA",  source.close, MA_Period);    
	
	first= math.max(MA.DATA:first(), MACD.DATA:first());

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	

   
			   MACD:update(mode);
			   MA:update(mode);
		 
	 
--[[
Green Price Bar: (13-period EMA > previous 13-period EMA) and 
                 (MACD-Histogram > previous period's MACD-Histogram)

Red Price Bar: (13-period EMA < previous 13-period EMA) and 
               (MACD-Histogram < previous period's MACD-Histogram)

Price bars are colored blue when conditions for a Red Price Bar or 
Green Price Bar are not met. The MACD-Histogram is based on MACD(12,26,9). 
]]


		
		if MACD.HISTOGRAM[period]>   MACD.HISTOGRAM[period-1]
		and  MA.DATA[period]>   MA.DATA[period-1]
		then
		open:setColor(period,Up);	   
		elseif MACD.HISTOGRAM[period]<  MACD.HISTOGRAM[period-1] 
		and  MA.DATA[period]<   MA.DATA[period-1]
		then		
		open:setColor(period,  Down);
        else
		open:setColor(period, Neutral);			
		end
		
		
				

		
 end


