-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3190
-- Id: 3426

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("HPF Oscillator");
    indicator:description("HPF Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

		indicator.parameters:addGroup("HPF"); 
    indicator.parameters:addInteger("Frame", "HPF Period", "Period", 50);
	
	
		indicator.parameters:addGroup("Averages ");
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
 
    indicator.parameters:addInteger("Period", "Period", "", 20);   
	
	indicator.parameters:addBoolean("Live" , "Calculate Last Candle", "", false);	

  	
		indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up_color", "Color of Up HPF", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Dn_color", "Color of Down HPF", "", core.rgb(255, 0, 0));
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Period, Method;

local first;
local source = nil;

-- Streams block
local HPF = nil;
local  Indicator ={};
local Live;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Live = instance.parameters.Live;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame.. ", " .. Method.. ", " .. Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
	assert(core.indicators:findIndicator("HPF") ~= nil, "Please, download and install HPF indicator");

	Indicator[1] = core.indicators:create("HPF", source, Frame );
	Indicator[2] = core.indicators:create("AVERAGES", Indicator[1].DATA, Method, Period, false);
	
	first = Indicator[2].DATA:first();
    HPF = instance:addStream("HPF", core.Bar, name, "HPF", instance.parameters.Up_color,Indicator[2].DATA:first());
    HPF:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local Last;
function Update(period)

	
	
	if Live then
	Shift=0;
	else
	Shift=1; 
	end
	
	if period <= first or  not source:hasData(period) or  period < (source:size()-1-Shift)  then
	Last=nil;
	return;
	end
	
	
	if Last== source:serial(source:size()-1-Shift) and not Live then
	return;
	end
	
	if not Live then
	Last=source:serial(source:size()-1-Shift);
    end
	
 
	
	Indicator[1]:update(core.UpdateAll);
	Indicator[2]:update(core.UpdateAll);
	


		
	local i;
	for i = first, period-Shift, 1 do
	        if  Indicator[1].DATA:hasData(i) and  Indicator[2].DATA:hasData(i)  then
			HPF[i] = Indicator[1].DATA[i]- Indicator[2].DATA[i] ;
			
					if  HPF[i] > HPF[i-1] then
					HPF:setColor(i, instance.parameters.Up_color);
					else
					HPF:setColor(i, instance.parameters.Dn_color);
					end
			
			
			else
			HPF[i]=nil;
			end
			
			
		end
	
end

