-- Id: 21472
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66154

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
    indicator:name("Heiken Ashi Smoothed Oscillator");
    indicator:description("Heiken Ashi Smoothed Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Pre smoothing average period", "", 7);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2", "Post smoothing average period", "", 7);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("Period3", "Signal smoothing average period", "", 7);
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
 

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color2", "Signal Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
end

 
local source = nil;
local Period1;
local Method1;
local Period2;
local Method2;
local Period3;
local Method3;
local open,close,high,low;
local HA_open,HA_close;
local open_MA,close_MA,high_MA,low_MA;
local Raw,HA;
local Post;
local signal, Signal;

function Prepare(nameOnly)
    source = instance.source;
	
	 Period1=instance.parameters.Period1;
	 Method1=instance.parameters.Method1;
	 Period2=instance.parameters.Period2;
	 Method2=instance.parameters.Method2;
	 Period3=instance.parameters.Period3;
	 Method3=instance.parameters.Method3;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	open_MA = core.indicators:create(Method1, source.open , Period1 );
	close_MA = core.indicators:create(Method1, source.close,  Period1 );
	high_MA = core.indicators:create(Method1, source.high , Period1 );
	low_MA = core.indicators:create(Method1, source.low,  Period1 );

    open = instance:addInternalStream(0, 0);
	close = instance:addInternalStream(0, 0);
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	
	HA_open = instance:addInternalStream(0, 0);
	HA_close = instance:addInternalStream(0, 0);
	--HA_high = instance:addInternalStream(0, 0);
--	HA_low = instance:addInternalStream(0, 0);
	 
	
	Raw = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	Post = core.indicators:create(Method2, Raw,Period2 );
	
	
	
	 
    Line = instance:addStream("Line", core.Line, name .. "Line", "Line", instance.parameters.color1, Post.DATA:first());
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
	Line:setWidth(instance.parameters.width1);
    Line:setStyle(instance.parameters.style1);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	signal = core.indicators:create(Method3, Line,Period3 );
	Signal = instance:addStream("Signal", core.Line, name .. "Signal", "Signal", instance.parameters.color2, signal.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
end

function Update(period, mode)
   
   
    open_MA:update(mode);
	close_MA:update(mode);
	high_MA:update(mode);
	low_MA:update(mode);
	
	if (period<low_MA.DATA:first()) then
    return;
    end
    
	open[period]=open_MA.DATA[period];
	close[period]=close_MA.DATA[period];
	high[period]=high_MA.DATA[period];
	low[period]=low_MA.DATA[period];
	 
	 
	  if (period == low_MA.DATA:first()) then
            HA_open[period] = (open[period - 1] + close[period - 1]) / 2;
        else
            HA_open[period] = (HA_open[period - 1] + HA_close[period - 1]) / 2;
        end
        HA_close[period] = ( open[period] +  high[period] +  low[period] +  close[period]) / 4;
       
	
	Raw[period]=(HA_open[period]-HA_close[period])/2;
	
	Post:update(mode);
	if (period<Post.DATA:first()) then
    return;
    end
	
	Line[period]= Post.DATA[period];
	signal:update(mode);
	
	if period < signal.DATA:first() then
	return;
	end
    
	Signal[period]=signal.DATA[period];
end

