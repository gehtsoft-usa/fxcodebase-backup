
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62415


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
    indicator:name("Price Based ZigZag");
    indicator:description("Price Based ZigZag");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("PBZZ_color_Up", "Color of PBZZ Up", "Color of PBZZ Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PBZZ_color_Down", "Color of PBZZ Down", "Color of PBZZ Down", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local PBZZ = nil;
local Up,Down,Trend;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	Trend = instance:addInternalStream(0, 0);

    
        PBZZ = instance:addStream("PBZZ", core.Line, name, "PBZZ", instance.parameters.PBZZ_color_Up, first);
		PBZZ:setWidth(instance.parameters.width);
        PBZZ:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	period=period-1;
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	if period== first then
		if source.close[period]> source.open[period] then
		Trend[period]=1;
		Down[period]=source.low[period];		
		else
		Trend[period]=-1;
		Down[period]=source.high[period];
		end
	else
    Trend[period]=Trend[period-1];	
	Up[period]=Up[period-1];
	Down[period]=Down[period-1];
	end
	
	
	if Trend[period]== -1 and source.close[period] > source.high[period-1] then
	Trend[period]=1;
	Up[period]=period-1;
	elseif Trend[period]== 1 and source.close[period] < source.low[period-1] then
	Trend[period]=-1;
	Down[period]=period-1;
	end
	
	if Trend[period]== 1 then
	core.drawLine(PBZZ, core.range(Up[period], period), source.low[Up[period]], Up[period], source.high[period], period, instance.parameters.PBZZ_color_Up);
	elseif Trend[period]==-1 then
	core.drawLine(PBZZ, core.range(Down[period], period), source.high[Down[period]], Down[period], source.low[period], period, instance.parameters.PBZZ_color_Down);
	end
	
     
end

