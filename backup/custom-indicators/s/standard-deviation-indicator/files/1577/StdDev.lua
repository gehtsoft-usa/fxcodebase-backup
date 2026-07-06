-- Id: 520
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=870

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
    indicator:name("Standard Deviation Indicator");
    indicator:description("Technical indicator named Standard Deviation (StdDev) measures the market volatility.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Period", 20);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrStdDev", "Color of StdDev", "Color of StdDev", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA;
local N;

function Prepare(nameOnly)
    source = instance.source;
    N=instance.parameters.N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    MA = core.indicators:create("MVA", source, N);
    first = MA.DATA:first()+N;	
	
    StdDev = instance:addStream("StdDev", core.Line, name .. ".StdDev", "StdDev", instance.parameters.clrStdDev, first);
	StdDev:setWidth(instance.parameters.width);
    StdDev:setStyle(instance.parameters.style);
	
	StdDev:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA:update(mode);
    if (period<first) then
	return;
	end
	
	
     local dAmount=0.;
     local dMovingAverage=MA.DATA[period];
     local i;
     for i=0,N,1 do
      dAmount=dAmount+math.pow((source[period-i]-dMovingAverage),2);
     end
     StdDev[period]=math.sqrt(dAmount/N);
    
end

