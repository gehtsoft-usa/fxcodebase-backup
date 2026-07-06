-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72383

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
    indicator:name("FX Major trend");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 21, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1, 0, 2000);
    indicator.parameters:addDouble("MoneyRisk", "MoneyRisk", "", 1, 0, 2000);
	
	 indicator.parameters:addGroup("Line Style");
	 indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Deviation,MoneyRisk; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	Deviation=instance.parameters.Deviation;
	MoneyRisk=instance.parameters.MoneyRisk;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  Deviation .. "," ..  MoneyRisk  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	BB= core.indicators:create("BB", source, Length,  Deviation);
	first=source:first() ; 
	
	
	Li_8 = instance:addInternalStream(0, 0);
 	Lda_12= instance:addInternalStream(0, 0); 
    Lda_16 = instance:addInternalStream(0, 0);  
	Lda_20= instance:addInternalStream(0, 0); 
	Lda_24= instance:addInternalStream(0, 0); 
	
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	BB:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    
 	Lda_12[period]=BB.TL[period];
    Lda_16[period]=BB.BL[period];
	

	  Li_8[period]=Li_8[period-1];
	  
	  
      if (source[period] > Lda_12[period-1]) then Li_8[period] = 1; end
      if (source[period] <  Lda_16[period-1]) then Li_8[period] = -1; end
	  
      if (Li_8[period] > 0 and Lda_16[period] < Lda_16[period-1]) then Lda_16[period] = Lda_16[period- 1]; end
      if (Li_8[period] < 0 and Lda_12[period] > Lda_12[period-1]) then Lda_12[period] = Lda_12[period- 1]; end	  
	  
      Lda_20[period] = Lda_12[period] + (MoneyRisk - 1.0) / 2.0 * (Lda_12[period] - Lda_16[period]);
      Lda_24[period] = Lda_16[period] - (MoneyRisk - 1.0) / 2.0 * (Lda_12[period] - Lda_16[period]);
	  
      if (Li_8[period] > 0 and Lda_24[period] < Lda_24[period-1]) then Lda_24[period] = Lda_24[period- 1];end
      if (Li_8[period] < 0 and Lda_20[period] > Lda_20[period-1]) then Lda_20[period] = Lda_20[period- 1];end
	  
	   
	
	Line[period]= 1;
	
	
	if Li_8[period]> 0 then
    Line:setColor(period,  instance.parameters.Up);		
	else
    Line:setColor(period,  instance.parameters.Down);		
	end
	
	
	
	
end