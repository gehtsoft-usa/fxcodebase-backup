-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21622
-- Id: 7093

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
    indicator:name("Color RSI indicator");
    indicator:description("Color RSI indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
    indicator.parameters:addDouble("OverBought", "OverBought", "", 80);
    indicator.parameters:addDouble("OverSold", "OverSold", "", 20);
    indicator.parameters:addBoolean("ShowArrow", "Show arrow", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSIclr", "RSI Color", "RSI Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("OBclr", "OverBought Color", "OverBought Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("OSclr", "OverSold Color", "OverSold Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 2, 1, 5);
    indicator.parameters:addColor("UpArrowclr", "Up arrow Color", "Up arrow Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DnArrowclr", "Down arrow Color", "Down arrow Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Period;
local OverBought;
local OverSold;
local ShowArrow;
local RSI_Ind;
local RSI=nil;
local OB=nil;
local OS=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    OverBought=instance.parameters.OverBought;
    OverSold=instance.parameters.OverSold;
    ShowArrow=instance.parameters.ShowArrow;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.OverBought .. ", " .. instance.parameters.OverSold .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI_Ind = core.indicators:create("RSI", source, Period);
	first = RSI_Ind.DATA:first() ;
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    OB = instance:addStream("OB", core.Dot, name .. ".OverBought", "OverBought", instance.parameters.OBclr, first);
    OS = instance:addStream("OS", core.Dot, name .. ".OverSold", "OverSold", instance.parameters.OSclr, first);
    RSI:setWidth(instance.parameters.widthLinReg);
    RSI:setStyle(instance.parameters.styleLinReg);
	
	RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    OB:setPrecision(math.max(2, instance.source:getPrecision()));
    OS:setPrecision(math.max(2, instance.source:getPrecision()));
	
    OB:setWidth(instance.parameters.DotSize);
    OS:setWidth(instance.parameters.DotSize);
    if ShowArrow then
     UpArrow = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UpArrowclr);
     DnArrow = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DnArrowclr);
    end
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
    RSI_Ind:update(mode);
    RSI[period]=RSI_Ind.DATA[period];
    if RSI_Ind.DATA[period]>OverBought then
     OB[period]=RSI_Ind.DATA[period];
     if ShowArrow and RSI_Ind.DATA[period-1]<OverBought then
      UpArrow:set(period, RSI_Ind.DATA[period], "\226");
     end
    end
    if RSI_Ind.DATA[period]<OverSold then
     OS[period]=RSI_Ind.DATA[period];
     if ShowArrow and RSI_Ind.DATA[period-1]>OverSold then
      DnArrow:set(period, RSI_Ind.DATA[period], "\225");
     end
    end
    
end

