-- Id: 1357
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1908

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
    indicator:name("Squelch Trend");
    indicator:description("Squelch Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("Level", "Squelch Triger Level", "Squelch Triger Level", 20);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Coloe", "Color of Up", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Coloe", "Color of Down", core.COLOR_DOWNCANDLE );
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Level;

local first;
local source = nil;

local  openup=nil;
local  closeup=nil;
local  highup=nil;
local  lowup=nil;

-- Streams block
local Squelch = nil;
local Option=nil;
local Up, Down;
-- Routine
function Prepare(nameOnly)
    Level = instance.parameters.Level;
	source = instance.source;
    first = source:first()+40;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Level .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    assert(core.indicators:findIndicator("JES") ~= nil, "JES" .. " indicator must be installed");
	Squelch = core.indicators:create("JES", source, Level);
    
	openup = instance:addStream("openup", core.Line, name, "openup", core.rgb(0, 0, 0), first);
    highup = instance:addStream("highup", core.Line, name, "highup", core.rgb(0, 0, 0), first);
    lowup = instance:addStream("lowup", core.Line, name, "lowup", core.rgb(0, 0, 0), first);
    closeup = instance:addStream("closeup", core.Line, name, "closeup", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("UP", "UP", openup, highup, lowup, closeup);
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
	
	Squelch:update(mode);
	
	    openup[period]=source.open[period];
		closeup[period]= source.close[period];
		highup[period]=source.high[period];
		lowup[period]=source.low[period];	
	
	 if period <= first or not source:hasData(period) then
	 return;
	 end
	
		if Squelch.S1[period] > Level then 	
		openup:setColor(period, Up);
		else
        openup:setColor(period, Down);
		end        
   
end

