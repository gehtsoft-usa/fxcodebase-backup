
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
--

-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Donchian Channel")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);    
	 indicator.parameters:addString("MD", "Show Close or High/Low", "", "Close");
    indicator.parameters:addStringAlternative("MD", "Close", "", "Close");
    indicator.parameters:addStringAlternative("MD", "High/Low", "", "HighLow");
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addString("SHL", "Show High/Low lines", "Show High/Low lines", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "Both lines", "", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "High only", "", "High"); 
    indicator.parameters:addStringAlternative("SHL", "Low only", "", "Low"); 
	indicator.parameters:addBoolean("SM", "Show middle line", "", true);  
	indicator.parameters:addBoolean("SUB", "Show Sub Levels", "", false);
	indicator.parameters:addBoolean("AC", "Analyze the current period", "", true);  
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDU", "Up Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDU", "Up Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDU", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDN", "Down Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDN", "Down Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDN", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthDM", "Middle Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDM", "Middle Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDM", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clrSUB", "Color of the Sub Level lines", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthSUB", "Sub Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSUB", "Sub Level Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSUB", core.FLAG_LINE_STYLE);

end

local first = 0;
local n = 0;
local ac;
local sm;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local MODE=nil;
local SUB;
local SHL;
local low, high;

-- initializes the instance of the indicator
function Prepare(nameOnly) 
    SUB = instance.parameters.SUB;
    SHL = instance.parameters.SHL;
    source = instance.source;
    n = instance.parameters.N;
	MODE=instance.parameters.MD; 
    ac =instance.parameters.AC;
    sm = instance.parameters.SM;

    first = n + source:first() - 1;
    if (not ac) then
        first = first + 1;
    end
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    if (SHL == "High" or SHL == "Both") then
        du = instance:addStream("DU", core.Line, name .. ".DU", "U", instance.parameters.clrDU,  first)
        du:setWidth(instance.parameters.widthDU);
        du:setStyle(instance.parameters.styleDU);
    else
        du = instance:addInternalStream(0, 0)
    end
    
    if SHL == "Low" or SHL == "Both"  then
        dn = instance:addStream("DN", core.Line, name .. ".DN", "D", instance.parameters.clrDN,  first)
        dn:setWidth(instance.parameters.widthDN);
        dn:setStyle(instance.parameters.styleDN);
    else
        dn = instance:addInternalStream(0, 0)
    end
    
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "M", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.widthDM);
        dm:setStyle(instance.parameters.styleDM);
    end
	
	if SUB then
	high = instance:addStream("high", core.Line, name .. ".DMU", "S", instance.parameters.clrSUB,  first)
	    high:setWidth(instance.parameters.widthSUB);
        high:setStyle(instance.parameters.styleSUB);
	low = instance:addStream("low", core.Line, name .. ".DMD", "S", instance.parameters.clrSUB,  first)
	    low:setWidth(instance.parameters.widthSUB);
        low:setStyle(instance.parameters.styleSUB);
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
		
		if  MODE=="Close" then
            du[period] = core.max(source.close, range); 
            dn[period] = core.min(source.close, range); 
		else
            du[period] = core.max(source.high, range); 
            dn[period] = core.min(source.low, range); 
		end
        if (sm) then
            dm[period] = (du[period] + dn[period]) / 2;
        end
		
		if SUB then
            high[period]=  (du[period] + dm[period]) / 2;
            low[period]=   (dn[period] + dm[period]) / 2;
		end
    end
end

