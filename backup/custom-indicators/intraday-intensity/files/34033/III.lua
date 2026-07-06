-- Id: 6648
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19120

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Intraday Intensity Index");
    indicator:description("Intraday Intensity Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 21);
     indicator.parameters:addInteger("SP", "Smoothing Period", "", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("III_color", "Color of III", "Color of III", core.rgb(255, 0, 0));


    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local III = nil;
local Raw;
local SP;
local MA;
-- Routine
function Prepare(nameOnly)
   Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
    SP = instance.parameters.SP;
    local name = profile:id() .. "(" .. source:name() .. ", ".. tostring(Period)  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    Raw = instance:addInternalStream(0, 0);

 
    III = instance:addStream("III", core.Bar, name, "III", instance.parameters.III_color, first);
    III:setPrecision(math.max(2, instance.source:getPrecision()));
	MA = core.indicators:create("MVA", III, SP);
	Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < source:first()  then
    return;   
    end
    
    if (source.high[period]-source.low[period] )~= 0  and source.volume[period] ~=0  then
    Raw[period]= ((2*source.close[period]-source.high[period]-source.low[period])/(source.high[period]-source.low[period]))*source.volume[period];  
    end
	
	
	-- Sum21 ((2C-H-L)/(H-L))xV
	 if period <  first  then
    return;   
    end
	
	  III[period]= (mathex.sum(Raw, period-Period+1, period)/mathex.sum(source.volume, period-Period+1, period)) *100; 
	
    MA:update(mode);
	
	if period <  MA.DATA:first() then
	return;
	end
	
    Signal[period]= MA.DATA[period];
    
    
end

