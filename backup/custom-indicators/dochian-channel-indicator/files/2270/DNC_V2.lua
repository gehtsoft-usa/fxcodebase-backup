
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20

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


-- http://vtsystems.com/resources/helps/0000/HTML_VTtrader_Help_Manual/index.html?ti_donchianchannel.html
 

-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Donchian Channel")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Wine Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Wine Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Wine Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
	indicator.parameters:addBoolean("MD", "High/Low", "", true);

end

local first = 0;
local n = 0;
local ac = true;
local sm = false;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local MODE=nil;

-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    n = instance.parameters.N;
	MODE=instance.parameters.MD; 
    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes");

    first = n + source:first() - 1;
    if (not ac) then
        first = first + 1;
    end
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    dn = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
    du = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.width3);
        dm:setStyle(instance.parameters.style3);
    end
end

-- calculate the value
function Update(period)
    if (period >= first) then
        local range;
        if (ac) then
            range = core.rangeTo(period, n);
        else
            range = core.rangeTo(period - 1, n);
        end
		
		if (MODE) then
        du[period] = core.max(source.high, range);
        dn[period] = core.min(source.low, range);
		else
		du[period] = core.max(source.close, range);
        dn[period] = core.min(source.close, range);
		end
        if (sm) then
            dm[period] = (du[period] + dn[period]) / 2;
        end
    end
end

