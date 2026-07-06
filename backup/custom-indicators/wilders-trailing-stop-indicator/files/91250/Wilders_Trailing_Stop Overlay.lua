
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=60028
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
    indicator:name("Wilders_Trailing_Stop Overlay");
    indicator:description("Wilders_Trailing_Stop Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
    indicator.parameters:addDouble("Coeff", "Coeff", "", 3.5);

	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("NEclr", "NE color", "NE color", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Period;
local Coeff;
local ATR;
local WTS=nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

function Prepare(nameOnly)   
    source = instance.source;
    Period=instance.parameters.Period;
    Coeff=instance.parameters.Coeff;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Coeff .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	    ATR = core.indicators:create("ATR", source, Period);
	 first = ATR.DATA:first();
	
	
    WTS= instance:addInternalStream(0, 0);
 
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
end

function Update(period, mode)

  open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
   if period<first+Period then
    open:setColor(period, instance.parameters.NEclr);
   return;
   end
   
    ATR:update(mode);
    local loss=ATR.DATA[period]*Coeff;
    if source.close[period]>WTS[period-1] and source.close[period-1]>WTS[period-1] then
     WTS[period]=math.max(WTS[period-1], source.close[period]-loss);
    open:setColor(period, instance.parameters.DNclr);
    elseif source.close[period]<WTS[period-1] and source.close[period-1]<WTS[period-1] then
     WTS[period]=math.min(WTS[period-1], source.close[period]+loss);
    open:setColor(period, instance.parameters.UPclr);
    elseif source.close[period]>WTS[period-1] then
     WTS[period]=source.close[period]-loss;
    open:setColor(period, instance.parameters.DNclr);
    else
     WTS[period]=source.close[period]+loss;
    open:setColor(period, instance.parameters.UPclr);
    end 
   
end

