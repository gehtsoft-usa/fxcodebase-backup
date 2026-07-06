-- Id: 11001
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60241

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name(" Reversal  /  Continuation Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("M1", "Fast Moving Average Period", "Period", 3);
    indicator.parameters:addInteger("M2", "Middle Moving Average Period" , "", 7);
    indicator.parameters:addInteger("M3", "Slow Moving Average Period", "", 50);
	
	indicator.parameters:addString("Method", " Moving Average Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("On1", "Fast / Middle Moving Average Filter ", "", true);
	indicator.parameters:addBoolean("On2", "Middle / Slow Moving Average Filter ", "", true);
    indicator.parameters:addBoolean("On3", "Price Filter ", "", true);
	
    indicator.parameters:addString("Type", " Price Type", "Type" , "Reversal");
    indicator.parameters:addStringAlternative("Type", "Continuation", "Continuation" , "Continuation");
    indicator.parameters:addStringAlternative("Type", "Reversal", "Reversal" , "Reversal");
    indicator.parameters:addStringAlternative("Type", "Any", "Any" , "Any");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,255));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,255));
    indicator.parameters:addInteger("Size", "Font Size","Font Size", 10);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Method, M1,M2,M3;

local Method=nil;

local m1, m2, m3;

local first;
local source = nil;

-- Streams block
--local HZU = nil;
--local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down;
local up, down,Size; 
local On={};
local Type;
-- Routine
function Prepare(nameOnly)
    M1 = instance.parameters.M1;
    M2 = instance.parameters.M2;
    M3 = instance.parameters.M3;
	Size = instance.parameters.Size;
	Method= instance.parameters.Method;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    On[1] = instance.parameters.On1;
	On[2] = instance.parameters.On2;	
	On[3] = instance.parameters.On3;
	Type = instance.parameters.Type;
	
    source = instance.source;
   
	
    local name = profile:id() .. "(" .. source:name() .. ", "  .. M1 .. ", " .. M2 .. ", " .. M3.. ", " .. Method .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    m1 = core.indicators:create(Method, source.close, M1);
    m2 = core.indicators:create(Method, source.close, M2);
	m3 = core.indicators:create(Method, source.close, M3);
    first = math.max( m1.DATA:first(), m2.DATA:first(), m3.DATA:first());	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, Up, first);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, Down, first);

end

-- Indicator calculation routine
function Update(period, mode)


    m1:update(mode);
    m2:update(mode);
	m3:update(mode);
	
	 up:setNoData(period );
     down:setNoData(period );      
	 
	 
	if 	 not On[1] and not  On[2]  then
    return;
    end	
	 
	if period < first  or not source:hasData(period) then		
    return;
    end 
	
			if (m1.DATA[period] > m2.DATA[period] or not On[1])
			and  ( m2.DATA[period] > m3.DATA[period] or not On[2])	
			then
			
		  
				 
			   if On[3] then 
			   
			      
				   if source.close[period]> source.open[period] and Type ~=  "Reversal"  then
				   up:set(period, source.high[period], "\217");				  
				   end
				   
				    if source.close[period]< source.open[period]  and Type ~= "Continuation"  then
					 down:set(period, source.low[period], "\218");
				   end
				   
			   else
				up:set(period, source.high[period], "\217");
			   end
		   end
		   
       if (m1.DATA[period] < m2.DATA[period] or not On[1])
			and  ( m2.DATA[period] < m3.DATA[period] or not On[2])
       then    
			   if On[3] then
				    if source.close[period]< source.open[period] and Type ~=  "Reversal"  then					
				    down:set(period, source.low[period], "\218");
				   end
				   
				    if source.close[period]> source.open[period]  and Type ~= "Continuation"  then
					up:set(period, source.high[period], "\217");
				   end
			   else
				 down:set(period, source.low[period], "\218")
			   end
  
       end
   
   
end

