-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60566
-- Id: 11573

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Range Indicator");
    indicator:description("Range Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("r", "Range Period", "Range Period", 5);
    indicator.parameters:addInteger("m", "Smoothing Period", "Smoothing Period", 3);
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RI_color", "Color of RI", "Color of RI", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
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
local r;
local m;

local first;
local source = nil;

-- Streams block
local RI = nil;
	local G,J;
	local EMA;
-- Routine
function Prepare(nameOnly)
    r = instance.parameters.r;
    m = instance.parameters.m;
    source = instance.source;
    first = source:first()+r;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(r) .. ", " .. tostring(m) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        G = instance:addInternalStream(0, 0);
        J = instance:addInternalStream(0, 0);
        EMA = core.indicators:create("EMA", J, m);
        RI = instance:addStream("RI", core.Line, name, "RI", instance.parameters.RI_color,  EMA.DATA:first());
    RI:setPrecision(math.max(2, instance.source:getPrecision()));
		RI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		RI:setWidth(instance.parameters.width);
		RI:setStyle(instance.parameters.style);
	
    end
end


function getTrueRange(period)
    local hl = math.abs(source.high[period] - source.low[period]);
    local hc =  math.abs(source.high[period] - source.close[period - 1]);
    local lc =  math.abs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end



function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local F = getTrueRange(period);


	if source.close[period]> source.close[period-1] then
	G[period]= F/source.close[period];
	else
	G[period]=F;
	end
	
	local H,I= mathex.minmax(G, period-r+1, period);
	
	 
	if (I-H) > 0 then
	J[period]= ((G[period]-H)/(I-H))*100;
	else
	J[period]= (G[period]-H)*100;
	end
	
	EMA:update(mode);
	
	if period < EMA.DATA:first() then
	return;
	end
	
	
        RI[period] = EMA.DATA[period];
    
end

