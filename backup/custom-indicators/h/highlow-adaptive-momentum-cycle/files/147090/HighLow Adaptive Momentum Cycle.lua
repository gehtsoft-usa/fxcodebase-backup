-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72625

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("HighLow Adaptive Momentum Cycle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("myPeriod", "Fast MA", "", 21, 1, 2000);
    indicator.parameters:addBoolean("Adaptive", "Adaptive", "", true);
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("Up", "Up Trend Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("UpDown", "Down in Up Trend Bar Color", "", core.rgb(0, 200, 0)); 
	 indicator.parameters:addColor("DownUp", "Up in Down Trend Bar Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("Down", "Down Trend Bar Color", "", core.rgb(200, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local myPeriod, Adaptive; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	myPeriod=instance.parameters.myPeriod;
	Adaptive=instance.parameters.Adaptive;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  myPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	myVAR1 = instance:addInternalStream(0, 0);

	first=source:first()+myPeriod ; 
	
 
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
	 averagePeriod = myPeriod
	 if adaptive  then 
	  minPeriod = math.floor(averagePeriod/2.0)
	  maxPeriod = minPeriod*5.0
	  endPeriod = math.floor(maxPeriod)
	  signal    = math.abs((source.median[period]-source.median[period-endPeriod]))
	  noise     = 0.00000000001
	 
	  for k=1 , endPeriod, 1 do
	   noise=noise+math.abs(source.median[period]-source.median[period-k])
	   averagePeriod = math.floor(((signal/noise)*(maxPeriod-minPeriod))+minPeriod)
	  end
	 
	 end 
	
	
 
 myLow, myHigh= mathex.minmax(source, period-averagePeriod, period);
 
 
 myVAR1[period]  = 0.66 * ((source.median[period] - myLow) / (myHigh - myLow) - 0.5) + 0.67 * myVAR1[period-1]
 myVAR1[period]  = math.min(math.max(myVAR1[period], -0.999), 0.999)
 Line[period] = math.log((myVAR1[period] + 1.0) / (1 - myVAR1[period])) / 2.0 + Line[period-1] / 2.0  
    
	if Line[period] > 0 then
	 if Line[period]> Line[period-1] then
	 Line:setColor(period,  instance.parameters.Up);
     else	 
	 Line:setColor(period,  instance.parameters.UpDown);	
	 end
	else
	 if Line[period]> Line[period-1] then
	 Line:setColor(period,  instance.parameters.DownUp);	
	 else
	 Line:setColor(period,  instance.parameters.Down);
	 end
	end
end

 