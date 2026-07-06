-- Id: 16043

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63479

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
    indicator:name("Higher Highs Lower Lows");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Period", "", 20);
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OverBought", "Overbought Level","", 60);
	indicator.parameters:addDouble("Threshold", "Threshold Level","", 50);
    indicator.parameters:addDouble("OverSold","Oversold Level","", 10);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	 
end


local first;
local Length;
local source;
local Up, Down;
local Threshold, OverBought, OverSold;
local HHS, LLS;
local HHH, LLL;
local high, low;
function Prepare(onlyName)
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Length=instance.parameters.Length;
	Threshold=instance.parameters.Threshold;
	OverBought=instance.parameters.OverBought;
	OverSold=instance.parameters.OverSold;
	source = instance.source; 
	first=source:first()+Length;
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. Length .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 
	
	HHH= instance:addInternalStream(first, 0);
	LLL= instance:addInternalStream(first, 0);
	
	high = core.indicators:create("EMA", HHH, Length);
	low = core.indicators:create("EMA", LLL, Length);

    HHS = instance:addStream("HHS", core.Line, name, "HHS", Up, high.DATA:first());
    HHS:setWidth(instance.parameters.width);
    HHS:setStyle(instance.parameters.style);
	
	LLS = instance:addStream("LLS", core.Line, name, "LLS", Down, low.DATA:first());
    LLS:setWidth(instance.parameters.width);
    LLS:setStyle(instance.parameters.style);
	
	LLS:addLevel(OverBought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	LLS:addLevel(OverSold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	LLS:addLevel(Threshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	 
    LLS:setPrecision(math.max(2, instance.source:getPrecision()));
	HHS:setPrecision(math.max(2, instance.source:getPrecision()));
end

 

function Update(period, mode)
 
	
    if period < first then
	return;
	end
	
    min_High, max_High=mathex.minmax(source.high, period-Length+1, period);
	min_Low, max_Low=mathex.minmax(source.high, period-Length+1, period);
	
	if source.high[period]> source.high[period-1] then
	HHH[period]=( source.high[period] - min_High )/( max_High - min_High );
	else
	HHH[period]=0;
	end
	
	if source.low[period]< source.low[period-1] then
	LLL[period]=( max_Low - source.low[period] )/( max_Low - min_Low );
	else
	LLL[period]=0;
	end 
			
	high:update(mode);
    low:update(mode);	
	
	 if period< high.DATA:first() then
	 return;
	 end
 
     HHS[period]= high.DATA[period]*100;
	 LLS[period]= low.DATA[period]*100;
end 