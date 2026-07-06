-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73007

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Fractal Dimension Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Period", "", 30, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local N;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	N=instance.parameters.N;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  N  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+N; 
	
	
	diff = instance:addInternalStream(0, 0); 
	
	
    FDI = instance:addStream("FDI", core.Line, name, "FDI", instance.parameters.color, first );
    FDI:setPrecision(math.max(2, instance.source:getPrecision()));
    FDI:setWidth(instance.parameters.width);
    FDI:setStyle(instance.parameters.style); 
 
end


function Update(period, mode)
 
 
	 if period <= first then
	 return;
	 end 
	 
	 local LL, HH = mathex.minmax(source, period-N+1, period);
	  
 
	 for Period = 1,  N-1, 1  do
			  if (HH ~= LL) then
				   if Period==1 then
				   length=0;
				   end
			     diff[period] = (source[period-Period] - LL) / (HH - LL) 
				 if Period > 1 then
				 length = length + math.sqrt((diff[period] - diff[period-1])*(diff[period] -  diff[period-1]) + (1 / (N*N)))
				 end   
			 end 
	end 
	  	
	 if length > 0 then  
	  FDI[period]=1+(math.log(length)+math.log(2))/(math.log(2*(N)));
	  else
	  FDI[period] = 0
     end
  
end


--[[
N = 30

once fdi=undefined

if barindex >= n-1 then
 diff=0
 length = 0
 pdiff = 0
 hh=0
 ll=0
 FDI=0
 HH = highest[N](close)
 LL = lowest[N](close)

 for Period = 1 to N-1 do
  if (HH - LL) > 0 then
   diff = (customclose[Period] - LL) / (HH - LL)
    if Period > 1 then
     length = length + SQRT(SQUARE(diff - pdiff) + (1 / SQUARE(N)))
   endif
  pdiff = diff
 endif
next

 if length > 0 then
  FDI = 1 + (LOG(length) + LOG(2)) / LOG(2 * (N))
 else
  FDI = 0
 endif
endif

return FDI AS "Fractal Dimension Index"

]]


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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