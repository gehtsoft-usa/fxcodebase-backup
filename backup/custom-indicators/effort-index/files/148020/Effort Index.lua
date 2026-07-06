-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72867

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
    indicator:name("Effort Index");
    indicator:description("Effort versus Result");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Vlp", "Volume lookback period", "", 40, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "Spread");
    indicator.parameters:addStringAlternative("Method", "Effort Index", "Effort Index" , "Effort Index"); 
    indicator.parameters:addStringAlternative("Method", "Spread", "Spread" , "Spread"); 
    indicator.parameters:addStringAlternative("Method", "Bar to Bar", "Bar to Bar" , "Bar to Bar"); 	
 
 
	
	 indicator.parameters:addGroup("Style");		
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 255)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 255)); 
	 indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Vlp; 
local Indicator;
local Method; 	
-- Routine
 function Prepare(nameOnly)   
 
    
	Vlp=instance.parameters.Vlp;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Vlp  .. "," ..   Method  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Vrg= core.indicators:create("MVA", source.volume, Vlp);
	first=Vrg.DATA:first()+1 ; 
	
	
	rg = instance:addInternalStream(0, 0);
	rs = instance:addInternalStream(0, 0);	
	
	arg= core.indicators:create("WMA", rg, Vlp); 
	rsg= core.indicators:create("WMA", rs, Vlp); 	
	
	Sro = instance:addInternalStream(0, 0);	
	Vro = instance:addInternalStream(0, 0);	
	Rso = instance:addInternalStream(0, 0);	
	
	RS = instance:addInternalStream(0, 0); 
	R  = instance:addInternalStream(0, 0);
	
	
	if Method == "Effort Index" then
    EI = instance:addStream("EI", core.Bar, name, "EI", instance.parameters.color1, first + Vlp);
    EI:setPrecision(math.max(2, instance.source:getPrecision()));
    EI:addLevel(0);			
	else	
	EI = instance:addInternalStream(0, 0);
	end
	
 	if Method ~= "Effort Index" then
		Effort = instance:addStream("Effort", core.Bar, name, "Effort", instance.parameters.DownColor, first + Vlp);
		Effort:setPrecision(math.max(2, instance.source:getPrecision()));
		Effort:addLevel(0);	

		AverageEffort = instance:addStream("AverageEffort", core.Line, name, "AverageEffort", instance.parameters.color2, first + Vlp+ Vlp);
		AverageEffort:setPrecision(math.max(2, instance.source:getPrecision()));
		AverageEffort:addLevel(0);	
		
		Result = instance:addStream("Result", core.Bar, name, "Result", instance.parameters.UpColor, first + Vlp);
		Result:setPrecision(math.max(2, instance.source:getPrecision()));
		Result:addLevel(0);	

		AverageResult = instance:addStream("AverageResult", core.Line, name, "AverageResult", instance.parameters.color1, first + Vlp+ Vlp);
		AverageResult:setPrecision(math.max(2, instance.source:getPrecision()));
		AverageResult:addLevel(0);			
		
	else
	Effort = instance:addInternalStream(0, 0);
	AverageEffort = instance:addInternalStream(0, 0);
	end
end


function Update(period, mode)


    if period <=source:first() then
	return;
	end
	
	rg[period]=source.high[period]-source.low[period];
	rs[period]=math.abs(source.close[period]-source.close[period-1])
	
	Vrg:update(mode); 
	arg:update(mode);	
	rsg:update(mode);	

	 if period <= first then
	 return;	 
	 end
	 
	Sro[period]  = rg[period]/arg.DATA[period]; 
	Vro[period]  = source.volume[period]/Vrg.DATA[period]; 
	Rso[period]  = rs[period]/rsg.DATA[period];  
	  

	 if period <= first + Vlp then
	 return;	 
	 end	  
	  
	local Smin, Smax = mathex.minmax(Sro, period-Vlp+1, period);
	local Vmin, Vmax = mathex.minmax(Vro, period-Vlp+1, period);
	local Rmin, Rmax = mathex.minmax(Rso, period-Vlp+1, period);
	
	RS[period] = (Sro[period] - Smin)*100/(Smax-Smin);
	Effort[period] = -(Vro[period] - Vmin)*100/(Vmax-Vmin);
	R [period] = (Rso[period] - Rmin)*100/(Rmax-Rmin);
	EI[period]   = R [period]/(-Effort[period]);
	
	if Method == "Spread" then	
	Result[period]=RS[period];
	elseif Method == "Bar to Bar" then	
	Result[period]=R[period];	
	end
	

  
	if period <= first + Vlp + Vlp then
	return;	 
	end
	
	if Method ~= "Effort Index" then	
	AverageEffort[period]=mathex.avg(Effort, period-Vlp+1, period);
	AverageResult[period]=mathex.avg(Result, period-Vlp+1, period);	 
	end
end

 


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
