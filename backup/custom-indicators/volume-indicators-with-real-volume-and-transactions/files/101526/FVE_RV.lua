-- Id: 14496

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Finite Volume Elements with Real volume/Transactions");
    indicator:description("Finite Volume Elements with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("FVE Calculation");	
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period1", "Period", "Period", 22);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("Smoothing Calculation");	
	indicator.parameters:addInteger("Period2", "Period", "Period", 22);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("FVE_color", "Color of FVE", "Color of FVE", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Method1;
local Period2, Method2;
local first;
local Ind;

local FirstStart;
local LastTime;
local source = nil;

-- Streams block
local FVE = nil;
local Signal = nil;
local INTRA,INTER, VE;
local MA1, MA2;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Method1 = instance.parameters.Method1;
	Period2 = instance.parameters.Period2;
	Method2 = instance.parameters.Method2;
    source = instance.source;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Method1).. ", " .. tostring(Period2) .. ", " .. tostring(Method2).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    first = source:first()+Period1;
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
	
	 assert(source:supportsVolume(), "The source must have volume");
	 
	INTRA = instance:addInternalStream(0, 0);
	INTER = instance:addInternalStream(0, 0);
    VE= instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, Ind.DATA, Period1);
	
    FirstStart=true;
    LastTime=0;

  

    if (not (nameOnly)) then
        FVE = instance:addStream("FVE", core.Line, name .. ".FVE", "FVE", instance.parameters.FVE_color, math.max(Period1+1,  MA1.DATA:first()));
    FVE:setPrecision(math.max(2, instance.source:getPrecision()));
		FVE:setWidth(instance.parameters.width1);
        FVE:setStyle(instance.parameters.style1);
		if Period2 > 0 then 
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		MA2 = core.indicators:create(Method2, FVE, Period2);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, MA2.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  

    INTRA[period] = math.log(source.high[period]) - math.log(source.low[period]);
	INTER[period] = math.log(source.typical[period]) -math.log(source.typical[period-1]);
	
	
	if period < first  then
	return;
	end
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
	local VINTRA = mathex.stdev  (INTRA, period-Period1+1, period);	
	local VINTER = mathex.stdev  (INTER, period-Period1+1, period);
 
    local CUTOFF = 0.1 * (VINTER + VINTRA) * source.close[period];
    local MF = source.close[period] - (source.high[period] + source.low[period])/2 + source.typical[period] - source.typical[period-1];
	
	if MF > CUTOFF then
     VE[period] = Ind.DATA[period];
    elseif MF < -CUTOFF then
     VE[period] = -Ind.DATA[period];
    else
     VE[period] = 0;
	end
	
	 MA1:update(mode);
	
	if period < MA1.DATA:first() then
	return;
	end
	
         FVE[period] = 100 * mathex.sum (VE, period-Period1+1, period) / (MA1.DATA[period] * Period1) ;
		 
		 
		if Period2 > 0 then		
		 MA2:update(mode);
         Signal[period] =  MA2.DATA[period];
		end
    
end

function AsyncOperationFinished(cookie, success, message)

end

  --[[  INTRA = LOG(HI) - LOG(LO)
VINTRA = STD(INTRA, PERIOD)
INTER = LOG(TYP) - LOG(TYP.1)
VINTER = STD(INTER, PERIOD)
CUTOFF = 0.1 * (VINTER + VINTRA) * CL
MF = CL - (HI + LO)/2 + TYP - TYP.1

VE = Volume Element
IF(MF > CUTOFF)
     VE = +VOL
ELSE IF(MF < -CUTOFF)
     VE = -VOL
ELSE
     VE = 0
FVE = 100 * SUM(VE, PERIOD) / (MA(VOL, PERIOD) * PERIOD)  
]]
