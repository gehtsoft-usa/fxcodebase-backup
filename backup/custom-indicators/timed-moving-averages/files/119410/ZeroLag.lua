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
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("ZeroLag indicator");
    indicator:description("ZeroLag indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local ZeroLag = nil;
local EMA = nil;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. ")";
    instance:name(name);
    
    EMA=core.indicators:create("EMA", source, Period);  	
    ZeroLag = instance:addStream("ZeroLag", core.Line, name .. ".ZeroLag", "ZeroLag", instance.parameters.clr, first);
    ZeroLag:setWidth(instance.parameters.widthLinReg);
    ZeroLag:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
    EMA:update(mode);   

    if period>first+Period then       
        local K = 2 /(Period + 1);
        local x = math.floor((Period - 1)/2);    
        ZeroLag[period] = K*(2*source[period]-source[period - x])+(1-K)*EMA.DATA[period-1];   
    end 
end

