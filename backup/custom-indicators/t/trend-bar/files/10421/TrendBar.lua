-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4150

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
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("TrendBar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Zone Trade");
	
    indicator.parameters:addGroup("SAR Calculation");
	indicator.parameters:addDouble("Step", "Step","", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);
	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addDouble("DMI_Period", "Period","", 14, 1, 1000);	
	 
	 indicator.parameters:addGroup("Bar Color");
	 indicator.parameters:addColor("UP", "Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DOWN", "Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("NEUTRAL", "No Trend ", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Step;
local Max;
local SAR
local DMI_Period;

local DMI;

local first;
local source = nil;

-- Streams block
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local UP;
local DOWN;
local NEUTRAL;

-- Routine
function Prepare(nameOnly)
    Step = instance.parameters.Step;
    Max = instance.parameters.Max;
    DMI_Period= instance.parameters.DMI_Period;
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	NEUTRAL = instance.parameters.NEUTRAL;
	
	
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", "  .. Step .. ", " .. Max .. ", " .. DMI_Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    SAR = core.indicators:create("SAR", source, Step, Max);
    DMI = core.indicators:create("DMI", source, DMI_Period);
	
	first =math.max(SAR.DN:first(), SAR.UP:first(), DMI.DATA:first());	

	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	 
     
	if period < first  or not source:hasData(period) then
	open:setColor(period, UP);
    return;
    end 
 
    SAR:update(mode);
    DMI:update(mode);
		
				if DMI.DIP[period]  > DMI.DIM[period] and SAR.DN[period] < source.close[period]  and SAR.UP[period] ==0 then 
				open:setColor(period, UP);
				elseif  DMI.DIP[period] < DMI.DIM[period] and SAR.UP[period] > source.close[period]  and SAR.DN[period] ==0 then
				open:setColor(period, DOWN);	
				else
				open:setColor(period, NEUTRAL);
				end		
				  
end

