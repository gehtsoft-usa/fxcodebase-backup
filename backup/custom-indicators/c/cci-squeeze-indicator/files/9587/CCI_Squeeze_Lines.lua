-- Id: 3604
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI Squeeze Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("CCI Squeeze Parameters");
    indicator.parameters:addInteger("MA_Period", "Period of MA", "Period of MA", 200);
    indicator.parameters:addString("MA_Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "", "TMA");
    indicator.parameters:addInteger("CCI_Period", "Period of CCI", "Period of CCI", 50);

    indicator.parameters:addColor("upB_color", "Color of upB", "Color of upB", core.rgb(0, 255, 0));
    indicator.parameters:addColor("loB_color", "Color of loB", "Color of loB", core.rgb(255, 128, 64));
    indicator.parameters:addColor("upB2_color", "Color of upB2", "Color of upB2", core.rgb(0, 64, 0));
    indicator.parameters:addColor("loB2_color", "Color of loB2", "Color of loB2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("line_color", "Color of line", "Color of line", core.rgb(128, 128, 128));

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought level", "Overbought level", 50, -1000, 1000);
    indicator.parameters:addInteger("oversold", "Oversold level", "Oversold level", -50, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "Level lines width", "The width of the overbought/oversold levels", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level lines stype", "The style of the overbought/oversold levels", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Level lines color", "The color of the overbought/oversold levels"  , core.rgb(96, 96, 138));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local first;
local source = nil;
local MA;
local CCI;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    CCI_Period=instance.parameters.CCI_Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. MA_Period .. ", " .. MA_Method .. ", " .. CCI_Period .. ")";
    instance:name(name);
	
	if nameOnly then
        return;
    end
	
	
	MA = core.indicators:create(MA_Method, source.close, MA_Period);
    CCI = core.indicators:create("CCI", source, CCI_Period);
    first = math.max(MA.DATA:first(),CCI.DATA:first())+2;
	
	
    upB = instance:addStream("upB", core.Bar, name .. ".upB", "upB", instance.parameters.upB_color, first);
    loB = instance:addStream("loB", core.Bar, name .. ".loB", "loB", instance.parameters.loB_color, first);
    upB2 = instance:addStream("upB2", core.Bar, name .. ".upB2", "upB2", instance.parameters.upB2_color, first);
    loB2 = instance:addStream("loB2", core.Bar, name .. ".loB2", "loB2", instance.parameters.loB2_color, first);
	

    cciline = instance:addStream("cciline", core.Line, name .. ".cciline", "cciline", instance.parameters.line_color, first);
    cciline:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    cciline:addLevel(0);
    cciline:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	
	upB:setPrecision(math.max(2, instance.source:getPrecision()));	 
	loB:setPrecision(math.max(2, instance.source:getPrecision()));	 
	upB2:setPrecision(math.max(2, instance.source:getPrecision()));	 
	loB2:setPrecision(math.max(2, instance.source:getPrecision()));
	cciline:setPrecision(math.max(2, instance.source:getPrecision()));

end

function Update(period, mode)
    MA:update(mode);
    CCI:update(mode);
    if (period>first) then
     cciline[period]=CCI.DATA[period];
     if source.close[period]<MA.DATA[period] then
      if CCI.DATA[period]>0. then
       upB[period]=CCI.DATA[period];
       loB[period]=nil;
       upB2[period]=nil;
       loB2[period]=nil;
      else
       upB[period]=nil;
       loB[period]=CCI.DATA[period];
       upB2[period]=nil;
       loB2[period]=nil;
      end
     else
      if CCI.DATA[period]>0. then
       upB[period]=nil;
       loB[period]=nil;
       upB2[period]=CCI.DATA[period];
       loB2[period]=nil;
      else
       upB[period]=nil;
       loB[period]=nil;
       upB2[period]=nil;
       loB2[period]=CCI.DATA[period];
      end
     end
    end
end

