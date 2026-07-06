-- Id: 24707
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68344

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
-- Indicator profile initialization routine
 
function Init()
    indicator:name("High Low River");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
		indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 2000);
 
	
	indicator.parameters:addString("Method1", "Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Price Smoothing Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 5, 1, 2000);
 
	
	indicator.parameters:addString("Method2", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Offset Calculation"); 
	
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	indicator.parameters:addString("Method", "Method", "Method" , "ATR");
    indicator.parameters:addStringAlternative("Method", "ATR", "ATR" , "ATR");
    indicator.parameters:addStringAlternative("Method", "Standard Deviation", "Standard Deviation" , "Standard Deviation");
	
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0 );
	
	indicator.parameters:addGroup("Offset Smoothing Calculation"); 
    indicator.parameters:addInteger("Period3", "Period", "", 5, 1, 2000); 
	
	indicator.parameters:addString("Method3", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , false); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up,Down, Neutral;

local first;
local source = nil;

local Method1, Period1;
local Method2, Period2;   
local Method3, Period3;  
local High,Low;
local MA_High,MA_Low;
local Offset,MA_Offset;
 
local Lines;
local Transparency;

local Top=nil;
local Bottom=nil;

local Signal;

local Multiplier,Offset_Type;
local Period, Method,ATR;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   
   Lines= instance.parameters.Lines;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
			
	Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2; 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3; 
	
	Period= instance.parameters.Period;
    Method= instance.parameters.Method; 
	
	Multiplier= instance.parameters.Multiplier;
	Offset_Type= instance.parameters.Offset_Type;
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    High = core.indicators:create(Method1, source.high, Period1);
    Low = core.indicators:create(Method1, source.low, Period1);
	
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA_High = core.indicators:create(Method2, High.DATA, Period2);
    MA_Low = core.indicators:create(Method2, Low.DATA, Period2);
	
	ATR = core.indicators:create("ATR", source, Period);
    
    first=math.max(MA_High.DATA:first(),ATR.DATA:first())
	
	Offset  = instance:addInternalStream(0, 0); 
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
    MA_Offset = core.indicators:create(Method3, Offset, Period3);
 
	Signal = instance:addInternalStream(0, 0); 
	
	
	 if Lines then
   
   Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first);
   Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);
   else
   Top=instance:addInternalStream(first, 0);     
   Bottom=instance:addInternalStream(first, 0);
   end
	
	
	instance:createChannelGroup("Group","Group" , Top, Bottom, Neutral, Transparency);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
      
   High:update(mode);
   Low:update(mode);
   MA_High:update(mode);
   MA_Low:update(mode);
   ATR:update(mode);
   MA_Offset:update(mode);
	
	if period < first then
	return;
	end
	
	
	if Method== "ATR" then
	Offset[period]= ATR.DATA[period];
	else
	Offset[period]= mathex.stdev(source.close, period-Period+1, period);
	end
		
 
	
	Top[period] = MA_High.DATA[period] + math.abs(MA_Offset.DATA[period])*Multiplier;
	Bottom[period] = MA_Low.DATA[period]- math.abs(MA_Offset.DATA[period])*Multiplier; 
	
	if source.close[period]< Bottom[period] then
	Signal[period]=-1;
	elseif source.close[period]> Top[period] then
	Signal[period]=1;
	else
	Signal[period]=Signal[period-1];
	end
	
      
				if Signal[period] > 0 then 
				Top:setColor(period, Up);
				elseif  Signal[period] < 0 then
				Top:setColor(period, Down);	
				else
				Top:setColor(period, Neutral);
				end
		
				  
end

