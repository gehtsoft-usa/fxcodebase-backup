-- Id: 19774

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65386

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("RSI midline Indicator");
    indicator:description("RSI midline Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    local colour = core.colors();
    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 14);

	 indicator.parameters:addGroup("Channel Calculation"); 
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


    indicator.parameters:addInteger("Period", "Period", "", 20);
	
	indicator.parameters:addInteger("DeviationPeriod", "Deviation Period", "", 20);
	indicator.parameters:addDouble("DeviationMultiplier", "Deviation Multiplier", "", 2);

	
	indicator.parameters:addGroup("Line Style");
 --   indicator.parameters:addColor("ZL_color", "Zero line color", "", colour.Yellow);
    indicator.parameters:addColor("MID_color", "Mid line color", "", colour.Gray);
	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);


	
	indicator.parameters:addGroup("Channel Style");
	indicator.parameters:addColor("TLC", "Top Line color", "", core.rgb(0, 200, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("BLC", "Bottom Line Color", "", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("CLC", "Central Line Color", "", core.rgb(0, 0, 200));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
 
	
	 
end

local RSIPeriod;
local RSI;

local first;


local source = nil;
local AVERAGES, Method, Period;
-- Streams block
local Top, Bottom, Central;
local DeviationPeriod, DeviationMultiplier;
-- Routine
function Prepare(nameOnly)
    RSIPeriod = instance.parameters.RSIPeriod;
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	DeviationPeriod= instance.parameters.DeviationPeriod;
	DeviationMultiplier= instance.parameters.DeviationMultiplier;
    source = instance.source;
  

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);	
	    
   if   (nameOnly) then
        return;
    end

    	RSI = core.indicators:create("RSI", source, RSIPeriod);
 
    	first = RSI.DATA:first();
        mid=instance:addStream("MID", core.Line, name.."MID", "MID", instance.parameters.MID_color, first);
    mid:setPrecision(math.max(2, instance.source:getPrecision()));

		assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
		AVERAGES = core.indicators:create("AVERAGES", mid,  Method,Period);
		
		
		Top=instance:addStream("Top", core.Line, name, "Top", instance.parameters.TLC,  AVERAGES.DATA:first()  +DeviationPeriod);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.BLC, AVERAGES.DATA:first()  +DeviationPeriod);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Central=instance:addStream("Central", core.Line, name, "Central", instance.parameters.CLC,  AVERAGES.DATA:first());
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
		Central:setWidth(instance.parameters.width4);
        Central:setStyle(instance.parameters.style4);
        mid:setWidth(instance.parameters.width1);
        mid:setStyle(instance.parameters.style1);
    
  
end

function Update(period,mode)
    if period < first or not source:hasData(period) then
        return;		
    end
	RSI:update(mode);	
    
	mid[period] = RSI.DATA[period];
	
	
   	AVERAGES:update(mode);	
	
	if period <  AVERAGES.DATA:first()  then
	return;
	end
	
    Central[period]= AVERAGES.DATA[period];	
	
	local Deviation= mathex.stdev (mid, period-DeviationPeriod+1, period)*DeviationMultiplier;
	

	Top[period]= Central[period]+Deviation;
    Bottom[period]= Central[period]-Deviation;
	
end
