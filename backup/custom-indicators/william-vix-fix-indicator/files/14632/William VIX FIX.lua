-- Id: 13554
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6362

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name(" William Vix Fix indicator");
    indicator:description(" William Vix Fix indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 22);
	indicator.parameters:addInteger("bbl", "Bolinger Band Length", "Bolinger Band Length", 20);
	indicator.parameters:addDouble("mult", "Bollinger Band Standard Devaition", "Bollinger Band Standard Devaition", 2);
	
	indicator.parameters:addDouble("lb", "Look Back Period", "Look Back Period", 50);
	indicator.parameters:addDouble("ph", "Highest Percentile", "Highest Percentile", 0.85);
	indicator.parameters:addDouble("pl", "Lowest Percentile", "Lowest Percentile", 1.01);
	
	

	indicator.parameters:addGroup("Style");	
	indicator.parameters:addString("Type", "Line Type", "Type" , "Bar");
    indicator.parameters:addStringAlternative("Type", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type", "Bar", "Bar" , "Bar");
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("WVF_color_Up", "Color of WVF Up", "Color of WVF", core.rgb(0, 255, 0));
	indicator.parameters:addColor("WVF_color_Down", "Color of WVF Down", "Color of WVF", core.rgb(128,128, 128));
	indicator.parameters:addColor("Range_color", "Color of Range", "Color of Range", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Band_color", "Color of Band", "Color of Band", core.rgb(0, 0, 255));
	
	indicator.parameters:addBoolean("hp", "Show High Range", "", true);
	indicator.parameters:addBoolean("sd", "Show Standard Deviation Line", "", true);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local bbl,mult,ph,pl,lb;
local first;
local source = nil;
local Type;
-- Streams block
local WVF = nil;
local hp,sd;
local upperBand,lowerBand;
local rangeHigh, rangeLow;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Type = instance.parameters.Type;
	hp = instance.parameters.hp;
	sd = instance.parameters.sd;
	bbl = instance.parameters.bbl;
	mult = instance.parameters.mult;
	ph = instance.parameters.ph;
	pl = instance.parameters.pl;
	lb  = instance.parameters.lb; 
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    if Type == "Line" then
        WVF = instance:addStream("WVF", core.Line, name, "WVF", instance.parameters.WVF_color_Up, first);
    	WVF:setWidth(instance.parameters.width);
        WVF:setStyle(instance.parameters.style);
		else
		WVF = instance:addStream("WVF", core.Bar, name, "WVF", instance.parameters.WVF_color_Up, first);
		end
		WVF:setPrecision(math.max(2, instance.source:getPrecision()));
		
		
		 if hp  then
		 rangeHigh = instance:addStream("rangeHigh", core.Line, name, "rangeHigh", instance.parameters.Range_color,   first +  bbl + lb);
    rangeHigh:setPrecision(math.max(2, instance.source:getPrecision()));
		 rangeLow = instance:addStream("rangeLow", core.Line, name, "rangeLow", instance.parameters.Range_color, first +  bbl + lb);
    rangeLow:setPrecision(math.max(2, instance.source:getPrecision()));
		 else
		 rangeHigh= instance:addInternalStream(0, 0);
		 rangeLow= instance:addInternalStream(0, 0);
		 end
		 
        if sd then
		upperBand = instance:addStream("upperBand", core.Line, name, "upperBand", instance.parameters.Band_color, first+  bbl ); 
    upperBand:setPrecision(math.max(2, instance.source:getPrecision()));
		lowerBand = instance:addStream("lowerBand", core.Line, name, "lowerBand", instance.parameters.Band_color, first+  bbl ); 
    lowerBand:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		upperBand= instance:addInternalStream(0, 0); 
		lowerBand= instance:addInternalStream(0, 0); 
        end		
      
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
        WVF[period] = ((mathex.max (source.close, period- Period, period)- source.low[period])/mathex.max(source.close, period- Period, period))*100;
		
		
	if period < first +  bbl then
	return;
	end
		
		local sDev = mult * mathex.stdev(WVF, period-bbl+1, period);
		local midLine = mathex.avg(WVF,  period-bbl+1, period);
		
		lowerBand[period] = midLine - sDev
		upperBand[period] = midLine + sDev
		
	if period < first +  bbl + lb then
	return;
	end

		rangeHigh[period] = (mathex.max( WVF , period-lb+1,period)) * ph
		rangeLow[period] = (mathex.min( WVF, period-lb+1,period)) * pl
		
        if WVF[period] >= upperBand[period] or WVF[period] >= rangeHigh[period] then
		WVF:setColor(period, instance.parameters.WVF_color_Up);
		else
		WVF:setColor(period, instance.parameters.WVF_color_Down);
		end
		 
end
