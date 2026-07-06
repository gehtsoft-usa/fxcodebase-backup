-- Id: 5005

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8114

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
    indicator:name("Trend Id without Log" );
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MVAP", "MVA Period", "", 200);
    indicator.parameters:addInteger("STDEVP", "Standard Deviation Period ", " ", 20);
	 indicator.parameters:addInteger("AVGP", "Difference  Smoothing Period ", " ", 20);
	indicator.parameters:addDouble("Multiplier", "Standard Deviation Multiplier ", " ", 2);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("One_color", "Color of Deviation Line ", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Two_color", "Color of Percent Difference", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MVAP;
local STDEVP;

local first;
local source = nil;

-- Streams block
local One = nil;
local Two = nil;
local AVGP;
local Raw ;
local MVA;
local Multiplier;
local Average;
local Three;
-- Routine
function Prepare(nameOnly)
    AVGP= instance.parameters.AVGP;
    MVAP = instance.parameters.MVAP;
    STDEVP = instance.parameters.STDEVP;
	Multiplier= instance.parameters.Multiplier;
    source = instance.source;
   
   	Raw = instance:addInternalStream(0, 0);
	MVA=core.indicators:create("MVA", source, MVAP );
	Average =core.indicators:create("MVA", Raw, AVGP );
	
	 first = Average.DATA:first() +  STDEVP;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. MVAP .. ", " .. STDEVP .. ", " .. AVGP .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    One = instance:addStream("Deviation", core.Line, name .. ".Deviation", "Deviation", instance.parameters.One_color, first);
	One:setWidth(instance.parameters.width1);
    One:setStyle(instance.parameters.style1);
		
    Two = instance:addStream("Positiv", core.Line, name .. ".Difference Positiv", "Difference", instance.parameters.Two_color, first);
	Two:setWidth(instance.parameters.width2);
    Two:setStyle(instance.parameters.style2);
		
	
	Three = instance:addStream("Negativ", core.Line, name .. ".Difference Negativ", "Difference", instance.parameters.Two_color, first);
	Three:setWidth(instance.parameters.width2);
    Three:setStyle(instance.parameters.style2);
	
	One:setPrecision(math.max(2, instance.source:getPrecision()));
	Two:setPrecision(math.max(2, instance.source:getPrecision()));
	Three:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	 MVA:update(mode);
	 Average:update(mode);
	 
	if period < first or not source:hasData(period) then
    return;
	end
	 
	Raw [period] = ( source[period] - MVA.DATA[period]) / (MVA.DATA[period] /100 );
	 
	  local d = mathex.stdev(Average.DATA, period - STDEVP + 1, period);

    	Two[period] = d*Multiplier;
        One[period] = Average.DATA [period];
        Three[period] =  -d*Multiplier;
end

