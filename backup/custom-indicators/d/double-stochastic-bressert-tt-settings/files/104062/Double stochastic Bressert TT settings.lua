-- Id: 15221
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62993

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
    indicator:name("Double stochastic Bressert TT settings");
    indicator:description("Double stochastic Bressert TT settings");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("StochasticLength", "Stochastic Length", "Stochastic Length", 55);
    indicator.parameters:addInteger("SmoothEmaLength", "SmoothEmaLength", "SmoothEmaLength", 13);
    indicator.parameters:addInteger("RatioLong", "RatioLong", "RatioLong", 5);
    indicator.parameters:addInteger("RatioShort", "RatioShort", "RatioShort", 3);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DDS_Up", "Color of DDS Up", "Color of DDS", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DDS_Down", "Color of DDS Down", "Color of DDS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 75);
    indicator.parameters:addDouble("oversold","Oversold Level","", 25);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local StochasticLength;
local SmoothEmaLength;
local RatioLong;
local RatioShort;

local first;
local source = nil;

-- Streams block
local DDS = nil;
local alpha;

local EMA1,EMA2;
local work={};
 
-- Routine
function Prepare(nameOnly)
    StochasticLength = instance.parameters.StochasticLength;
    SmoothEmaLength = instance.parameters.SmoothEmaLength;
    RatioLong = instance.parameters.RatioLong;
    RatioShort = instance.parameters.RatioShort;
    source = instance.source;
    
	
	alpha = 2.0 / (1.0+SmoothEmaLength);
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(StochasticLength) .. ", " .. tostring(SmoothEmaLength) .. ", " .. tostring(RatioLong) .. ", " .. tostring(RatioShort) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		work[0] = instance:addInternalStream(0, 0);
		work[1] = instance:addInternalStream(0, 0);
		work[2] = instance:addInternalStream(0, 0); 
		EMA1 = core.indicators:create("EMA", source, RatioShort);
		EMA2 = core.indicators:create("EMA", source, RatioLong);
		
		first = math.max(EMA1.DATA:first(),EMA2.DATA:first());
	
        DDS = instance:addStream("DDS", core.Line, name, "DDS", instance.parameters.DDS_Up, first+2*SmoothEmaLength);
		DDS:setWidth(instance.parameters.width);
        DDS:setStyle(instance.parameters.style);
		DDS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		DDS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 

        DDS:setPrecision(math.max(2, instance.source:getPrecision()));		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
  
	
	EMA1:update(mode);
	EMA2:update(mode);
	
	if period < first or not source:hasData(period) then
	return;
	end
	 work[2][period] = EMA1.DATA[period]-EMA2.DATA[period];
	
	
	if period < first + StochasticLength then
	return;
	end
	
	min,max=mathex.minmax(work[2], period-StochasticLength+1, period);
	

	if (min~=max) then
	work[0][period] = 100*(work[2][period]-min)/(max-min);
	else
	work[0][period] = 0;
	end
	
    work [1][period] = work[1][period-1]+alpha*(work[0][period]-work[1][period-1]);
	
	if period < first + StochasticLength*2 then
	return;
	end
	
	min,max=mathex.minmax(work[1], period-StochasticLength+1, period);
	local stochastic;
	  if (min~=max) then
	  stochastic = 100*(work [1][period]-min)/(max-min);
	  else
	  stochastic=0; 
	  end
	
	 DDS[period]   = DDS[period-1]+alpha*(stochastic-DDS[period-1]);
 
    if DDS[period] > DDS[period-1] then
	DDS:setColor(period, instance.parameters.DDS_Up);
	else
	DDS:setColor(period, instance.parameters.DDS_Down);
	end
end

 