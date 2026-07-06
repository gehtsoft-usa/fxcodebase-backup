-- Id: 1998
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2431

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
    indicator:name("MA Slope Oscilator");
    indicator:description("MA Slope Oscilator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("First MA Slope Parameters ");
		indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("First_Period", " First MA Period", "", 25);
    indicator.parameters:addString("First_Method", "Method of First MA", "", "EMA");
    indicator.parameters:addStringAlternative("First_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("First_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("First_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("First_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("First_Method", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("First_Method", "HMA", "", "HMA");
    indicator.parameters:addDouble("First_Slope", "Slope", "pip/minute", 0);
    indicator.parameters:addInteger("First_Bars", "Bars", "", 1);

	
	
	indicator.parameters:addGroup("Second MA Slope Parameters ");
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
     indicator.parameters:addInteger("Second_Period", " Second MA Period", "", 50);
    indicator.parameters:addString("Second_Method", "Method of Second MA", "", "EMA");
    indicator.parameters:addStringAlternative("Second_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Second_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Second_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Second_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Second_Method", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("Second_Method", "HMA", "", "HMA");
    indicator.parameters:addDouble("Second_Slope", "Slope", "pip/minute", 0);
    indicator.parameters:addInteger("Second_Bars", "Bars", "", 1);
   
   indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Contradictory_color", "Color of Contradictory", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Flat_color", "Color of Flat", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local First_Period,First_Method,First_Slope,First_Bars, Second_Period,Second_Method,Second_Slope,Second_Bars;

local first;
local source = nil;
local Price1, Price2;
-- Streams block
local MASO;

local indicator1;
local indicator2;

-- Routine
function Prepare(nameOnly)
    First_Period = instance.parameters.First_Period;
    First_Method = instance.parameters.First_Method;
    First_Slope = instance.parameters.First_Slope;
    First_Bars = instance.parameters.First_Bars;
	
	Second_Period = instance.parameters.Second_Period;
    Second_Method = instance.parameters.Second_Method;
    Second_Slope = instance.parameters.Second_Slope;
    Second_Bars = instance.parameters.Second_Bars;
	
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	
	assert(core.indicators:findIndicator("MA_SLOPE") ~= nil, "Please, download and install MA_SLOPE");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. First_Period .. ", "..First_Method.. ", "..First_Slope.. ", "..First_Bars.. ", ".. Second_Period ..", ".. Second_Method .. ", "..  Second_Slope..", " .. Second_Bars.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	
	indicator1=core.indicators:create("MA_SLOPE", source[Price1], First_Period,First_Method , First_Slope, First_Bars, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
	indicator2=core.indicators:create("MA_SLOPE", source[Price2], Second_Period,Second_Method , Second_Slope, Second_Bars, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
	
	 first = math.max(indicator1.DATA:first(), indicator2.DATA:first());
	
    MASO = instance:addStream("MASO", core.Bar, name .. ".MASO", "MASO", instance.parameters.Up_color, first); 
	MASO:addLevel(0);
	
	MASO:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


      
        MASO[period]= 100;
        MASO:setColor(period, instance.parameters.Flat_color);
       if period < first   then
	   return;
	   end
	
	   indicator1:update(mode);
	   indicator2:update(mode);
	   
				
							if   indicator1.DATA:colorI(period) ==  core.rgb(0, 255, 0)
                            and   indicator2.DATA:colorI(period) ==  core.rgb(0, 255, 0)	
							then	 
							 MASO:setColor(period, instance.parameters.Up_color);
							elseif   indicator1.DATA:colorI(period) ==  core.rgb(255, 0, 0)
                            and   indicator2.DATA:colorI(period) ==  core.rgb(255, 0, 0)
							then 
							 MASO:setColor(period, instance.parameters.Down_color);
							else 
							 MASO:setColor(period, instance.parameters.Contradictory_color);
						
							end
	
end

