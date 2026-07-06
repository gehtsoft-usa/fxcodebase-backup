-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41454
-- Id: 9379

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
    indicator:name("Step RSI oscillator");
    indicator:description("Step RSI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addInteger("StepFast", "Step size fast", "", 5);
    indicator.parameters:addInteger("StepSlow", "Step size slow", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSIclr", "RSI color", "RSI color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RSIwidth", "RSI width", "RSI width", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI style", "RSI style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("StepFclr", "Step RSI fast color", "Step RSI fast color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("StepFwidth", "Step RSI fast width", "Step RSI fast width", 1, 1, 5);
    indicator.parameters:addInteger("StepFstyle", "Step RSI fast style", "Step RSI fast style", core.LINE_SOLID);
    indicator.parameters:setFlag("StepFstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("StepSclr", "Step RSI slow color", "Step RSI slow color", core.rgb(255, 222, 0));
    indicator.parameters:addInteger("StepSwidth", "Step RSI slow width", "Step RSI slow width", 1, 1, 5);
    indicator.parameters:addInteger("StepSstyle", "Step RSI slow style", "Step RSI slow style", core.LINE_SOLID);
    indicator.parameters:setFlag("StepSstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local StepFast;
local StepSlow;
local fmin, fmax, smin, smax;
local ftrend, strend;
local RSI_Ind;
local RSI=nil;
local StepRSIFast=nil;
local StepRSISlow=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    StepFast=instance.parameters.StepFast;
    StepSlow=instance.parameters.StepSlow;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.StepFast .. ", " .. instance.parameters.StepSlow .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    fmin = instance:addInternalStream(0, 0);
    fmax = instance:addInternalStream(0, 0);
    ftrend = instance:addInternalStream(0, 0);
    smin = instance:addInternalStream(0, 0);
    smax = instance:addInternalStream(0, 0);
    strend = instance:addInternalStream(0, 0);
    RSI_Ind = core.indicators:create("RSI", source.close, Period);
	first=RSI_Ind.DATA:first();
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.RSIwidth);
    RSI:setStyle(instance.parameters.RSIstyle);
    StepRSIFast = instance:addStream("StepRSIFast", core.Line, name .. ".StepRSIFast", "StepRSIFast", instance.parameters.StepFclr, first);
    StepRSIFast:setPrecision(math.max(2, instance.source:getPrecision()));
    StepRSIFast:setWidth(instance.parameters.StepFwidth);
    StepRSIFast:setStyle(instance.parameters.StepFstyle);
    StepRSISlow = instance:addStream("StepRSISlow", core.Line, name .. ".StepRSISlow", "StepRSISlow", instance.parameters.StepSclr, first);
    StepRSISlow:setPrecision(math.max(2, instance.source:getPrecision()));
    StepRSISlow:setWidth(instance.parameters.StepSwidth);
    StepRSISlow:setStyle(instance.parameters.StepSstyle);
end

function Update(period, mode)


   if period<first then
   return;
   end
   
    RSI_Ind:update(mode);
    ftrend[period]=ftrend[period-1];
    strend[period]=strend[period-1];
    fmax[period]=RSI_Ind.DATA[period]+2*StepFast;
    fmin[period]=RSI_Ind.DATA[period]-2*StepFast;
    if RSI_Ind.DATA[period]>fmax[period-1] then
     ftrend[period]=1;
    elseif RSI_Ind.DATA[period]<fmin[period-1] then
     ftrend[period]=-1; 
    end
    if ftrend[period]==1 and fmin[period]<fmin[period-1] then
     fmin[period]=fmin[period-1];
    elseif ftrend[period]==-1 and fmax[period]>fmax[period-1] then
     fmax[period]=fmax[period-1];
    end
    smax[period]=RSI_Ind.DATA[period]+2*StepSlow;
    smin[period]=RSI_Ind.DATA[period]-2*StepSlow;
    if RSI_Ind.DATA[period]>smax[period-1] then
     strend[period]=1;
    elseif RSI_Ind.DATA[period]<smin[period-1] then
     strend[period]=-1;
    end
    if strend[period]==1 and smin[period]<smin[period-1] then
     smin[period]=smin[period-1];
    elseif strend[period]==-1 and smax[period]>smax[period-1] then
     smax[period]=smax[period-1];
    end
    RSI[period]=RSI_Ind.DATA[period];
    if ftrend[period]>=0 then
     StepRSIFast[period]=fmin[period]+StepFast;
    else
     StepRSIFast[period]=fmax[period]-StepFast;
    end
    if strend[period]>=0 then
     StepRSISlow[period]=smin[period]+StepSlow;
    else
     StepRSISlow[period]=smax[period]-StepSlow;
    end
 
end

