-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71881

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
    indicator:name("Trend_Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("RangePeriods", "Range Periods", "", 120, 1, 2000);
    indicator.parameters:addDouble("PriceSmoothing", "Price Smoothing", "", 0.67, 0, 2000);
    indicator.parameters:addDouble("IndexSmoothing", "Index Smoothing", "", 0.9, 0, 2000);	
	 

	indicator.parameters:addGroup("Line Style");	  
	indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Up Down Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local RangePeriods, PriceSmoothing,IndexSmoothing; 
local Indicator;
local Gi_unused_80 = 56;
local Gi_unused_76 = 56;
-- Routine
 function Prepare(nameOnly)   
 
    
	IndexSmoothing=instance.parameters.IndexSmoothing;
	PriceSmoothing=instance.parameters.PriceSmoothing;
	RangePeriods=instance.parameters.RangePeriods; 
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  RangePeriods.. "," ..  PriceSmoothing .. "," ..  IndexSmoothing  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	G_ibuf_128= instance:addInternalStream(0, 0);
	G_ibuf_116= instance:addInternalStream(0, 0);
	first=source:first()+RangePeriods ; 
	
 
	
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	if period < RangePeriods then
	return;
	end
	 
	local min, max = mathex.minmax(source,period-RangePeriods+1, period );

	if period < first then
	return;
	end
	 
	local  Min = source:pipSize() / 10.0;
	 
   if (max - min) < Min  then max = min + Min    end
   
   
   local  Ld_20 = max - min;
   local  Ld_28 = (source.high[period] + source.low[period]) / 2.0;
   if (Ld_20 ~= 0.0)  then
      Ld_36 = (Ld_28 - min) / Ld_20;
      Ld_36 = 2.0 * Ld_36 - 1.0;
   end
 
   G_ibuf_128[period] = PriceSmoothing * (G_ibuf_128[period - 1]) + (1.0 - PriceSmoothing) * Ld_36;
 
   if (G_ibuf_128[period] > 0.99) then G_ibuf_128[period] = 0.99; end
   if (G_ibuf_128[period] < -0.99) then  G_ibuf_128[period] = -0.99; end
   if (1 - G_ibuf_128[period] ~= 0.0) then Ld_52 = math.log((G_ibuf_128[period] + 1.0) / (1 - G_ibuf_128[period])); end
   
   Line[period]  = IndexSmoothing * (G_ibuf_116[period- 1]) + (1.0 - IndexSmoothing) * Ld_52;
 
  if Line[period] > 0 then
  Line:setColor(period,   instance.parameters.Up);
  else
  Line:setColor(period,   instance.parameters.Down);
  end
 	
    
end