-- Id: 20500
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65698

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



function Init()
    indicator:name("Candle wicks average density");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addInteger("MA_Period", "MA Period", "Period" , 14);
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Bar color", "Bar Color", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("color2", "Down Bar color", "Bar Color", core.rgb(255, 0, 0));
    
	indicator.parameters:addColor("color3", "Top Line color", "Bar Color", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color4", "Bottom Line color", "Bar Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local source;
 
local Up, Down ;
local MA1,MA2 , MA_Period,MA_Method;
 
-- Routine
 function Prepare(nameOnly)  
   
 
	MA_Period= instance.parameters.MA_Period;
	MA_Method= instance.parameters.MA_Method;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	 
    Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.color1, source:first());
    Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.color2, source:first());
	
	 MA1 = core.indicators:create(MA_Method, Up, MA_Period);
	 MA2 = core.indicators:create(MA_Method, Down, MA_Period);
	 
	Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.color3, source:first());
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
		
    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.color4, source:first());
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
	Up:setPrecision(math.max(2, instance.source:getPrecision()));
	Down:setPrecision(math.max(2, instance.source:getPrecision()));
	Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
function Update(period, mode)
    
	
	Up[period]= (source.high[period]- math.max(source.open[period], source.close[period]))/source:pipSize();
	Down[period]=- ( math.min(source.open[period], source.close[period]) -source.low[period])/source:pipSize();
	
	
	
	MA1:update(mode);
	MA2:update(mode);
	 
	if MA1.DATA:hasData(period)then
	Top[period]=MA1.DATA[period]
	Bottom[period]=MA2.DATA[period]
	end
	
	
end






