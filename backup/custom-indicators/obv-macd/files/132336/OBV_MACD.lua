-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69586
 
--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("On Balance Volume Convergence/Divergence");
    indicator:description("Displays volume as a histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("P1", "Short Period", "", 12);
	indicator.parameters:addInteger("P2", "Long Period", "", 26);
	indicator.parameters:addInteger("P3", "Signal Period", "", 9);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255));
end

local close;
local volume;
local first;
local OBV,Fast, Slow,Signal,signal;
local MACD, Signal, Histogram
function Prepare(nameOnly)

    assert(instance.source:supportsVolume(), "The source must have volume");

    close = instance.source.close;
    volume = instance.source.volume;
     

    OBV = instance:addInternalStream(0, 0);
	
	
	Fast = core.indicators:create("EMA", OBV, instance.parameters.P1);
	Slow = core.indicators:create("EMA", OBV, instance.parameters.P2);
	
	
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	 first=math.max(Fast.DATA:first() , Slow.DATA:first());

    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first);
    MACD:setPrecision(0);
	
	
	signal = core.indicators:create("MVA",MACD, instance.parameters.P3);
	
	Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, signal.DATA:first());
	Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, signal.DATA:first());
end

function Update(period, mode)
    if period == first then
        OBV[period] = volume[period];
    elseif period > first then
        if close[period] > close[period - 1] then
            OBV[period] = OBV[period - 1] + volume[period];
        elseif close[period] < close[period - 1] then
            OBV[period] = OBV[period - 1] - volume[period];
        else
            OBV[period] = OBV[period - 1];
        end
		
		
		
		Fast:update(mode);
		Slow:update(mode);
		
		if period < first then
		return;
		end
		
		MACD[period]=Fast.DATA[period]-Slow.DATA[period];
		
		signal:update(mode);
		
		if period < signal.DATA:first() then
		return;
		end
		
		Signal[period]=signal.DATA[period];
		
		Histogram[period]= MACD[period]-Signal[period];
		
    end
end

