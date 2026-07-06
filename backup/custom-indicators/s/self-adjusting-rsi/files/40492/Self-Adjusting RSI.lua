-- Id: 7424
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23532

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Self-Adjusting RSI");
    indicator:description("Self-Adjusting RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("x", "Period", "Period", 14);
    indicator.parameters:addDouble("k1", "Standard Deviation", "Standard Deviation",1.8,0.1, 5  );
     indicator.parameters:addDouble("c1", "SMA constant", "SMA constant",2, 0.1, 5 );
	 
	 indicator.parameters:addInteger("m1", "Method", "",1);
     indicator.parameters:addIntegerAlternative("m1", "Standard Deviation", "", 1);
     indicator.parameters:addIntegerAlternative("m1", "Simple Moving Average", "", 2); 	 

 
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthR", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleR", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleR", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("TOP_color", "Color of TOP", "Color of TOP", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthT", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("BOTTOM_color", "Color of BOTTOM", "Color of BOTTOM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthB", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local x;
local k1;
local c1;
local m1;
local first;
local source = nil;
local Indicator;
-- Streams block
local RSI = nil;
local Top, Bottom;
local MA1, MA2, RAW;
-- Routine
function Prepare(nameOnly)
    x = instance.parameters.x;
    k1 = instance.parameters.k1;
	c1 = instance.parameters.c1;
	m1 = instance.parameters.m1;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(x) .. ", " .. tostring(k1).. ", " .. tostring(c1).. ", " .. tostring(m1) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Indicator = core.indicators:create("RSI",source,x);
		first = Indicator.DATA:first()+x;
	
		if m1 == 2 then
			MA1 = core.indicators:create("MVA",Indicator.DATA , x);
			RAW=  instance:addInternalStream(0, 0);
			MA2 = core.indicators:create("MVA",RAW , x);
			first = MA2.DATA:first();
		end
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		RSI:setWidth(instance.parameters.widthR);
        RSI:setStyle(instance.parameters.styleR);
		Top = instance:addStream("OB", core.Line, name, "OB", instance.parameters.TOP_color, first);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.widthT);
        Top:setStyle(instance.parameters.styleT);
		Bottom = instance:addStream("OS", core.Line, name, "OS", instance.parameters.BOTTOM_color, first);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.widthB);
        Bottom:setStyle(instance.parameters.styleB);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	Indicator:update(mode);
	

	
	if m1 == 1 then	
	
	Top [period] = 50+(k1* mathex.stdev(Indicator.DATA , period- x+1, period ));
	Bottom [period] = 50-(k1* mathex.stdev(Indicator.DATA , period- x+1, period ));
	
	elseif m1 == 2 then   
	MA1:update(mode);
	
	if period < MA1.DATA[period] then
    return;
    end
	
	RAW[period] = math.abs(Indicator.DATA[period] - MA1.DATA[period]);
	
	MA2:update(mode);
	
	if period < MA2.DATA[period] then
    return;
    end	
	
	Top [period]=  50+(c1*  MA2.DATA[period]);
	Bottom [period]=  50-(c1*  MA2.DATA[period]);
	end
	
	

   
   RSI[period] = Indicator.DATA[period];
   
end

