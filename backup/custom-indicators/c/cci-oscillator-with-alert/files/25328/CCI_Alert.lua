-- Id: 5759
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12937

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

function Init()
    indicator:name("CCI oscillator with alert");
    indicator:description("CCI oscillator with alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI period", "", 14);
	indicator.parameters:addBoolean("Live", "Live", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));

    indicator.parameters:addGroup("OB/OS Levels");    
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local LastTime;
local CCI_Period;
local CCI;
local Buff = nil;
local Alert = nil;
local Live;
function Prepare(nameOnly)
    source = instance.source;
    CCI_Period = instance.parameters.CCI_Period;
	Live= instance.parameters.Live;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    CCI = core.indicators:create("CCI", source, CCI_Period);
	first = CCI.DATA:first();
    LastTime = nil;
    Buff = instance:addStream("Buff", core.Line, name .. ".CCI", "CCI", instance.parameters.clr, first);
    Buff:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    Buff:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Buff:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	
	Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function ShowMessage(Message)
    terminal:alertMessage(source:instrument(), source[source:size() - 1], Message, source:date(NOW));
end

function Update(period, mode)
    if period < first then
	return;
	end
	
	local Shift=0;
	
	if not Live then
	period=period-1;
	Shift=1;
	end
	
        CCI:update(mode);
        Buff[period] = CCI.DATA[period];
		
        if period == (source:size() - 1-Shift) and LastTime ~= source:date(period) then
            LastTime = source:date(period);
            if CCI.DATA[period-1 ] <= 0 and CCI.DATA[period] > 0 then
                ShowMessage("CCI>0");
            elseif CCI.DATA[period-1 ] >= 0 and CCI.DATA[period] < 0 then
                ShowMessage("CCI<0");
			elseif CCI.DATA[period ]> instance.parameters.overbought and CCI.DATA[period-1] <= instance.parameters.overbought then
                ShowMessage("CCI>Overbought");	
			elseif CCI.DATA[period ]< instance.parameters.oversold and CCI.DATA[period-1] <= instance.parameters.oversold then
                ShowMessage("CCI<Oversold");		
            end
        end
    
end
