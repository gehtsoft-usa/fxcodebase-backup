
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65023

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


function Init()
    indicator:name("Guppy's Multiple Moving Average Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	local i;
	indicator.parameters:addGroup("Style ");
 
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
 
end

local source = nil;
local EMAs = {};    -- an array of outputs
local Line;

function CreateEMA(index )
 
    -- create the line
    EMAs[index] = instance:addInternalStream(0, 0);
				
end

function Prepare(nameOnly)
    source = instance.source;
    local name;

    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    CreateEMA(0);
    CreateEMA(1);
    CreateEMA(2);
    CreateEMA(3);
    CreateEMA(4);
    CreateEMA(5);

    CreateEMA(6);
    CreateEMA(7);
    CreateEMA(8);
    CreateEMA(9);
    CreateEMA(10);
    CreateEMA(11);
	
	  Line = instance:addStream("Line", core.Line, name .. "Line", "Line", instance.parameters.color, source:first());				
	  Line:setWidth(instance.parameters.width);
	  Line:setStyle(instance.parameters.style);
end

function CalcEMA(index, N, period)
    local first;

    first = source:first() + N - 1;
    if period < first then
       return ;
    elseif period == first then
       -- range: period - N + 1, period - N + 2, ..., period
       local range = core.rangeTo(period, N);
       EMAs[index][period] = core.avg(source, range);
    else
       local k;
       k = 2.0 / (N + 1.0);
       -- EMA - PRICE * K - PREV EMA * (1 - K)
       EMAs[index][period] = source[period] * k + EMAs[index][period - 1] * (1 - k);
    end
end

function Update(period)
    CalcEMA(0, 3, period);
    CalcEMA(1, 5, period);
    CalcEMA(2, 8, period);
    CalcEMA(3, 10, period);
    CalcEMA(4, 12, period);
    CalcEMA(5, 15, period);

    CalcEMA(6, 30, period);
    CalcEMA(7, 35, period);
    CalcEMA(8, 40, period);
    CalcEMA(9, 45, period);
    CalcEMA(10, 50, period);
    CalcEMA(11, 60, period);
	
	
	local Sum=0;
	
	for i= 0, 11 , 1 do	
	Sum=Sum+EMAs[i][period];
	end
	
	Line[period]=Sum/12;
	
	
end


