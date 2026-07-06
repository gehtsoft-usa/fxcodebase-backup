-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71981

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
    indicator:name("Discontinued Signal Lines RSX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 32, 1, 2000);
    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 32, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local RSIPeriod, SignalPeriod; 
local Indicator;
 
local alpha,f88,f20;
-- Routine
 function Prepare(nameOnly)   
 
    
	RSIPeriod=instance.parameters.RSIPeriod;
	SignalPeriod=instance.parameters.SignalPeriod;
	source = instance.source
	
	alpha = 2.0/(1.0+SignalPeriod)
	
	if (RSIPeriod-1 >= 5) then
	f88 = RSIPeriod-1.0
	else
	f88 = 5.0
	end 
    
	f18 = 3.0 / (RSIPeriod + 2.0)
	f20 = 1.0 - f18
			
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  RSIPeriod.. "," ..  SignalPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	RSI= core.indicators:create("RSI", source, RSIPeriod);
	first=RSI.DATA:first() ; 
	
 
 
	
	f0= instance:addInternalStream(0, 0);
	f90= instance:addInternalStream(0, 0);
	f8= instance:addInternalStream(0, 0);
	v8= instance:addInternalStream(0, 0);
	f10= instance:addInternalStream(0, 0);
    f28	= instance:addInternalStream(0, 0);	
    f30	= instance:addInternalStream(0, 0);
	f38= instance:addInternalStream(0, 0);	
	f40= instance:addInternalStream(0, 0);	
	f48= instance:addInternalStream(0, 0);	
	f50= instance:addInternalStream(0, 0);
	f58= instance:addInternalStream(0, 0);
    f60	= instance:addInternalStream(0, 0);
	f68= instance:addInternalStream(0, 0);
	f70= instance:addInternalStream(0, 0);
	f78= instance:addInternalStream(0, 0);
	f80= instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
 
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
end


function Update(period, mode)

	RSI:update(mode); 

 
	 
    f0[period]=f0[period-1];
	f90[period]=f90[period-1];
	
	if period == first then
	        f90[period] = 1.0
	 
          f0[period] = 0.0
			
		 
              f8[period] =source[period]
	 
			
	else
	
	        if (f88 <= f90[period]) then
			f90[period] = f88 + 1
			end
			
			f90[period] = f90[period-1] + 1
	 
			 
		 
			f8[period] =source[period]
			v8[period] = f8[period] - f8[period-1]
			f28[period] = f20 * f28[period-1] + f18 * v8[period]
			f30[period] = f18 * f28[period] + f20 * f30[period-1]
			local vC = f28[period] * 1.5 - f30[period] * 0.5
			f38[period] = f20 * f38[period-1] + f18 * vC
			f40[period] = f18 * f38[period] + f20 * f40[period-1]
			local v10 = f38[period] * 1.5 - f40[period] * 0.5
			f48[period] = f20 * f48[period-1] + f18 * v10
			f50[period] = f18 * f48[period] + f20 * f50[period-1]
			local v14 = f48[period] * 1.5 - f50[period] * 0.5
			f58[period] = f20 * f58[period-1] + f18 * math.abs(v8[period])
			f60[period] = f18 * f58[period] + f20 * f60[period-1]
			local v18 = f58[period] * 1.5 - f60[period] * 0.5
			f68[period] = f20 * f68[period-1] + f18 * v18
			 
			f70[period] = f18 * f68[period] + f20 * f70[period-1]
			local v1C = f68[period] * 1.5 - f70[period] * 0.5
			f78[period] = f20 * f78[period-1] + f18 * v1C
			f80[period] = f18 * f78[period] + f20 * f80[period-1]
			local v20 = f78[period] * 1.5 - f80[period] * 0.5
			 
				if  (f88 >= f90[period]) and (f8[period] ~= f8[period-1])   then
				f0[period] = 1.0
				end
				if ((f88 == f90[period]) and (f0[period] == 0.0)) then
				f90[period] = 0.0
				end
				
				
			if (f88 < f90[period])
			and (v20> 0.0000000000000001) 
			then
			 
			 Line[period]  = (v14 / v20 + 1.0) * 50.0
				if (Line[period]  > 100.0) then
				Line[period]  = 100.0
				end
				if (Line[period]  < 0.0) then
				Line[period]  = 0.0
				end
			else
			Line[period]  = 50.0
			end		
	end
	 
	 

	 
 
	if Line[period]>50 then
	Top[period] = Top[period-1]+alpha*(Line[period]-Top[period-1]);
	Bottom[period]=Bottom[period-1];
	else
	Bottom[period] = Bottom[period-1]+alpha*(Line[period]-Bottom[period-1])
	Top[period]=Top[period-1];	
	end 
end
 