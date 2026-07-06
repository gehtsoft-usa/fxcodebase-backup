 

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67387

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
 

-- initializes the indicator
function Init()

    indicator:name("Donchian Channel of RSI")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14, 1, 2000);
 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
	
	indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
	
 
	
	
	indicator.parameters:addGroup("Donchian Lines Style");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE); 
	
	
	indicator.parameters:addGroup("RSI Line Style");
    indicator.parameters:addColor("clrRSI", "Color of the RSI line", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local first = 0;
local n = 0;
local ac = true;
local sm = false;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local Indicator;
local RSI;
local Period; 
local Size;
local ShowLabel;
-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    n = instance.parameters.N;
	
	
	 local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes"); 

 
	Period=instance.parameters.Period;
	

	Indicator = core.indicators:create("RSI", source, Period);
	
    first = n + Indicator.DATA:first() - 1;
    if (not ac) then
        first = first + 1;
    end
   
    du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.width3);
        dm:setStyle(instance.parameters.style3);
    end
	
	RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.clrRSI,  first)
	RSI:setWidth(instance.parameters.width4);
    RSI:setStyle(instance.parameters.style4);
	
	du:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	du:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	du:setPrecision(math.max(2, instance.source:getPrecision()));
	dn:setPrecision(math.max(2, instance.source:getPrecision()));
	if (sm) then
	dm:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	RSI:setPrecision(math.max(2, instance.source:getPrecision()));
end


 
-- calculate the value
function Update(period)


    Indicator:update(mode);
	
    if (period< first) then
	return;
	end
        RSI[period]=Indicator.DATA[period];
    
 	
        if (ac) then
            dn[period] = mathex.min(Indicator.DATA, period-n+1, period);
			du[period] = mathex.max(Indicator.DATA, period-n+1, period);
        else
            dn[period] = mathex.min(Indicator.DATA, period-n+1-1, period-1);
			du[period] = mathex.max(Indicator.DATA, period-n+1-1, period-1);
        end		
        
	
	
	     if (sm) then
            dm[period] = (du[period] + dn[period]) / 2;
        end
end

