
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18973

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
    indicator:name("VolMA indicator");
    indicator:description("VolMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSIVolumePeriod", "Volume RSI Period", "", 20);
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSIVolumePeriod;
local Period;
local Price;
local VolumeRSI;
local VolMA=nil;
local p;

function Prepare(nameOnly)
    source = instance.source;
    RSIVolumePeriod=instance.parameters.RSIVolumePeriod;
    Period=instance.parameters.Period;
    Price=instance.parameters.Price;
    first = source:first();
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSIVolumePeriod .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	VolumeRSI = core.indicators:create("RSI", source.volume, RSIVolumePeriod);
	
	
    VolMA = instance:addStream("VolMA", core.Line, name .. ".VolMA", "VolMA", instance.parameters.clr, first+RSIVolumePeriod);
    VolMA:setWidth(instance.parameters.widthLinReg);
    VolMA:setStyle(instance.parameters.styleLinReg);
    if Price=="close" then
     p=source.close;
    elseif Price=="open" then
     p=source.open;
    elseif Price=="high" then
     p=source.high;
    elseif Price=="low" then
     p=source.low;
    elseif Price=="median" then
     p=source.median;
    elseif Price=="typical" then
     p=source.typical;
    else
     p=source.weighted;
    end 
end

function Update(period, mode)
   if (period>first+RSIVolumePeriod) then
    VolumeRSI:update(mode);
    local PeriodMA=math.floor(VolumeRSI.DATA[period]*Period/100);
    PeriodMA=math.max(PeriodMA,1);
    local StartBar=period-PeriodMA+1;
    if StartBar<first then
     VolMA[period]=nil;
    else 
     VolMA[period]=mathex.avg(p,core.range(StartBar,period));
    end 
   end 
end

