-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3682

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stochastic color candle");
    indicator:description("Stochastic color candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "K", "K", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "SD", "SD", 3, 2, 1000);
    indicator.parameters:addInteger("D", "D", "D", 3, 2, 1000);
    indicator.parameters:addDouble("Level1", "Level1", "Level1", 20);
    indicator.parameters:addDouble("Level2", "Level2", "Level2", 80);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local K;
local SD;
local D;
local Level1;
local Level2;
local Stoch;


local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


function Prepare(nameOnly)
    source = instance.source;
    K=instance.parameters.K;
    SD=instance.parameters.SD;
    D=instance.parameters.D;
    Level1=instance.parameters.Level1;
    Level2=instance.parameters.Level2;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K .. ", " .. instance.parameters.SD .. ", " .. instance.parameters.D .. ", " .. instance.parameters.Level1 .. ", " .. instance.parameters.Level2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Stoch = core.indicators:create("STOCHASTIC", source, K, SD, D);
   
    first = Stoch.DATA:first();
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
	

   if (period<first) then
   return;
   end
   
    Stoch:update(mode);
    if Stoch.D[period]<Level1 then
    open:setColor(period, instance.parameters.clr1);	  
    elseif Stoch.D[period]>=Level1 and Stoch.D[period]<=Level2 then
    open:setColor(period, instance.parameters.clr2);  
    elseif Stoch.D[period]>Level2 then
    open:setColor(period, instance.parameters.clr3); 
    end
   
end

