-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3695

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
    indicator:name("Indicator color candle");
    indicator:description("Indicator color candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("IN", "Indicator", "", "");
    indicator.parameters:setFlag("IN",core.FLAG_INDICATOR);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
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
local Price;
local Ind;


local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

function Prepare(nameOnly)
    source = instance.source;
    Level1=instance.parameters.Level1;
    Level2=instance.parameters.Level2;
    Price=instance.parameters.Price;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.IN .. ", " .. instance.parameters.Level1 .. ", " .. instance.parameters.Level2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params = instance.parameters:getCustomParameters("IN");
    if  ind_:requiredSource() == core.Tick then
     if Price=="close" then
      Ind = ind_:createInstance(source.close, params);
     elseif Price=="open" then
      Ind = ind_:createInstance(source.open, params);
     elseif Price=="high" then
      Ind = ind_:createInstance(source.high, params);
     elseif Price=="low" then
      Ind = ind_:createInstance(source.low, params);
     elseif Price=="median" then
      Ind = ind_:createInstance(source.median, params);
     elseif Price=="typical" then
      Ind = ind_:createInstance(source.typical, params);
     else
      Ind = ind_:createInstance(source.weighted, params);
     end
    else
     Ind = ind_:createInstance(source, params);
    end 
	
	 first = Ind.DATA:first();
	
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
	
	
   if (period <first) then
   return;
   end
   
    Ind:update(mode);
    if Ind.DATA[period]<Level1 then 
	open:setColor(period,  instance.parameters.clr1);	
    elseif Ind.DATA[period]>=Level1 and Ind.DATA[period]<=Level2 then 
	open:setColor(period,  instance.parameters.clr2);	
    elseif Ind.DATA[period]>Level2 then
    open:setColor(period,  instance.parameters.clr3);		
    end
 
end

