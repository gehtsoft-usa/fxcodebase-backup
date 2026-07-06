
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41453&p=116479#p116479

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
    indicator:name("Non Repainting Super Trend indicator");
    indicator:description("Non Repainting Super Trend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 4);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Multiplier;
local ATR;
local trend;
local up, dn;
local NR_Super_Trend=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    Multiplier=instance.parameters.Multiplier;
    first = source:first()+2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Multiplier .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    trend = instance:addInternalStream(first, 0);
    up = instance:addInternalStream(first, 0);
    dn = instance:addInternalStream(first, 0);
    ATR = core.indicators:create("ATR", source, Period);
  
    NR_Super_Trend = instance:addStream("NR_Super_Trend", core.Line, name .. ".NR_Super_Trend", "NR_Super_Trend", instance.parameters.UPclr, first);
    NR_Super_Trend:setWidth(instance.parameters.widthLinReg);
    NR_Super_Trend:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    ATR:update(mode);
    up[period]=source.median[period]+Multiplier*ATR.DATA[period];
    dn[period]=source.median[period]-Multiplier*ATR.DATA[period];
    trend[period]=trend[period-1];
    if source.close[period]>up[period-1] then
     trend[period]=1;
    elseif source.close[period]<dn[period-1] then
     trend[period]=-1; 
    end
    if trend[period]==1 and dn[period]<dn[period-1] then
     dn[period]=dn[period-1];
    end
    if trend[period]==-1 and up[period]>up[period-1] then
     up[period]=up[period-1];
    end
    if trend[period]==1 then
     NR_Super_Trend[period]=dn[period];
     NR_Super_Trend:setColor(period, instance.parameters.DNclr);
    else
     NR_Super_Trend[period]=up[period];
     NR_Super_Trend:setColor(period, instance.parameters.UPclr);
    end
   end 
end

