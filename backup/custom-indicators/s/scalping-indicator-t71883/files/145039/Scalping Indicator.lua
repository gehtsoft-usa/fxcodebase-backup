-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71883

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
    indicator:name("Scalping Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("intensity", "Intensity", "", 50, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("Up", "Up Bar Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Bar Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local intensity; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	intensity=instance.parameters.intensity;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  intensity  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+intensity; 
 
    ld_40 = instance:addInternalStream(0, 0);
	ld_64 = instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end

local li_108;

function Update(period, mode)

	--  Indicator:update(mode); 

	 if period < first then
	 return;
	 end
 
	  
	  local l_low_88, l_high_96=mathex.minmax(source, period-intensity+1, period);
	  
      local ld_80 = (source.high[period] + source.low[period]) / 2.0;
      local ld_32 = 0.66 * ((ld_80 - l_low_88) / (l_high_96 - l_low_88) - 0.5) + 0.05 * ld_40[period-1];
      local ld_32 = math.min(math.max(ld_32, -0.999), 0.999);
      Line[period] = math.log((ld_32 + 1.0) / (1 - ld_32)) / 2.0 + ld_64[period-1] / 2.0;
      ld_40[period] = ld_32;
      ld_64[period] = Line[period];
   
      if Line[period] > 0 then
      Line:setColor(period,  instance.parameters.Up);
	  else
      Line:setColor(period,  instance.parameters.Down);	  
	  end
	  
	
end
 