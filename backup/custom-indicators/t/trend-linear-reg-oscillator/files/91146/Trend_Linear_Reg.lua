-- Id: 10539

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59990

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
    indicator:name("Trend Linear Reg oscillator");
    indicator:description("Trend Linear Reg oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 128, 128));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(128, 255, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(255, 128, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(255, 0, 128));
end

local first;
local source = nil;
local Period;
local TLR=nil;
local sumx, sumx2;
local c;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period ;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    TLR = instance:addStream("TLR", core.Bar, name .. ".TLR", "TLR", instance.parameters.clr1, first);
    TLR:setPrecision(math.max(2, instance.source:getPrecision()));
    sumx=Period*(Period-1)/2;
    sumx2=Period*(Period-1)*(2*Period-1)/6;
    c=sumx2*Period-sumx*sumx;
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period>first then
    local i;
    local sumy, sumxy=0, 0;
    for i=0, Period-1, 1 do
     sumy=sumy+source[period-i];
     sumxy=sumxy+i*source[period-i];
    end
    local b=(sumxy*Period-sumx*sumy)/c;
    TLR[period]=-b/pipSize;
    if TLR[period]>0 then
     if TLR[period]>TLR[period-1] then
      TLR:setColor(period, instance.parameters.clr1);
     else
      TLR:setColor(period, instance.parameters.clr2);
     end
    else
     if TLR[period]>TLR[period-1] then
      TLR:setColor(period, instance.parameters.clr3);
     else
      TLR:setColor(period, instance.parameters.clr4);
     end
    end
   end 
end

