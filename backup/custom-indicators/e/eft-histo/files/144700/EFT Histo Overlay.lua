-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71785

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
    indicator:name("EFT Histo Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");	

 	 indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 30, 1, 2000);	
    indicator.parameters:addDouble("PriceSmooth", "Price smoothing", "", 0.3, 0, 0.9999);		
    indicator.parameters:addDouble("IndexSmooth", "Index smoothing", "", 0.3, 0, 0.9999);		
 
	
 
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
 
	
local first;
local source = nil;
local Period;

	
-- Routine
 function Prepare(nameOnly)   
 
    PriceSmooth=instance.parameters.PriceSmooth;
	IndexSmooth=instance.parameters.IndexSmooth;
	
    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;	
	
    Period=instance.parameters.Period;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period  .. ", " ..  PriceSmooth .. ", " ..  IndexSmooth.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	
	source = instance.source
	first=source:first()+Period ; 
	
 
	
	
    Line = instance:addInternalStream(0, 0);	
    Trend = instance:addInternalStream(0, 0);	
    Temp = instance:addInternalStream(0, 0);	
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
end


function Update(period, mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
 
 if period < first then 
 open:setColor(period, Neutral);	 
 return; 
 end
 
 local min,max=mathex.minmax(source, period-Period+1, period);
 
 
 
    Temp[period]= PriceSmooth*((source.close[period]-min)/(max-min)-0.5)+PriceSmooth*Temp[period-1];
	if Temp[period] > 0.9999 then
	Temp[period]= 0.9999;
    elseif Temp[period] < -0.9999 then
	Temp[period]= -0.9999;	
	end
	
    Line[period]=IndexSmooth*math.log((1.0+Temp[period])/(1.0-Temp[period]))+IndexSmooth*Line[period-1]; 
	
   if Line[period]> 0 then
   Trend[period]=1;   
   elseif Line[period]< 0 then
   Trend[period]=-1;      
   else  
   Trend[period]  =Trend[period-1];
   end
   
    if  Trend[period]== 1 then
    open:setColor(period,  Up);
    elseif  Trend[period]== -1 then 
    open:setColor(period,  Down);	
    else
    open:setColor(period,  Neutral);	
    end
    
end

 