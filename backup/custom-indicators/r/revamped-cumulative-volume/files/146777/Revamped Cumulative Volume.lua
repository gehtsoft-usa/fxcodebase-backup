-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72518

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
    indicator:name("Cumulative Volume");
    indicator:description("Cumulative Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "Period", "Period", 14);
	 indicator.parameters:addBoolean("Cumulative", "Combined", "Combined" ,  true);
	 indicator.parameters:addBoolean("Relative", "Relative", "Relative" ,  false);
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addColor("Pozitiv", "Color Pozitiv", " ", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ", " ", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Cum", "Color of Cumulative", " ", core.rgb(0, 0, 255));	
    indicator.parameters:addColor("Total", "Color of Total", " ", core.COLOR_LABEL );		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Period;
local Pos, Neg;
local pos,neg;
local Cumulative,Relative;
-- Routine
	 function Prepare(nameOnly)   
    Period = instance.parameters.Period;
	Relative = instance.parameters.Relative;
	Cumulative = instance.parameters.Cumulative;
    source = instance.source;
    first = source:first()+Period;
	
	

 
      local name = profile:id() .. "(" ..  (Relative and "Relative" or "Absolute") .. ", " .. (Cumulative and "Combined" or "Separated") .. ")";
    instance:name(name);


    if   (nameOnly) then
        return;
    end
    
	if not Relative then
 	Total = instance:addStream("Total", core.Line, name .. ".Total", "Total", instance.parameters.Total, first);
    Total:setPrecision(math.max(2, instance.source:getPrecision())); 
	else
 	Total = instance:addInternalStream(0, 0);
	end
	pos = instance:addInternalStream(0, 0);
	neg = instance:addInternalStream(0, 0);
        if Cumulative    then
		

		 
		 Cum = instance:addStream("C", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.Cum, first);
         Cum:setPrecision(math.max(2, instance.source:getPrecision()));
		 
        Pos = instance:addStream("P", core.Line, name .. ".Pozitiv", "Pozitiv", instance.parameters.Pozitiv, first);
        Pos:setPrecision(math.max(2, instance.source:getPrecision()));
        Neg = instance:addStream("N", core.Line, name .. ".Negativ", "Negativ", instance.parameters.Negativ, first);	
        Neg:setPrecision(math.max(2, instance.source:getPrecision()));
		
		else		
        Pos = instance:addStream("P", core.Bar, name .. ".Pozitiv", "Pozitiv", instance.parameters.Pozitiv, first);
        Pos:setPrecision(math.max(2, instance.source:getPrecision()));
        Neg = instance:addStream("N", core.Bar, name .. ".Negativ", "Negativ", instance.parameters.Negativ, first);	
        Neg:setPrecision(math.max(2, instance.source:getPrecision()));
		
		 Cum = instance:addStream("C", core.Line, name .. ".Cumulative", "Cumulative", instance.parameters.Cum, first);
         Cum:setPrecision(math.max(2, instance.source:getPrecision()));
		 

        end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    	      if source.close[period]>source.close[period-1] then
			  pos[period]=source.volume[period];
			  neg[period]=0;
			  else
			  neg[period]=source.volume[period];
			  pos[period]=0;
			  end
			  
 
     if period <= first  
	  then
	 return;
	 end
   

			 
              local denominator = mathex.sum(source.volume, period-Period+1, period) / 100;
			  local p, n;
			  local p = mathex.sum(pos, period-Period+1, period) / 100;
			  local n = mathex.sum(neg , period-Period+1, period) / 100;
			  
			 
			     if Relative then				
				 Cum[period]=((p-n)/denominator)*100;
				 else
			      Cum[period]=(p-n);
				 end
			 
				   if Relative then
				  Pos[period]= (p/denominator)*100;
				  Neg[period]= -(n/denominator)*100;
				  else
				   Pos[period]= p;
				  Neg[period]= -n;
				  end
           
     Total[period]=p+n;
end

