-- Id: 18856

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65006

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Average Daily Range");
    indicator:description("Average Daily Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	   
	
	indicator.parameters:addGroup("ADR Calculation");
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N", "ADR Periods", "", 14);	
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.5);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local ADR=nil;
local Source, loading;
local N;
local TF;
local first;
 
local size;
local Multiplier;
function Prepare(nameOnly)  
    N=instance.parameters.N;	
	Multiplier=instance.parameters.Multiplier;
	TF=instance.parameters.TF;
    local name =  profile:id() .. ","  .. instance.source:name() ;
    instance:name(name);
    if nameOnly then
        return;
    end
	
    source = instance.source;
	first = source:first() + N;
   
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), N, 100, 101);
    ADR = instance:addStream("ADR", core.Line, name .. ".ADR", "ADR", instance.parameters.color, first);
    ADR:setWidth(instance.parameters.width);
    ADR:setStyle(instance.parameters.style);
	loading = true;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

function Update(period, mode)
    if period < first or loading or Source:size() < N then
    	return;
    end	
	
	local adr = Calculate();
    ADR[period] = adr / Source:pipSize() * Multiplier;
end

function Calculate()
	local Sum = 0;
 	for i = 0, N - 1, 1 do
 		Sum = Sum + (Source.high[NOW - i] - Source.low[NOW - i]) 
 	end  
 	return (Sum /N)
end