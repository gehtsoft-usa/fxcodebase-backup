-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72444

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Monster Cumulative Delta");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down ;
local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
 
	
 

	source = instance.source;
	first= source:first();	
	cumDelta= instance:addInternalStream(0, 0); 
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)

	
			if period < first then 
			return;
			end
	

 

	 local U1=0.0
	 local D1=0.0
	 
	if source.close[period]>=source.open[period] and (source.close[period]-source.open[period]+2*(source.high[period]-source.close[period])+2*(source.open[period]-source.low[period])) > 0   then 
	 U1 = source.volume[period]*(source.high[period]-source.low[period])/(source.close[period]-source.open[period]+2*(source.high[period]-source.close[period])+2*(source.open[period]-source.low[period])) 
	end 
	 
	if source.close[period]<source.open[period] and (source.open[period]-source.close[period]+2*(source.high[period]-source.open[period])+2*(source.close[period]-source.low[period])) > 0    then 
	 D1 = source.volume[period]*(source.high[period]-source.low[period])/(source.open[period]-source.close[period]+2*(source.high[period]-source.open[period])+2*(source.close[period]-source.low[period])) 
	end 	
 
    local Delta;
	
	if(source.close[period]>=source.open[period]) then 
	 Delta= U1 
	else
	 Delta= -D1 
	end  
 
 
    cumDelta[period]= cumDelta[period-1]+Delta;
	
	
	 if source.close[period]>=source.open[period] then 
	  hi= cumDelta[period]; 
	 else
	  hi =cumDelta[period-1]
	 end 
	 if source.close[period]<=source.open[period] then 
	  lo= cumDelta[period] 
	 else 
	  lo=cumDelta[period-1]
	 end 
	 
	 
	 	
    open[period] = cumDelta[period-1];
	close[period] = cumDelta[period];
	high[period] = hi;
	low[period] = lo;
	
	 
 
 

        if close[period] > open[period] then  
		open:setColor(period,  Up); 
		else
		open:setColor(period,  Down); 		
        end 
		
		
				

		
 end


 
