-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25754
-- Id: 7862

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
    indicator:name("DI Cluster");
    indicator:description("DI Cluster");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addString("Type", "Indicator Type", "", "ADX");
    indicator.parameters:addStringAlternative("Type", "ADX", "", "ADX");
    indicator.parameters:addStringAlternative("Type", "DI+", "", "DI+");
    indicator.parameters:addStringAlternative("Type", "DI-", "", "DI-");

	
    indicator.parameters:addGroup("1. Line Calculation");	
    indicator.parameters:addInteger("N1", "Period", "Period", 5);
    indicator.parameters:addGroup("2. Line Calculation");	
    indicator.parameters:addInteger("N2", "Period", "Period", 8);
	indicator.parameters:addGroup("3. Line Calculation");	
    indicator.parameters:addInteger("N3", "Period", "Period", 14);


    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color1", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color2", "Line Color", "Line Color", core.rgb( 255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color3", "Line Color", "Line Color", core.rgb( 0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
end
local Type;
local ONE, TWO,  THREE;
local first;
local source = nil;
local N1, N2, N3;
local Indicator={};

function Prepare(nameOnly)
    Type=instance.parameters.Type;   
    source = instance.source;
    N1=instance.parameters.N1;
	N2=instance.parameters.N2;
	N3=instance.parameters.N3;
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. source:barSize() .. ", " .. Type .. ", " .. N1 .. ", " .. N2 .. ", " .. N3 .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	if Type == "ADX" then
		Indicator[1] = core.indicators:create("ADX", source, N1);
		Indicator[2] = core.indicators:create("ADX", source, N2);
		Indicator[3] = core.indicators:create("ADX", source, N3);
		else
		Indicator[1] = core.indicators:create("DMI", source, N1);
		Indicator[2] = core.indicators:create("DMI", source, N2);
		Indicator[3] = core.indicators:create("DMI", source, N3);	
	end
	
	first = math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first(), Indicator[2].DATA:first());
	
    ONE = instance:addStream("One", core.Line, name .. "." .. "One",  "One", instance.parameters.Color1, first);
	ONE:setWidth(instance.parameters.width1);
    ONE:setStyle(instance.parameters.style1);
	
	TWO = instance:addStream("Two", core.Line, name .. "." .. "Two",  "Two", instance.parameters.Color2, first);
	TWO:setWidth(instance.parameters.width2);
    TWO:setStyle(instance.parameters.style2);
	
	THREE = instance:addStream("Three", core.Line, name .. "." .. "Three",  "Three", instance.parameters.Color3, first);
	THREE:setWidth(instance.parameters.width3);
    THREE:setStyle(instance.parameters.style3);
	
	ONE:setPrecision(math.max(2, instance.source:getPrecision()));
	TWO:setPrecision(math.max(2, instance.source:getPrecision()));
	THREE:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if (period<first ) then
	return;
	end 
	  Indicator[1]:update(mode);
	  Indicator[2]:update(mode);
	  Indicator[3]:update(mode); 
	 
	 
	 if Type=="ADX" then
     ONE[period]=Indicator[1].DATA[period];
	 TWO[period]=Indicator[2].DATA[period];
	 THREE[period]=Indicator[3].DATA[period];
	 elseif Type=="DI+" then
	 ONE[period]=Indicator[1].DIP[period];
	 TWO[period]=Indicator[2].DIP[period];
	 THREE[period]=Indicator[3].DIP[period];
	 else
	 ONE[period]=Indicator[1].DIM[period];
	 TWO[period]=Indicator[2].DIM[period];
	 THREE[period]=Indicator[3].DIM[period];
	 end
end

