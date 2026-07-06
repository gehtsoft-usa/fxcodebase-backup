-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7806

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Alternate Ichimoku");
    indicator:description("Alternate Ichimoku");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 75);
    indicator.parameters:addInteger("Shift", "Shift", "shift", 75);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("ShowCloud", "Show Cloud Lines", "", false);
    indicator.parameters:addColor("Out_Up", "Color of Cloud Up Line", "", core.rgb(0, 0, 222));
	indicator.parameters:addColor("Out_Down", "Color of Cloud Down Line", "", core.rgb(0, 0, 222));
	
	indicator.parameters:addColor("CloudColor", "Cloud color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("transparency", "Cloud transparency (%)", "", 70, 0, 100);
	   
	 indicator.parameters:addBoolean("ShowMid", "Show Mid Line", "", false);  
	 	indicator.parameters:addColor("Mid", "Mid Line Color", "", core.rgb(128, 128, 128));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Shift;

local first;
local source = nil;

local transparency;

-- Streams block
local Out = {};
local ShowCloud;
local CloudColor;
local Out_Up;
local Out_Down;
local ShowMid;
local Mid;

-- Routine
function Prepare(nameOnly)
    Mid= instance.parameters.Mid;
    ShowMid= instance.parameters.ShowMid;
    Out_Up= instance.parameters.Out_Up;
	Out_Down= instance.parameters.Out_Down;
    CloudColor= instance.parameters.CloudColor;
    transparency= instance.parameters.transparency;
    ShowCloud= instance.parameters.ShowCloud;
    PERIOD = instance.parameters.PERIOD;
    Shift = instance.parameters.Shift;
    source = instance.source;
    first = math.max(source:first()+ PERIOD-1 + Shift,  source:first()+ PERIOD *1.68);

    local name = profile:id() .. "(" .. source:name() .. ", " .. PERIOD .. ", " .. Shift .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
    Out[1] = instance:addStream("Out1", core.Line, name, "Top", Out_Up, first);
	Out[2] = instance:addStream("Out2", core.Line, name, "Bottom", Out_Down, first);	
	Out[3] = instance:addStream("Out3", core.Line, name, "Mid", Mid, first);
	Out[4] = instance:addStream("Out4", core.Line, name, "Mid", Mid, first);
	
	if  ShowCloud then
	Out[1]:setStyle (core.LINE_NONE);
	Out[2]:setStyle (core.LINE_NONE);	
	end
	
	
	if not ShowMid then 
	Out[3]:setStyle (core.LINE_NONE);	
	end
	

	
	instance:createChannelGroup("Cloud", "Cloud", Out[1], Out[2], CloudColor, 100 - transparency);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period  < first or  not source:hasData(period) then
       return;	   
    end
	
	
	local min, max;
	local MIN, MAX;
	local Tsmin,Tsmax;
	
	min, max = mathex.minmax (source, period - PERIOD +1 , period );
	
	MIN, MAX = mathex.minmax (source, math.max( period - PERIOD-1 - Shift, source:first())  , math.min(source:size()-1, period - Shift));
	
	Tsmin,Tsmax = mathex.minmax (source, period - PERIOD *1.68 , period );
	

	Out[1][period]=  (min+max) /2;	
	Out[2][period]=  (MIN+MAX) /2;
	Out[3][period]=  ( Out[1][period] + Out[2][period])/2 ;
	Out[4][period]=  ( Tsmin+Tsmax)/2 ;
	
end

