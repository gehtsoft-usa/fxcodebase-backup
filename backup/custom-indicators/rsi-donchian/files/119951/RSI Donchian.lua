-- Id: 21684
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66268

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
--

-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("RSI Donchian")
    indicator:description("RSI Donchian");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Period", "RSI Period", "", 20, 2, 10000);
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("clrRSI", "Color of the RSI line", "", core.rgb(255, 0, 0));
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
local Period;
local rsi,RSI;
-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    n = instance.parameters.N;
	Period= instance.parameters.Period;
	
	    local name = profile:id() .. "(" .. source:name() .. "," .. Period.. "," .. n .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes");
	
	
	rsi = core.indicators:create("RSI", source, Period);
	

    first =rsi.DATA:first()+n;
    if (not ac) then
        first = first + 1;
    end
    
	
	RSI = instance:addStream("DU", core.Line, name .. ".RSI", "RSI", instance.parameters.clrRSI,  rsi.DATA:first())
    RSI:setWidth(instance.parameters.width4);
    RSI:setStyle(instance.parameters.style4);
		
		
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
		dm:setPrecision(math.max(2, instance.source:getPrecision()));
    end
	
	RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	dn:setPrecision(math.max(2, instance.source:getPrecision()));
	du:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	
	dn:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	dn:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
end

-- calculate the value
function Update(period,mode)


    rsi:update(mode);
	
	if period < rsi.DATA:first() then
	return;
	end
	
	
	RSI[period]=rsi.DATA[period];

    if (period<first) then
	return;
	end
	
	
	
	
	local min,max;
	
	
	if ac then
	min,max = mathex.minmax (RSI, period -n +1  , period);
	else
	min,max = mathex.minmax (RSI, period-1 -n +1  , period-1);
	end
	
   
            du[period] =  max;
            dn[period] = min;
     
		
	
        if (sm) then
            dm[period] = (du[period] + dn[period]) / 2;
        end
   
end

