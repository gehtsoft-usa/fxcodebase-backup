-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71823

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
    indicator:name("Elegant oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("bandEdgeInput", "Band edge", "", 20, 1, 2000);
    indicator.parameters:addInteger("lengthRMSInput", " Oscillator period", "", 50, 1, 2000);
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local bandEdgeInput, lengthRMSInput; 
local Indicator;
local ANG_FREQ;	
local alpha, coef2, coef1, coef0;
local ift,deriv1,deriv2;
-- Routine
 function Prepare(nameOnly)   
 
    
	bandEdgeInput=instance.parameters.bandEdgeInput;
	lengthRMSInput=instance.parameters.lengthRMSInput;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  bandEdgeInput.. "," ..  lengthRMSInput  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


	
    ANG_FREQ = math.pi * math.sqrt(2) / bandEdgeInput;
	
	alpha  =  math.exp(-ANG_FREQ);
    coef2  = -math.pow(alpha, 2);
    coef1  =  math.cos(ANG_FREQ) * 2.0 * alpha;
    coef0  = 1.0 - coef1 - coef2;	
  
	deriv1 = instance:addInternalStream(0, 0); 
	deriv2 = instance:addInternalStream(0, 0); 
	
	ift = instance:addInternalStream(0, 0); 
	first=source:first()+2 ; 
	
    --deriv
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first+lengthRMSInput );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 
   if period < first then
   return;
   end 
   deriv1[period]  = (source[period] - source[period-2]) ;
   deriv2[period] = math.pow(deriv1[period], 2);

    if period < first +lengthRMSInput then
    return;
    end 
   
   local rms = mathex.sum(deriv2, period-lengthRMSInput+1, period);
   rms = math.sqrt(rms / lengthRMSInput);
   
   
    ift[period]= math.exp(2.0 * deriv1[period] / rms);
	ift[period]= (ift[period] - 1.0) / (ift[period] + 1.0);
	

    local sma2   = 0.5 * (ift[period] + ift[period-1]); 
	Line[period]= coef0 * sma2 +  coef1 * Line[period-1] + coef2 * Line[period-2];
	
	if Line[period]  > 0 then
	Line:setColor(period, instance.parameters.Up);
	else
	Line:setColor(period, instance.parameters.Down);
	end
	
	
end


 