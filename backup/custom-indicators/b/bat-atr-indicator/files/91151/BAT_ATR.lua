-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59994
-- Id: 10548

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("BAT ATR indicator");
    indicator:description("BAT ATR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 3);
    indicator.parameters:addDouble("Factor", "Factor", "", 3);
    indicator.parameters:addBoolean("UseTypicalPrice", "Use typical price", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("UPwidth", "UP line width", "UP line width", 1, 1, 5);
    indicator.parameters:addInteger("UPstyle", "UP line style", "UP line style", core.LINE_SOLID);
    indicator.parameters:setFlag("UPstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DNwidth", "DN line width", "DN line width", 1, 1, 5);
    indicator.parameters:addInteger("DNstyle", "DN line style", "DN line style", core.LINE_SOLID);
    indicator.parameters:setFlag("DNstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ATR_Period;
local Factor;
local UseTypicalPrice;
local UP=nil;
local DN=nil;
local PriceLevel;
local ATR;
local Dir;
local LevelUp, LevelDn;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Period=instance.parameters.ATR_Period;
    Factor=instance.parameters.Factor;
    UseTypicalPrice=instance.parameters.UseTypicalPrice;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.Factor .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Dir = instance:addInternalStream(first, 0);
    LevelUp = instance:addInternalStream(first, 0);
    LevelDn = instance:addInternalStream(first, 0);
    ATR = core.indicators:create("ATR", source, ATR_Period);
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first+ATR_Period );
    UP:setWidth(instance.parameters.UPwidth);
    UP:setStyle(instance.parameters.UPstyle);
    DN = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first+ATR_Period );
    DN:setWidth(instance.parameters.DNwidth);
    DN:setStyle(instance.parameters.DNstyle);
    if UseTypicalPrice then
     PriceLevel=source.typical;
    else
     PriceLevel=source.close;
    end
end

function Update(period, mode)
   local CurrUp, PrevUp, CurrDn, PrevDn; 
   if period>first+ATR_Period then
    ATR:update(mode);
    CurrUp=PriceLevel[period]-ATR.DATA[period]*Factor;
    CurrDn=PriceLevel[period]+ATR.DATA[period]*Factor;
    Dir[period]=Dir[period-1];
    LevelUp[period]=LevelUp[period-1];
    LevelDn[period]=LevelDn[period-1];
    if Dir[period]==1 then
     LevelUp[period]=math.max(LevelUp[period], CurrUp);
     DN[period]=LevelUp[period];
     UP[period]=nil;
     if source.low[period]<DN[period] then
      Dir[period]=-1;
      LevelDn[period]=100000;
     end
    else
     LevelDn[period]=math.min(LevelDn[period], CurrDn);
     UP[period]=LevelDn[period];
     DN[period]=nil;
     if source.high[period]>UP[period] then
      Dir[period]=1;
      LevelUp[period]=0;
     end
    end
   elseif period==first+ATR_Period then
    ATR:update(mode);
    CurrUp=source.close[period]-ATR.DATA[period]*Factor;
    PrevUp=source.close[period-1]-ATR.DATA[period-1]*Factor;
    CurrDn=source.close[period]+ATR.DATA[period]*Factor;
    PrevDn=source.close[period-1]+ATR.DATA[period-1]*Factor;
    if CurrUp>PrevUp then
     Dir[period]=1;
     LevelUp[period]=CurrUp;
    elseif CurrDn<PrevDn then
     Dir[period]=-1;
     LevelDn[period]=CurrDn; 
    end
   end 
end

