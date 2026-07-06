-- Id: 12770
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61361

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
    indicator:name("B-Line");
    indicator:description("B-Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length1", "Length1", "Length1", 35);
    indicator.parameters:addInteger("Length2", "Length2", "Length2", 10);
    indicator.parameters:addInteger("Length3", "Length3", "Length3", 2);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
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
local Length1;
local Length2;
local Length3;

local first1, first2, first3;
local source = nil;

-- Streams block
local K = nil;
local k;
local D = nil;

-- Routine
function Prepare(nameOnly)
    Length1 = instance.parameters.Length1;
    Length2 = instance.parameters.Length2;
    Length3 = instance.parameters.Length3;
    source = instance.source;
    first1 = source:first()+Length1;
    first2 = first1+Length2;
	first3 = first2+Length3;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length1) .. ", " .. tostring(Length2) .. ", " .. tostring(Length3) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	    k = instance:addInternalStream(0, 0);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, first2);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
		K:setWidth(instance.parameters.width1);
        K:setStyle(instance.parameters.style1);
		K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		
        D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, first3);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
		D:setWidth(instance.parameters.width2);
        D:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first1 or not source:hasData(period) then
	return;
	end
	
	LL, HH = mathex.minmax(source.median, period-Length1+1, period);
	    if HH-LL == 0 then
		k[period] =0;
		else
        k[period] = 100 *(((source.high[period]+source.low[period])/2) - LL)/(HH- LL);
		end
		
		if period < first2  then
		return;
		end
		
		K[period] = mathex.avg(k, period-Length2+1, period);
		
		
		if period < first3  then
		return;
		end
		
        D[period] = mathex.avg(K, period-Length3+1, period);
   
end

 
