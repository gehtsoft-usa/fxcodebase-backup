-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34072
-- Id: 8895

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
    indicator:name("Easy Trend Visualizer indicator");
    indicator:description("Easy Trend Visualizer indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXPeriod1", "ADX period 1", "", 10);
    indicator.parameters:addInteger("ADXPeriod2", "ADX period 2", "", 14);
    indicator.parameters:addInteger("ADXPeriod3", "ADX period 3", "", 20);
    indicator.parameters:addDouble("Level1", "Level 1", "", 35);
    indicator.parameters:addDouble("Level2", "Level 2", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Lclr", "Levels color", "Levels color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP arrow color", "UP arrow color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN arrow color", "DN arrow color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local ADXPeriod1;
local ADXPeriod2;
local ADXPeriod3;
local Level1;
local Level2;
local ADX1;
local ADX2;
local ADX3;
local DMI;
local To;
local Tc;
local LineBuff=nil;
local UP=nil;
local DN=nil;

function Prepare(nameOnly)
    source = instance.source;
    ADXPeriod1=instance.parameters.ADXPeriod1;
    ADXPeriod2=instance.parameters.ADXPeriod2;
    ADXPeriod3=instance.parameters.ADXPeriod3;
    Level1=instance.parameters.Level1;
    Level2=instance.parameters.Level2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ADXPeriod1 .. ", " .. instance.parameters.ADXPeriod2 .. ", " .. instance.parameters.ADXPeriod3 .. ", " .. instance.parameters.Level1 .. ", " .. instance.parameters.Level2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    To=instance:addInternalStream(source:first(), 0);
    Tc=instance:addInternalStream(source:first(), 0);
    ADX1 = core.indicators:create("ADX", source, ADXPeriod1);
    ADX2 = core.indicators:create("ADX", source, ADXPeriod2);
    ADX3 = core.indicators:create("ADX", source, ADXPeriod3);
    DMI = core.indicators:create("DMI", source, ADXPeriod1);
	
	
	 first =math.max( ADX1.DATA:first(),ADX2.DATA:first(),ADX3.DATA:first())
    LineBuff = instance:addStream("LineBuff", core.Line, name .. ".LineBuff", "LineBuff", instance.parameters.Lclr, first);
    LineBuff:setWidth(instance.parameters.widthLinReg);
    LineBuff:setStyle(instance.parameters.styleLinReg);
    UP = instance:createTextOutput ("UP", "UP", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    DN = instance:createTextOutput ("DN", "DN", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    ADX1:update(mode);
    ADX2:update(mode);
    ADX3:update(mode);
    DMI:update(mode);
    if ADX1.DATA[period]>ADX1.DATA[period-1] and ADX2.DATA[period]>ADX2.DATA[period-1] and ADX3.DATA[period]>ADX3.DATA[period-1] and ADX1.DATA[period]>Level1 and ADX2.DATA[period]>Level2 then
     local di=DMI.DIP[period]-DMI.DIM[period];
     local hi=math.max(source.open[period], source.close[period]);
     local lo=math.min(source.open[period], source.close[period]);
     local op=source.open[period];
     if di>0 then
      To[period]=lo;
      Tc[period]=hi;
      if To[period-1]==0 then
       UP:set(period, op, "\225");
      end 
     else
      To[period]=hi;
      Tc[period]=lo;
      if To[period-1]==0 then
       DN:set(period, op, "\226");
      end
     end
    else
     if To[period-1]~=0 then
      LineBuff[period]=source.close[period-1];
     else
      LineBuff[period]=LineBuff[period-1];
     end 
    end
 
end

