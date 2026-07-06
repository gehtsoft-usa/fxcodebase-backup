
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63125

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Timed Moving Averages");
    indicator:description("Timed Moving Averages");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Duration", "MA Duration in seconds", "MA Duration in seconds", 60);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local Duration;
local MA;
local BarSize;
local PeriodOf;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Duration = instance.parameters.Duration; 
    source = instance.source;
	
	assert(source:barSize() ~= "t1", "The time frame must not be tick");
 
	local s1, e1;	
	 s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
	 
    BarSize= math.floor((e1 - s1)*86400+0.5); 
	
		PeriodOf =Duration/BarSize;
		
		core.host:execute ("setStatus", "MA :" .. win32.formatNumber(PeriodOf, false, 2)  );
		 
		if   Duration <BarSize then
		 error( "The chosen MA Duration must be equal to or bigger than "..BarSize  );
		end
		
 
	 
	  
	
    first=source:first();
 
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.Color, source:first());
		MA:setWidth(instance.parameters.Width);
        MA:setStyle(instance.parameters.Style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	
		local P1= core.findDate (source, source:date(period-PeriodOf+1), false);
	
	if P1==-1
	or P1< source:first()+1 
	or P1>= period
    then
    return;
    end 
	
		
        MA[period]= mathex.avg(source,P1, period);
     
	 
end
 