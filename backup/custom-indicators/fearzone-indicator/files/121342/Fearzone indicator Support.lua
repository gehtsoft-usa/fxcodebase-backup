-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66693

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
    indicator:name("Fearzone indicator Support");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 30, 1, 2000);
	indicator.parameters:addInteger("Average_Period", "Average Period", "", 100, 1, 2000);
	indicator.parameters:addInteger("StDev_Period", "StDev Period", "", 100, 1, 2000);
 
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period, Average_Period, StDev_Period;
 
local first;
local source = nil;
 
local FZ1, FZ2;
 

local open=nil;
local close=nil;
local high=nil;
local low=nil;


-- Routine
 function Prepare(nameOnly)   
 
  
    Period= instance.parameters.Period;
    Average_Period= instance.parameters.Average_Period; 
    StDev_Period = instance.parameters.StDev_Period;
	
	
	local Parameters= Period ..  ", " .. Average_Period ..  ", " .. StDev_Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	first=source:first()+Period;
	
    FZ1 = instance:addInternalStream(0, 0);
	FZ2 = instance:addInternalStream(0, 0); 
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first());
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first());
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first());
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first());	
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close);
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	if period < first then
	return;
	end
	
	local min,max=mathex.minmax(source, period-Period+1, period);
	

	
    FZ1[period]=(max-source.close[period])/max;
	FZ2[period]=mathex.avg(source.close, period-Period+1, period);
	
	if period < first +math.max(Average_Period , StDev_Period)then
	return;
	end
	
	local av1=mathex.avg(FZ1,period-Average_Period+1, period);
    local stdv1= mathex.stdev(FZ1, period-StDev_Period+1, period);
	
	
	local FZ1Limit= av1+stdv1;
	
	
	local av2=mathex.avg(FZ2, period-Average_Period+1, period);
    local stdv2= mathex.stdev(FZ2, period-StDev_Period+1, period);
	
	
	local FZ2Limit= av2-stdv2;
	local Range=source.high[period]-source.low[period];
	
	if FZ1[period] > FZ1Limit and FZ2[period] < FZ2Limit then
    high[period]=source.low[period]-Range;
	low[period]=source.low[period]-2*Range;	
	open[period]=source.low[period]-Range;
	close[period]=source.low[period]-2*Range; 
	else
	high[period]=nil;
	low[period]=nil;
	open[period]=nil;
	close[period]=nil;
	
	end
	
	
end 