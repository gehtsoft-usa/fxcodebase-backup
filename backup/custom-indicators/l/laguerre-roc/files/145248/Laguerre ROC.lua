-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71941

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
    indicator:name("Laguerre ROC");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("vPeriod", "Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("gamma", "gamma", "", 0.5, 0, 2000);
	
	
 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.25);
	indicator.parameters:addDouble("Level2", "2. Level","", 0.5);
	indicator.parameters:addDouble("Level3", "3. Level","", 0.75); 
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
local vPeriod, gamma; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	vPeriod=instance.parameters.vPeriod;
	gamma=instance.parameters.gamma;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  vPeriod.. "," ..  gamma  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+vPeriod ; 
	
 
    rROC = instance:addInternalStream(0, 0);	
    L0 = instance:addInternalStream(0, 0);
    L1 = instance:addInternalStream(0, 0);
    L2 = instance:addInternalStream(0, 0);
    L3 = instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
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
	 
	local L0A = L0[period-1];
    local L1A = L1[period-1];
    local L2A = L2[period-1];
    local L3A = L3 [period-1];
 
	rROC[period] = (((source[period] - source[period-vPeriod+1]) /  source[period-vPeriod+1]) + source:pipSize())
    L0[period] = ((1 - gamma)*(rROC[period])) + (gamma*L0A) 
	L1[period] = - gamma *L0[period] + L0A + gamma *L1A
	L2[period] = - gamma *L1[period] + L1A + gamma *L2A
	L3[period] = - gamma *L2[period] + L2A + gamma *L3A
	
	
	
	local  CU = 0
    local CD = 0
 
	if (L0[period] >= L1[period]) then
	  CU = L0[period] - L1[period]
	else
	  CD = L1[period] - L0[period]
	end
	 
	
	if (L1[period] >= L2[period]) then
	  CU = CU + L1[period] - L2[period]
	 else
	  CD = CD + L2[period] - L1[period]
	 end
	 
	 if (L2[period] >= L3[period]) then
	  CU = CU + L2[period] - L3[period]
	 else
	  CD = CD + L3[period] - L2[period]
	 end	
	
 
	
	
	if (CU + CD ~=0) then
    Line[period] = CU / (CU + CD)
    end
	
end
 
 