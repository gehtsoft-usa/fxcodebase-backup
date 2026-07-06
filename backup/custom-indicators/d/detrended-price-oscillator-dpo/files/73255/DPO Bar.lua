-- Id: 9493

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
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Candle", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Dn", "Color of Down Color", "", core.COLOR_DOWNCANDLE )
end

local first;
local source = nil;
local MAo, MAc, MAh, MAl;
local N;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Method;


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    N=instance.parameters.N;
	Method=instance.parameters.Method;
    MAo = core.indicators:create(Method, source.open, N);
	MAc = core.indicators:create(Method, source.close, N);
	MAh = core.indicators:create(Method, source.high, N);
	MAl = core.indicators:create(Method, source.low, N);
    first = MAo.DATA:first();
     
    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
	
	open:setPrecision(math.max(2, instance.source:getPrecision()));	
	high:setPrecision(math.max(2, instance.source:getPrecision()));
    low:setPrecision(math.max(2, instance.source:getPrecision()));	
	close:setPrecision(math.max(2, instance.source:getPrecision()));
	 
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);    
end

function Update(period, mode)

    MAo:update(mode);
	MAc:update(mode);
	MAh:update(mode);
	MAl:update(mode);
	
    if (period <first) then
	return;
	end
	
	open[period] =  source.open[period] - MAo.DATA[period];
	close[period] = source.close[period] -MAc.DATA[period];
	high[period] = math.max(open[period],close[period], source.high[period] -MAh.DATA[period], source.low[period] -MAl.DATA[period] );
	low[period] = math.min(open[period] ,close[period], source.high[period] -MAh.DATA[period], source.low[period] -MAl.DATA[period]);
    
    
end

