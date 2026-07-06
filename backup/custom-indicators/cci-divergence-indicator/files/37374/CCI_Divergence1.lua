-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21362
-- Id: 7082

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("CCI Divergence Trend");
    indicator:description("Shows CCI Divergence trends");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("CCI_Period", "Period of CCI", "", 14);
	
	
	indicator.parameters:addGroup("Filter");
	
	indicator.parameters:addString("Downx", "Down Trend line filter", "", "Both");
    indicator.parameters:addStringAlternative("Downx", "Both", "", "Both");
    indicator.parameters:addStringAlternative("Downx", "Up Only", "", "Up");
	indicator.parameters:addStringAlternative("Downx", "Down Only", "", "Down");
	
	
	indicator.parameters:addString("Upx", "Up Trend line filter", "", "Both");
    indicator.parameters:addStringAlternative("Upx", "Both", "", "Both");
    indicator.parameters:addStringAlternative("Upx", "Up Only", "", "Up");
	indicator.parameters:addStringAlternative("Upx", "Down Only", "", "Down");
	

	
	indicator.parameters:addGroup("Style");
	
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));	

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;

-- Streams block
local lineid = nil;
local dummy;
local style, width;
local Down, Up;
-- Routine
function Prepare(nameOnly)
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
	Down= instance.parameters.Downx;
	Up= instance.parameters.Upx;
	
	style= instance.parameters.style;
	width= instance.parameters.width;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("CCI_DIVERGENCE") ~= nil, "CCI_DIVERGENCE" .. " indicator must be installed");
    CCI = core.indicators:create("CCI_DIVERGENCE", source, instance.parameters.CCI_Period, false);
    first = CCI.DATA:first();
    dummy = instance:addStream("D", core.Line, name .. ".D", "D", UP_color, 0);
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)


 
	
    local l;
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
	
	   period = period - 1;
    pperiod1 = source:serial(period)
    

    CCI:update(mode);

    if CCI:getStream(1):hasData(period - 2) 	
	then
        l = math.abs(CCI:getStream(1)[period - 2]);
        local prev = period - 2 - l;
		
		if  ((source.high[prev] < source.high[period - 2] )and Up =="Up"  )
		or ((source.high[prev] > source.high[period - 2] )and Up =="Down"  )
		or Up == "Both"
		then
		line_id = line_id + 1;
        core.host:execute("drawLine", line_id, source:date(prev), source.high[prev], source:date(period - 2), source.high[period - 2], UP_color, style, width);
		end
    end
    if CCI:getStream(2):hasData(period - 2) 
	then
        l = math.abs(CCI:getStream(2)[period - 2]);
        local prev = period - 2 - l;
		
		if  ((source.low[prev]< source.low[period - 2] )and Down =="Up"  )
		or ((source.low[prev] > source.low[period - 2] )and Down =="Down"  )
		or Down == "Both"
		then
        line_id = line_id + 1;
        core.host:execute("drawLine", line_id, source:date(prev), source.low[prev], source:date(period - 2), source.low[period - 2], DN_color, style, width);
		end
    end
end

