-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=227

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("GHLA Averages");
    indicator:description("GHLA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "", 50, 1, 2000);
	
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");
	
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("GHLA_Up", "Color of the Line Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("GHLA_Down", "Color of the Line Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local GHLA = nil;
local Method;
local HIGH, LOW;
local pdir;
-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
	Method = instance.parameters.Method;
    source = instance.source;
	
	 pdir = instance:addInternalStream(0, 0);  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD).. ", " .. tostring(Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
 
    assert(core.indicators:findIndicator("AVERAGES") ~= nil,   "Averages.lua indicator must be installed");
	HIGH= core.indicators:create("AVERAGES", source.high, Method, PERIOD);
	LOW= core.indicators:create("AVERAGES", source.low,Method,  PERIOD);
	 
	   first = HIGH.DATA:first();
	
     
        GHLA = instance:addStream("GHLA", core.Line, name, "GHLA", instance.parameters.GHLA_Up, first);
		GHLA:setWidth(instance.parameters.width);
        GHLA:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	  HIGH:update(mode);
	  LOW:update(mode);
	  
	  local switch = 0;
	  
	   if (source.close[period] > HIGH.DATA[period]) then
            switch = 1;
        elseif (source.close[period] <  LOW.DATA[period]) then
            switch = -1;
        end        
        if (switch ~= 0) then	       
            pdir[period] = switch;
           
        else
            switch = pdir[period - 1];
			pdir[period]=pdir[period - 1];
        end
		
		 if (switch == -1) then
            GHLA[period] = HIGH.DATA[period];
        else
            GHLA[period] = LOW.DATA[period];
        end
	
       if pdir[period] == 1 then
	   GHLA:setColor(period, instance.parameters.GHLA_Up);
	   else
	    GHLA:setColor(period, instance.parameters.GHLA_Down);
	   end
   
     if pdir[period]~=pdir[period-1] then
	GHLA:setBreak (period, true); 
    else	 
	GHLA:setBreak (period, false);
	end  
end

