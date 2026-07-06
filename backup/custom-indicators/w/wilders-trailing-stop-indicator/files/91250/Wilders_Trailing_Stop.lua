
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=60028
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Wilders Trailing Stop indicator");
    indicator:description("Wilders Trailing Stop indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
    indicator.parameters:addDouble("Coeff", "Coeff", "", 3.5);

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
local Coeff;
local ATR;
local WTS=nil;

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
   
    WTS = instance:addStream("WTS", core.Line, name .. ".WTS", "WTS", instance.parameters.UPclr, first);
    WTS:setWidth(instance.parameters.widthLinReg);
    WTS:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first+Period then
    ATR:update(mode);
    local loss=ATR.DATA[period]*Coeff;
    if source.close[period]>WTS[period-1] and source.close[period-1]>WTS[period-1] then
     WTS[period]=math.max(WTS[period-1], source.close[period]-loss);
     WTS:setColor(period, instance.parameters.DNclr);
    elseif source.close[period]<WTS[period-1] and source.close[period-1]<WTS[period-1] then
     WTS[period]=math.min(WTS[period-1], source.close[period]+loss);
     WTS:setColor(period, instance.parameters.UPclr);
    elseif source.close[period]>WTS[period-1] then
     WTS[period]=source.close[period]-loss;
     WTS:setColor(period, instance.parameters.DNclr);
    else
     WTS[period]=source.close[period]+loss;
     WTS:setColor(period, instance.parameters.UPclr);
    end 
   end 
end

