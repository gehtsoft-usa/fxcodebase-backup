-- Id: 555

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=895


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
    indicator:name("Detrended Price Oscillator (DPO)");
    indicator:description("Detrended Price Oscillator (DPO)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "Period", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDPO", "Color of DPO", "Color of DPO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local MA;
local N;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    source = instance.source;
    N=instance.parameters.N;
    MA = core.indicators:create("MVA", source, N);
    first = MA.DATA:first();
     
    DPO = instance:addStream("DPO", core.Line, name .. ".DPO", "DPO", instance.parameters.clrDPO, first);
	DPO:setWidth(instance.parameters.width);
    DPO:setStyle(instance.parameters.style);
	
	DPO:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA:update(mode);
    if (period>first) then
     DPO[period]=source[period]-MA.DATA[period];
    end 
end

