-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27612
-- Id: 8066

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
    indicator:name("Ehlers Leading Indicator");
    indicator:description("Ehlers Leading Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("MA Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "Period", 14);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("DSP_color", "Color of DSP", "Color of DSP", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("SIGNAL_color", "Color of SIGNAL", "Color of SIGNAL", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("ELI_color", "Color of ELI", "Color of ELI", core.rgb(0, 0, 255));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1,Method1; 
local MA1, MA2, MA3;
local first;
local source = nil;

-- Streams block
local DSP, SIGNAL, ELI;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Method1 = instance.parameters.Method1;	 
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Method1).. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
        MA1 = core.indicators:create(Method1, source, Period1);
        MA2 = core.indicators:create(Method1, source, Period1*2);
        first = math.max(MA1.DATA:first(),MA2.DATA:first());
    
        DSP = instance:addStream("DSP", core.Line, name, "DSP", instance.parameters.DSP_color, first);
    DSP:setPrecision(math.max(2, instance.source:getPrecision()));
		DSP:setWidth(instance.parameters.width1);
        DSP:setStyle(instance.parameters.style1);
		
			MA3 = core.indicators:create(Method1, DSP, Period1 );
		
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.SIGNAL_color, MA3.DATA:first());
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.width2);
        SIGNAL:setStyle(instance.parameters.style2);
		
		ELI  = instance:addStream("ELI", core.Bar, name, "ELI", instance.parameters.ELI_color, MA3.DATA:first());
    ELI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period, mode)

    MA1:update(mode);
	MA2:update(mode);
    
	if period < first   then
       return;
    end
	
	
	DSP[period]= MA1.DATA[period]-MA2.DATA[period];
	
		MA3:update(mode);
		
		if period < MA3.DATA:first()   then
        return;
        end
		
	SIGNAL[period]= MA3.DATA[period];
	
	ELI[period]= DSP[period] - SIGNAL[period];
	
	
end

