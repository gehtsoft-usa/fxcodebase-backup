-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59995
-- Id: 10549

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
    indicator:name("Step MA indicator");
    indicator:description("Step MA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("Kv", "Kv", "", 1);
    indicator.parameters:addInteger("StepSize", "Step size", "", 0);
    indicator.parameters:addString("Mode", "MA mode", "", "MVA");
    indicator.parameters:addStringAlternative("Mode", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Mode", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Mode", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Mode", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Mode", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Mode", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Mode", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Mode", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Mode", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Mode", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Mode", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Mode", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Mode", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Mode", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Mode", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Mode", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Mode", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Mode", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Mode", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Mode", "JSmooth", "", "JSmooth");
    indicator.parameters:addDouble("Percentage", "Percentage", "", 0);
    indicator.parameters:addString("UsePrice", "Use price", "", "0");
    indicator.parameters:addStringAlternative("UsePrice", "Close", "", "0");
    indicator.parameters:addStringAlternative("UsePrice", "High/Low", "", "1");
    indicator.parameters:addBoolean("ColorMode", "Color mode", "", false);
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Kv;
local StepSize;
local Mode;
local Percentage;
local UsePrice;
local ColorMode;
local smin, smax, trend;
local HL;
local MA_HL;
local pipSize;
local StepMA=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Kv=instance.parameters.Kv;
    StepSize=instance.parameters.StepSize;
    Mode=instance.parameters.Mode;
    Percentage=instance.parameters.Percentage/100;
    UsePrice=tonumber(instance.parameters.UsePrice);
    ColorMode=instance.parameters.ColorMode;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Kv .. ", " .. instance.parameters.StepSize .. ", " .. instance.parameters.Mode .. ", " .. instance.parameters.Percentage .. ", " .. instance.parameters.UsePrice .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    smin=instance:addInternalStream(0, 0);
    smax=instance:addInternalStream(0, 0);
    HL=instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    MA_HL=core.indicators:create("AVERAGES", HL, Mode, Period, false);
	
	first =  MA_HL.DATA:first()+2;
    StepMA = instance:addStream("StepMA", core.Line, name .. ".StepMA", "StepMA", instance.parameters.MainClr, first);
    StepMA:setWidth(instance.parameters.widthLinReg);
    StepMA:setStyle(instance.parameters.styleLinReg);
    pipSize=source:pipSize();
    if instance.parameters.I then
     trend=instance:addInternalStream(first, 0);
    else
     trend = instance:addStream("trend", core.Line, name .. ".trend", "trend", instance.parameters.MainClr, first);
    end 
end

function StepSizeCalc(index)
 if StepSize==0 then
  local ATRmin, ATRmax=mathex.minmax(MA_HL.DATA, MA_HL.DATA:first(), index);
  return math.floor(0.5*Kv*(ATRmax+ATRmin)/pipSize+0.5);
 else
  return Kv*StepSize;
 end 
end

function Update(period, mode)
  
    HL[period]=source.high[period]-source.low[period];
	if period>first+Period then
    MA_HL:update(mode);
    local Step=StepSizeCalc(period)*pipSize;
    if UsePrice==0 then
     smax[period]=source.close[period]+2*Step;
     smin[period]=source.close[period]-2*Step;
    else
     smax[period]=source.low[period]+2*Step;
     smin[period]=source.high[period]-2*Step;
    end
    trend[period]=trend[period-1];
    if source.close[period]>smax[period-1] then
     trend[period]=1;
    elseif source.close[period]<smin[period-1] then
     trend[period]=-1; 
    end
    local result;
    if trend[period]==1 then
     smin[period]=math.max(smin[period], smin[period-1]);
     StepMA[period]=smin[period]+Step+Percentage*Step;
    else
     smax[period]=math.min(smax[period], smax[period-1]);
     StepMA[period]=smax[period]-Step+Percentage*Step;
    end
    if ColorMode then
     if StepMA[period]>=StepMA[period-1] then
      StepMA:setColor(period, instance.parameters.UPclr);
     else
      StepMA:setColor(period, instance.parameters.DNclr);
     end
    end    
   end 
end

