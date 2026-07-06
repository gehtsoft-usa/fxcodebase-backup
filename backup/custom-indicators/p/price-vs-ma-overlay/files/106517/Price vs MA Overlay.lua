-- Id: 16130

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63540

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price vs MA Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
 
    indicator.parameters:addGroup("Selector");
	 indicator.parameters:addInteger("Type", "Method", "Method" , 1);
    indicator.parameters:addIntegerAlternative("Type", "Single MA", "Single MA" , 1);
    indicator.parameters:addIntegerAlternative("Type", "Both MAs", "Both MAs" , 2);

	indicator.parameters:addGroup("1. MA ");
	indicator.parameters:addInteger("Period1", "MA Method", "Method" , 25);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

	indicator.parameters:addGroup("2. MA ");
	indicator.parameters:addInteger("Period2", "MA Method", "Method" , 50);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Period1, Method1, ma1;
local Period2, Method2, ma2;

local Type;
function Prepare(nameOnly) 

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Period1 = instance.parameters.Period1;
	Method1= instance.parameters.Method1;
	
	Period2 = instance.parameters.Period2;
	Method2= instance.parameters.Method2;
	
    Type= instance.parameters.Type;

	source = instance.source;
	 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()
	..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
		ma1=core.indicators:create(Method1,  source.close, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	    ma2=core.indicators:create(Method2,  source.close, Period2); 
	
	
	first= math.max(ma1.DATA:first(), ma2.DATA:first() );

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	
 
	
			   ma1:update(mode);
			   if Type== 2 then
			   ma2:update(mode);
			   end
			    
		
        local Signal=0;

        if Type==1 then
			 if source.close[period] > ma1.DATA[period] then
			 Signal=1;
			 elseif source.close[period] < ma1.DATA[period] then
			 Signal=-1;
			 else
			 Signal=0;
			 end			 
		else
		     if source.close[period] > ma1.DATA[period] 
			 and source.close[period] > ma2.DATA[period] 
			 then
			 Signal=1;
			 elseif source.close[period] < ma1.DATA[period] 
			 and source.close[period] < ma2.DATA[period]
			 then
			 Signal=-1;
			 else
			 Signal=0;
			 end	
        end		
		
		if Signal==0  then
		open:setColor(period,Neutral);	   
		elseif Signal==1    then		
		open:setColor(period,  Up);
        elseif Signal==-1  then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
		 
		
 end


