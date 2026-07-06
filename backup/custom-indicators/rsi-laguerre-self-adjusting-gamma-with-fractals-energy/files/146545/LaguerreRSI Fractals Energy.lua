-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72438

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
    indicator:name("LaguerreRSI Fractals Energy");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 13, 1, 2000);
 
	
	 indicator.parameters:addGroup("Gamma Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 


	 indicator.parameters:addGroup("Laguerre RSI Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0)); 

    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.20);
	indicator.parameters:addDouble("Level2", "2. Level","", 0.50);
	indicator.parameters:addDouble("Level3", "3. Level","", 0.80); 
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
local Period;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+Period ; 
	
	
	hh = instance:addInternalStream(0, 0);
	L0 = instance:addInternalStream(0, 0);
	L1 = instance:addInternalStream(0, 0);
	L2 = instance:addInternalStream(0, 0);
	L3 = instance:addInternalStream(0, 0);	
 
    gamma = instance:addStream("gamma", core.Line, name, "gamma", instance.parameters.color1, first+Period );
    gamma:setPrecision(math.max(2, instance.source:getPrecision()));
    gamma:setWidth(instance.parameters.width1);
    gamma:setStyle(instance.parameters.style1);
    gamma:addLevel(0); 
	gamma:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	gamma:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	gamma:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 
    LaguerreRSI = instance:addStream("LaguerreRSI", core.Line, name, "LaguerreRSI", instance.parameters.color2, first+Period );
    LaguerreRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    LaguerreRSI:setWidth(instance.parameters.width2);
    LaguerreRSI:setStyle(instance.parameters.style2);
    LaguerreRSI:addLevel(0);	
end


function Update(period, mode)

	 -- Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
	 local HH = math.max(source.high[period], source.close[period-1])	 
	 local min,max=mathex.minmax(source, period-Period+1, period);
     local o = (source.open[period]+ source.close[period-1]) / 2
     hh[period] = math.max(source.high[period], source.close[period-1])- math.min(source.low[period],source.close[period-1]);
     local ll = math.min(source.low[period], source.close[period-1])
     local c = (o + HH + ll + source.close[period]) / 4    
	 

	 
	 if period <= first +Period then
	 return;
	 end	
    gamma[period] = math.log( mathex.sum(hh, period-Period+1, period   ) / (max-min))/ math.log(Period);


	 L0[period] = (1 - gamma[period]) * c + gamma[period] * L0[period-1]
	 L1[period] = -gamma[period] * L0[period] + L0[period-1] + gamma[period] * L1[period-1]
	 L2[period]= -gamma[period] * L1[period] + L1[period-1] + gamma[period] * L2[period-1]
	 L3[period] = -gamma[period] * L2[period] + L2[period-1] + gamma[period] * L3[period-1]
	 
	 
	 
	 if L0[period] >= L1[period] then
	  CU1 = L0[period] - L1[period]
	  CD1 = 0
	 else
	  CD1 = L1[period] - L0[period]
	  CU1 = 0
	 end 
	 
	 if L1[period] >= L2[period] then
	  CU2 = CU1 + L1[period] - L2[period]
	  CD2 = CD1
	 else
	  CD2 = CD1 + L2[period] - L1[period]
	  CU2 = CU1
	 end 
	 
	 if L2[period] >= L3[period] then
	  CU = CU2 + L2[period] - L3[period]
	  CD = CD2
	 else
	  CU = CU2
	  CD = CD2 + L3[period] - L2[period]
	 end 
	 
	 if CU + CD ~= 0 then
	  LaguerreRSI[period] = CU / (CU + CD)
	 else
	  LaguerreRSI[period]=0
	 end 
 
 
end

--[[
//PRC_LaguerreRSI Fractals Energy | indicator
//23.03.2017
//Nicolas @ www.prorealcode.com
//Sharing ProRealTime knowledge
//translated from original code from TOS (author:Mobius)

// --- settings
//nFE=13 //length for Fractal Energy calculation
// --- end of settings

// Calculations
if barindex>nFE then
 o = (open + close[1]) / 2
 hh = Max(high, close[1])
 ll = Min(low, close[1])
 c = (o + hh + ll + close) / 4
 gamma = Log(Summation[nFE](Max(high, close[1]) - Min(low, close[1])) / (Highest[nFE](high) - Lowest[nFE](low)))/ Log(nFE)

 L0 = (1 - gamma) * c + gamma * L0[1]
 L1 = -gamma * L0 + L0[1] + gamma * L1[1]
 L2 = -gamma * L1 + L1[1] + gamma * L2[1]
 L3 = -gamma * L2 + L2[1] + gamma * L3[1]
 if L0 >= L1 then
  CU1 = L0 - L1
  CD1 = 0
 else
  CD1 = L1 - L0
  CU1 = 0
 endif

 if L1 >= L2 then
  CU2 = CU1 + L1 - L2
  CD2 = CD1
 else
  CD2 = CD1 + L2 - L1
  CU2 = CU1
 endif

 if L2 >= L3 then
  CU = CU2 + L2 - L3
  CD = CD2
 else
  CU = CU2
  CD = CD2 + L3 - L2
 endif
 
 if CU + CD <> 0 then
  lagRSI = CU / (CU + CD)
 else
  lagRSI=0
 endif
endif

RETURN gamma coloured(200,200,0) as "gamma", lagRSI coloured(0,128,255) style(line,2) as "Lague
]]