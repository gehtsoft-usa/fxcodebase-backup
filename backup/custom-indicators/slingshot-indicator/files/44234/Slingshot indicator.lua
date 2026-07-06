-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25752
-- Id: 7860

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
    indicator:name("Slingshot indicator");
    indicator:description("Slingshot indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("1. Line Calculation");	
    indicator.parameters:addInteger("N1", "Period", "Period", 14);
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");

    indicator.parameters:addGroup("2. Line Calculation");	
     indicator.parameters:addInteger("N2", "Period", "Period", 14);
     indicator.parameters:addString("Price2", "Price Source", "", "low");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color1", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Color2", "Line Color", "Line Color", core.rgb( 255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end
local ONE, TWO;
local first;
local source = nil;
local N1, N2;
local Price1, Price2;

function Prepare(nameOnly)
    Price1=instance.parameters.Price1;
	Price2=instance.parameters.Price2;
    source = instance.source;
    N1=instance.parameters.N1;
	N2=instance.parameters.N2;
    first = math.max(N1, N2);
    local name = profile:id() .. "(" .. source:name()  .. ", " .. source:barSize() .. ", " .. N1 .. ", " .. Price1 .. ", " .. N2 .. ", " .. Price2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ONE = instance:addStream("One", core.Bar, name .. "." .. Price1,  Price1, instance.parameters.Color1, first);
    ONE:setPrecision(math.max(2, instance.source:getPrecision()));
	TWO = instance:addStream("Two", core.Line, name .. "." .. Price2,  Price2, instance.parameters.Color2, first);
    TWO:setPrecision(math.max(2, instance.source:getPrecision()));
	
	TWO:setWidth(instance.parameters.width);
    TWO:setStyle(instance.parameters.style);
end

function Update(period, mode)
    if (period<first ) then
	return;
	end
	
     ONE[period]=source[Price1][period]-source[Price1][period-N1];
     TWO[period]=source[Price2][period]-source[Price2][period-N2]; 
end

