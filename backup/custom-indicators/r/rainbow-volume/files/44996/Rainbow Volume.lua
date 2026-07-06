-- Id: 7899
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26221


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
    indicator:name("Rainbow Volume");
    indicator:description("Rainbow Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addColor("UUC", "Up Price / Up Volume Color", "Up Price / Up Volume Color", core.rgb(0,255,0));
	indicator.parameters:addColor("UDC", "Up Price / Down Volume Color", "Up Price / Down Volume Color", core.rgb(0,0,255));
	indicator.parameters:addColor("DDC", "Down Price / Down Volume Color", "Down Price / Down Volume Color", core.rgb(255,0,0));
	indicator.parameters:addColor("DUC", "Down Price / Up Volume Color", "Down Price / Up Volume Color", core.rgb(255,128,0));
    indicator.parameters:addColor("NC", "Neutral Color", "Neutral Color", core.rgb(128, 128, 128));
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
local Volume = nil;
local NC, UUP,DDC, UDC, DUC ;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	NC = instance.parameters.NC;
	UUC = instance.parameters.UUC;
	DDC = instance.parameters.DDC;
	UDC = instance.parameters.UDC;
	DUC = instance.parameters.DUC;
	
    source = instance.source;
    first = source:first()+Period;
	
	 assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", NC, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	Volume:setColor(period, NC);
	
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	
        Volume[period] = source.volume[period];
		
		if source.close[period] > source.close[period-Period] and source.volume[period] > source.volume[period-Period] then		
		Volume:setColor(period, UUC);
		elseif source.close[period] > source.close[period-Period] and source.volume[period] < source.volume[period-Period] then	
		Volume:setColor(period, UDC);
		elseif source.close[period] < source.close[period-Period] and source.volume[period] > source.volume[period-Period] then	
		Volume:setColor(period, DUC);
        elseif source.close[period] < source.close[period-Period] and source.volume[period] < source.volume[period-Period] then	
		Volume:setColor(period, DDC);
		end
end

