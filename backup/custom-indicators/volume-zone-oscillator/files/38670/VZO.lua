-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22397
-- Id: 7130

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
    indicator:name("VOLUME ZONE OSCILLATOR");
    indicator:description("VOLUME ZONE OSCILLATOR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculate");
    indicator.parameters:addInteger("Period", "Period", "", 6);
	indicator.parameters:addDouble("OB", "OB/OS Level", "", 40);
	indicator.parameters:addGroup("Style");
	
	 indicator.parameters:addInteger("lwidth", "VZO Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("lstyle", "VZO Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("VZO_color", "Color of VZO", "Color of VZO", core.rgb(255, 0, 0));
	
	 indicator.parameters:addInteger("width", "OS/OB Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "OS/OB Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color", "OS/OB Level Line Color", "Color of VZO", core.rgb(128, 128, 128));
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
local VZO = nil;
local VP;
local VPA, VA;
local OB;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	OB = instance.parameters.OB;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(OB) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		VP= instance:addInternalStream(0, 0);
		
		VA = core.indicators:create("EMA", source.volume, Period);
		VPA = core.indicators:create("EMA", VP, Period);
		
		 first = math.max(VA.DATA:first(),VPA.DATA:first() );
		 
        VZO = instance:addStream("VZO", core.Line, name, "VZO", instance.parameters.VZO_color, first);
		VZO:addLevel(OB, instance.parameters.style, instance.parameters.width, instance.parameters.color);    
		VZO:addLevel(-OB, instance.parameters.style, instance.parameters.width, instance.parameters.color);    
		VZO:setWidth(instance.parameters.lwidth);
        VZO:setStyle(instance.parameters.lstyle);
		
		VZO:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	if source.close[period] > source.close[period-1] then
	VP[period]= source.volume[period];
	else
	VP[period]= -source.volume[period];
	end
	
	
	VPA:update(mode);
	VA:update(mode);
	
	
	if period < first then
	return;
	end
	
	
        VZO[period] = 100 * (VPA.DATA[period]/ VA.DATA[period]);
    
end

