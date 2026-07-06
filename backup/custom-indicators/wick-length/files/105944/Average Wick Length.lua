-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63410

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
    indicator:name("Average Wick Length");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addString("Method", "Calculation Method", "Method" , "Separated");
    indicator.parameters:addStringAlternative("Method", "Separated", "Separated" , "Separated");
	indicator.parameters:addStringAlternative("Method", "Separated Opposite Only", "Separated Opposite Only" , "Separated Opposite Only");
    indicator.parameters:addStringAlternative("Method", "Cumulative", "Cumulative" , "Cumulative");
    indicator.parameters:addStringAlternative("Method", "Difference", "Difference" , "Difference");
	
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

  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local source;
local Method;
local Up, Down, Cumulative, Difference;
local MA1,MA2, MA3,MA4, MA_Period,MA_Method;
local RawUp, RawDown, RawCumulative, RawDifference;
-- Routine
 function Prepare(nameOnly)  
   
	Method= instance.parameters.Method;
	MA_Period= instance.parameters.MA_Period;
	MA_Method= instance.parameters.MA_Method;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	 RawUp = instance:addInternalStream(0, 0);
	 RawDown = instance:addInternalStream(0, 0);
	 RawDifference = instance:addInternalStream(0, 0);
	 RawCumulative = instance:addInternalStream(0, 0);
	 MA1 = core.indicators:create(MA_Method, RawUp, MA_Period);
	 MA2 = core.indicators:create(MA_Method, RawDown, MA_Period);
	 MA3 = core.indicators:create(MA_Method, RawDifference, MA_Period);
	 MA4 = core.indicators:create(MA_Method, RawCumulative, MA_Period);
	 
	
	if Method== "Separated" or  Method== "Separated Opposite Only"  then
    Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.color1, source:first());
    Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.color2, source:first());
	else
	Up = instance:addInternalStream(source:first(), 0);
	Down = instance:addInternalStream(source:first(), 0);
	end
	
	
	if Method== "Difference" then
    Difference = instance:addStream("Difference", core.Bar, name .. ".Difference", "Difference", instance.parameters.color1, source:first());
	else
	Difference = instance:addInternalStream(source:first(), 0);
	end
	
	if Method== "Cumulative" then
    Cumulative = instance:addStream("Cumulative", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.color1, source:first());    
	else
	Cumulative = instance:addInternalStream(source:first(), 0);
	end
	 
end

-- Indicator calculation routine
function Update(period, mode)
    
	
	RawUp[period]= (source.high[period]- math.max(source.open[period], source.close[period]))/source:pipSize();
	RawDown[period]=- ( math.min(source.open[period], source.close[period]) -source.low[period])/source:pipSize();
	
	if  Method== "Separated Opposite Only"  then
		if source.close[period]>  source.open[period] then
		RawUp[period]=0;
		else
		RawDown[period]=0;
		end	
	end
	 
    RawDifference[period]= RawUp[period]-math.abs(RawDown[period]);
	RawCumulative[period]= RawUp[period]+math.abs(RawDown[period]);
	
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	
	if MA1.DATA:hasData(period)then
	Up[period]=MA1.DATA[period]
	Down[period]=MA2.DATA[period]
	end
	
	if MA3.DATA:hasData(period)then
	Difference[period]=MA3.DATA[period]
	end
	if MA4.DATA:hasData(period)then
	Cumulative[period]=MA4.DATA[period]
	end
end






