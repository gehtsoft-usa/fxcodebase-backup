-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65661
-- Id:

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------+
--|                                 Patreon : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Any Time Frame VWAP");
    indicator:description("Any Time Frame VWAP");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("color", "Color of Daily Line", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

  
end

 
local WP,TF;
local source,first;

function Prepare(nameOnly)
    source = instance.source;
	first=source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	TF= instance.parameters.TF;

    WP = instance:addInternalStream(0, 0);
    
        VWAP = instance:addStream("VWAP", core.Line, name, "VWAP", instance.parameters.color, 0);
        VWAP:setWidth(instance.parameters.width);
        VWAP:setStyle(instance.parameters.style);
    
end

function Calculate(period,Index1 )
 
   
    local index = period;
    local Sum1 = 0;
    local Sum2 = 0;
  
    for index=Index1,period, 1 do
        Sum1 = Sum1 + WP[index];
        Sum2 = Sum2 + source.volume[index];
    end
    if Sum2 ~= 0 then
        return Sum1 / Sum2;
    else
        return 0;
    end
end
 
function Update(period)

    
    WP[period] = source.volume[period] * (source.high[period] + source.low[period] + source.close[period]) / 3;
	
	local L1 = core.getcandle(TF, source:date(period), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
	
	Index1=core.findDate (source, L1, false);
	
	if Index1 == -1 then
	return;
	end
	
    
	 
		VWAP[period] = Calculate(period,Index1 );
 
   
end 
