-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71942

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
    indicator:name("Simplified RSX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Len", "Period", "", 14, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);			
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Len; 
local Indicator;
local alpha, ialpha;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Len=instance.parameters.Len;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Len  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	first=source:first() ; 
	
    alpha = 3 / (Len + 2); 
    ialpha = 1 - alpha;
	
	f8 = instance:addInternalStream(0, 0);
	f30 = instance:addInternalStream(0, 0);
	f40 = instance:addInternalStream(0, 0);
	f50 = instance:addInternalStream(0, 0);
	f60 = instance:addInternalStream(0, 0);
	f70 = instance:addInternalStream(0, 0);
	f80 = instance:addInternalStream(0, 0);	
	
	f28 = instance:addInternalStream(0, 0);
	f38 = instance:addInternalStream(0, 0);
	f48 = instance:addInternalStream(0, 0);
	f58 = instance:addInternalStream(0, 0);
	f68 = instance:addInternalStream(0, 0);
	f78 = instance:addInternalStream(0, 0);		
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	


	Line:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	Line:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	Line:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
end


function Update(period, mode) 

	 if period < first then
	 return;
	 end
	 
	f8[period] =  100 * source[period];
	local f10 = f8[period-1]
	local v8 = f8[period] - f10
	
	
	f28[period] = ialpha * f28[period-1] + alpha * v8
	f30[period] = alpha * f28[period] + ialpha * f30[period-1]
	vC = f28[period] * 1.5 - f30[period] * 0.5
	 
	f38[period] = ialpha * f38[period-1] + alpha * vC
	f40[period] = alpha * f38[period] + ialpha * f40[period-1]
	v10 = f38[period] * 1.5 - f40[period] * 0.5
	 
	f48[period] = ialpha * f48[period-1] + alpha * v10
	f50[period] = alpha * f48[period] + ialpha * f50[period-1]
	v14 = f48[period] * 1.5 - f50[period] * 0.5
	 
	f58[period] = ialpha * f58[period-1] + alpha * math.abs(v8)
	f60[period] = alpha * f58[period] + ialpha * f60[period-1]
	v18 = f58[period] * 1.5 - f60[period] * 0.5
	 
	f68[period]= ialpha * f68[period-1] + alpha * v18
	f70[period] = alpha * f68[period] + ialpha * f70[period-1]
	v1C = f68[period] * 1.5 - f70[period] * 0.5
	 
	f78[period] = ialpha * f78[period-1] + alpha * v1C
	f80[period] = alpha * f78[period] + ialpha * f80[period-1]
	v20 = f78[period] * 1.5 - f80[period] * 0.5
	
	
	
 
	if v20 > 0 then
	v4 = (v14 / v20 + 1) * 50
	else
	v4 = 50
	end
	 
	    if v4 > 100 then
		Line[period] = 100
		else
		Line[period] = v4
		end
    
	if Line[period]> Line[period-1] then
	Line:setColor(period,  instance.parameters.color1);	
	else
	Line:setColor(period,  instance.parameters.color2);	  
	end
	
end

