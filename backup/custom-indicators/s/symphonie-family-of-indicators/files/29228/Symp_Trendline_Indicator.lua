-- Id: 6244
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15511

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

--                                 Symphonie Trendline Indicator v3.0 


function Init()
    indicator:name("Symphonie Trendline indicator");
    indicator:description("Symphonie Trendline indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "Period of CCI", "", 63);
    indicator.parameters:addInteger("ATR_Period", "Period of ATR", "", 18);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnClr", "Dn Color", "Dn Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local CCI_Period, ATR_Period;
local CCI, ATR;
local Symp_Trendline=nil;

function Prepare(nameOnly)
    source = instance.source;
    CCI_Period=instance.parameters.CCI_Period;
    ATR_Period=instance.parameters.ATR_Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. CCI_Period .. ", " .. ATR_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    CCI=core.indicators:create("CCI", source, CCI_Period);
    ATR=core.indicators:create("ATR", source, ATR_Period);
	
	first = math.max(CCI.DATA:first(),ATR.DATA:first())
    Symp_Trendline = instance:addStream("Symp_Trendline", core.Line, name .. ".Symp_Trendline", "Symp_Trendline", instance.parameters.UpClr, first);
    Symp_Trendline:setWidth(instance.parameters.widthLinReg);
    Symp_Trendline:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    CCI:update(mode);
    ATR:update(mode);
    if CCI.DATA[period]>=0 then
     Symp_Trendline[period]=source.low[period]-ATR.DATA[period];
     if Symp_Trendline[period]<Symp_Trendline[period-1] then
      Symp_Trendline[period]=Symp_Trendline[period-1];
     end
     Symp_Trendline:setColor(period,instance.parameters.UpClr);
    else
     Symp_Trendline[period]=source.high[period]+ATR.DATA[period];
     if Symp_Trendline[period]>Symp_Trendline[period-1] then
      Symp_Trendline[period]=Symp_Trendline[period-1];
     end
     Symp_Trendline:setColor(period,instance.parameters.DnClr);
    end
   end 
end

