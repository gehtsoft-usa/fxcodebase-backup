-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64601
-- Id: 17998

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("STOP LOSS TAKE PROFIT Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");		
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addDouble("MultiplierL", "Limit ATR Multiplier", "Multiplier", 2);
    indicator.parameters:addDouble("MultiplierS", "Stop ATR Multiplier", "Multiplier", 2); 
   

    indicator.parameters:addGroup("Stop Line Style");
    indicator.parameters:addColor("colorS", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthS", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleS", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("Take Profit Line Style");
    indicator.parameters:addColor("colorL", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthL", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleL", core.FLAG_LINE_STYLE);
 
	
end
local bid,ask;
local first;
local source = nil;

local Stop,Limit;
local MultiplierS,MultiplierL, Period;
local ATR;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    MultiplierS=instance.parameters.MultiplierS; 
	MultiplierL=instance.parameters.MultiplierL; 
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.MultiplierL.. ", " .. instance.parameters.MultiplierS.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    if source:isBid() then
        bid = source;
        ask = core.host:execute("getAskPrice");
    else
        ask = source;
        bid = core.host:execute("getBidPrice");
    end
    
    ATR = core.indicators:create("ATR", source, Period);

    first = ATR.DATA:first();
    Stop = instance:addStream("Stop", core.Line, name .. ".Stop", "Stop", instance.parameters.colorS, first);   
    Stop:setPrecision(math.max(2, instance.source:getPrecision()));
    Stop:setWidth(instance.parameters.widthS);
    Stop:setStyle(instance.parameters.styleS);
	
	Limit = instance:addStream("Limit", core.Line, name .. ".Limit", "Limit", instance.parameters.colorL, first);   
    Limit:setPrecision(math.max(2, instance.source:getPrecision()));
    Limit:setWidth(instance.parameters.widthL);
    Limit:setStyle(instance.parameters.styleL);
    
 
end

function Update(period, mode)
   
    ATR:update(mode);
    
	if (period<first) then
	return;
	end
	--TP PIPS;(ATR PIPS*TAKE PROFIT ATR MULTIPLIER)-SPREAD(IN GREEN COLOR)
    --SL PIPS:(ATR PIPS*STOP LOSS ATR MULTIPLIER)+SPREAD(IN RED COLOR)
    
	local Spread=(ask.open[period]-bid.open[period])/source:pipSize();
	Stop[period]=((ATR.DATA[period]/source:pipSize()) *MultiplierS) 	+Spread;
	Limit[period]=((ATR.DATA[period]/source:pipSize()) *MultiplierL) 	-Spread;
   
end

