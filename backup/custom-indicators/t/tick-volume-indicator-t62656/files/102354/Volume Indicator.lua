-- Id: 14821

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62656

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
    indicator:name("Volume Indicator");
    indicator:description("Volume Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 2);
    indicator.parameters:addInteger("MAPeriod", "MA Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Volume", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Volume", core.rgb(255, 0, 0));
	
	 indicator.parameters:addColor("xUp", "Color of N Consecutive Up", "Color of Volume", core.rgb(0, 200, 0));
	indicator.parameters:addColor("xDown", "Color of N Consecutive Down", "Color of Volume", core.rgb(200, 0, 0));
	
	indicator.parameters:addColor("MA_color", "MA Line Color","Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Volume = nil;
local MA,ma;
local Count;
local Up,Down,xUp,xDown;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	MAPeriod = instance.parameters.MAPeriod;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	xUp = instance.parameters.xUp;
	xDown = instance.parameters.xDown;
    source = instance.source;
	ma = core.indicators:create("MVA", source.volume, MAPeriod);
    first = ma.DATA:first();
	
	Count = instance:addInternalStream(0, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(MAPeriod) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", Up, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
		MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.MA_color, first);
		MA:setWidth(instance.parameters.width);
        MA:setStyle(instance.parameters.style);
		
		MA:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ma:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	if source.volume[period]>source.volume[period-1] then
	   
	    if Count[period-1]>0 then
		 Count[period]=Count[period-1]+1;
		 else
		 Count[period]=1;
		 end
	
	elseif source.volume[period]<source.volume[period-1] then
	     if Count[period-1]<0 then
		 Count[period]=Count[period-1]-1;
		 else
		 Count[period]=-1;
		 end
	else
	     if Count[period-1]>0 then
		 Count[period]=Count[period-1]+1;
		 else
		 Count[period]=Count[period-1]-1;
		 end
	end
	
	    MA[period]=ma.DATA[period];
        Volume[period] = source.volume[period];
		
		if source.close[period]>  source.open[period] then
			if Count[period]>= Period then
			Volume:setColor(period, xUp);
			else
			Volume:setColor(period, Up);
			end
		elseif source.close[period]<  source.open[period] then
		    if Count[period]<= -Period then
			Volume:setColor(period, xDown);
			else
			Volume:setColor(period, Down);
			end
		end
    
end

