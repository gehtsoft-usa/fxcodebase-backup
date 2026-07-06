-- Id: 2273
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
function Init()
    indicator:name("Slope Direction Oscillator 20in1");
    indicator:description("Slope Direction Oscillator 20in1");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addInteger("Frame1", "Short Period", " Short Period", 40);
		
	indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addString("Price1", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
	indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
	
	indicator.parameters:addInteger("Frame2", "Long Period", " Long Period", 80);
	
	indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth"); 
        indicator.parameters:addString("Price2", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
	indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
	
    indicator.parameters:addColor("UP_color", "Color of  UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NEUTRAL_color", "Color of NEUTRAL", "Color of NEUTRAL", core.rgb(255, 128, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Price1, Price2,Method1, Method2, Frame1, Frame2 ;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local NEUTRAL = nil;

local SHORT=nil;
local LONG = nil;
local SDLInput2, SDLInput1;
-- Routine
function Prepare()

     assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
     
	Price1=instance.parameters.Price1; 
	Price2=instance.parameters.Price2; 
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2; 
	Frame1=instance.parameters.Frame1;
	Frame2=instance.parameters.Frame2;
	
	
    source = instance.source;
    first = source:first();
		
	
	 if Price2=="close" then
    SDLInput2 = source.close;
    elseif Price2=="open" then
    SDLInput2 = source.open;
    elseif Price2=="high" then
     SDLInput2 = source.high;
    elseif Price2=="low" then
      SDLInput2 = source.low;
	  elseif Price2=="weighted" then
    SDLInput2 = source.weighted;
    elseif Price2=="typical" then
     SDLInput2 = source.typical;
    elseif Price2=="median" then
    SDLInput2 = source.median;  
    end
	
	 if Price1=="close" then
    SDLInput1 = source.close;
    elseif Price1=="open" then
    SDLInput1 = source.open;
    elseif Price1=="high" then
    SDLInput1 = source.high;
    elseif Price1=="low" then
     SDLInput1 = source.low;
	  elseif Price1=="weighted" then
    SDLInput1 = source.weighted;
    elseif Price1=="typical" then
     SDLInput1 = source.typical;
    elseif Price1=="median" then
      SDLInput1 = source.median; 
	 
    end	
    
	LONG= core.indicators:create("AVERAGES", SDLInput1, Method1, Frame1 , false);
	SHORT= core.indicators:create("AVERAGES", SDLInput2,  Method2,  Frame2 , false);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame1 .."," .. Price1 .. ", "..Method1 .. ", ".. Frame2 .."," .. Price2 .. ", "..Method1  .. ")";
    instance:name(name);
    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UP_color, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DOWN = instance:addStream("DOWN", core.Bar, name .. ".DOWN", "DOWN", instance.parameters.DOWN_color, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
    NEUTRAL = instance:addStream("NEUTRAL", core.Bar, name .. ".NEUTRAL", "NEUTRAL", instance.parameters.NEUTRAL_color, first);
    NEUTRAL:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= math.max(Frame1, Frame2) and source:hasData(period) then
	
	LONG:update(mode);
	SHORT:update(mode);
	
	 UP[period] = nil;
     DOWN[period] = nil;
     NEUTRAL[period] = nil;	 
	 
	  if period >= math.max(Frame1, Frame2)+1 then
	 
	
				if LONG.DATA[period-1] < LONG.DATA[period] and SHORT.DATA[period-1] < SHORT.DATA[period]   then 
				UP[period] = 1;
				elseif LONG.DATA[period-1] > LONG.DATA[period] and SHORT.DATA[period-1] > SHORT.DATA[period]   then 
			    DOWN[period] = 1;
				else
				NEUTRAL[period] = 1;
				end
				
		end
		
    end
end

