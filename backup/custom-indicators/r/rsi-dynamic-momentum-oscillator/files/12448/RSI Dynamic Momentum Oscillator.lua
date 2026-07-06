-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5087
-- Id: 4258

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
    indicator:name("Dynamic Momentum Oscillator (RSI)");
    indicator:description("Dynamic Momentum Oscillator (RSI)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Number", "RSI Period", "", 14);
	indicator.parameters:addInteger("PERIOD", "Smoothing Period", "", 14);
	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("first", "First Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("firstwidth", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("firststyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("firststyle", core.FLAG_LEVEL_STYLE);
end

local Number;
local INDICATOR;
local out;
local source;
local Indicator= {};
local first;


function Prepare(nameOnly)   
 
   Number=instance.parameters.Number;  
   PERIOD=instance.parameters.PERIOD; 
   
    source = instance.source;
	first= source:first();
    host = core.host;	
	
    local name =  profile:id() ..", " ..  source:name()  ;	
    instance:name(name);
    if nameOnly then
        return;
    end
	
	out = instance:addStream("out", core.Line, "", "DMO", instance.parameters.first, first);
    out:setWidth(instance.parameters.firstwidth);
    out:setStyle(instance.parameters.firststyle);
    out:setPrecision(2);
	
    Indicator["RSI"] =   core.indicators:create("RSI", source, Number );
	 Indicator["MVA"] =   core.indicators:create("MVA", Indicator["RSI"].DATA, PERIOD );
	
	first= Indicator["MVA"].DATA:first();
end


local Midpoint  = 50;

function Update(period, mode)

    if period < first then
	return;
	end

	Indicator["RSI"]:update(mode);
	Indicator["MVA"]:update(mode);
		
	out[period]= Midpoint - (  Indicator["MVA"].DATA[period]-   Indicator["RSI"].DATA[period]); 
end

