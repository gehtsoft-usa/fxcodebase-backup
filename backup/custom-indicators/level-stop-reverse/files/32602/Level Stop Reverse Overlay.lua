
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18031

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
    indicator:name("Level Stop Reverse Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
    indicator.parameters:addGroup("Selection");	
	indicator.parameters:addString("Mode", "Method", "Method" , "ATR");
	indicator.parameters:addStringAlternative("Mode", "ATR", "" , "ATR");
	indicator.parameters:addStringAlternative("Mode", "Smoothed ATR", "" , "SATR");
	indicator.parameters:addStringAlternative("Mode", "PIP", "" , "PIP");
	
    indicator.parameters:addGroup("ATR");	
	indicator.parameters:addDouble("AP", "ATR Period", "" , 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "" , 3);
	
	indicator.parameters:addGroup("Smoothed ATR");	
	indicator.parameters:addDouble("MP", "Smoothed Period", "" , 14);
	indicator.parameters:addDouble("SMultiplier", "SmoothedMultiplier", "" , 2.824);
	
	 indicator.parameters:addGroup("Pip");	
	indicator.parameters:addDouble("Pip", "Pip Distance", "" , 50);
	
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
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

 
local Mode;
local Multiplier;
local AP; 
local MP;
local Pip;
-- Streams block
local LSR = nil;
local ATR, MA;
local SMultiplier;
 


function Prepare(nameOnly)   

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Label = instance.parameters.Label;
    Pip = instance.parameters.Pip;
    Mode = instance.parameters.Mode;
	AP = instance.parameters.AP;
	MP = instance.parameters.MP;
	Multiplier = instance.parameters.Multiplier;
	SMultiplier= instance.parameters.SMultiplier;

	source = instance.source;
	first=source:first();
	
	 local name;
	if Mode == "ATR" then
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(AP).. ", " .. tostring(Multiplier).. ")";
	elseif Mode == "SATR" then
  	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(AP).. ", " .. tostring(MP).. ", " .. tostring(SMultiplier).. ")";
	else
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(Pip).. ")";
	end
	
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if  Mode == "ATR" or  Mode == "SATR" then 
	ATR = core.indicators:create( "ATR", source,  AP);
	first = math.max(first, ATR.DATA:first())
	end
	
	if Mode == "SATR" then
	MA = core.indicators:create( "EMA", ATR.DATA,  MP);
	first = math.max(first, MA.DATA:first())
	end
 
     LSR =  instance:addInternalStream(0, 0);
 
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
	
 if  Mode == "ATR" or  Mode == "SATR" then 
	ATR:update(mode);
	end
	
	if Mode == "SATR" then
	MA:update(mode);
	end
	
	if period < first then
	return;
	end

	
	local Delta;
	
	if Mode == "ATR" then 
	Delta= ATR.DATA[period] * Multiplier;
	elseif Mode == "SATR" then
	Delta= MA.DATA[period] * SMultiplier;
	else
	Delta= Pip * source:pipSize();
	end
	
	 LSR[period] =  LSR[period-1];
	
	if period == first then
		if source.close[period] > source.close[period] then
		LSR[period] = source.close[period]- Delta;
		else
		LSR[period] = source.close[period]+ Delta;
		end
	end	
	
        if source.close[period-1] <= LSR[period-1]  and  source.close[period] < LSR[period-1] then
		LSR[period] = math.min(source.close[period]+ Delta, LSR[period-1] );
		elseif source.close[period-1] >= LSR[period-1] and  source.close[period] >LSR[period-1] then
		LSR[period] = math.max(source.close[period]- Delta, LSR[period-1]);
		else
		
				  if  source.close[period] > LSR[period-1] then
				  LSR[period]=source.close[period]- Delta;
				  else 
				   LSR[period]=source.close[period]+ Delta;
				  end
                
		
		end
 		
		
		 
		
		 if source.close[period] > LSR[period]     then		
		open:setColor(period,  Up);
        elseif source.close[period] < LSR[period]     then	
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
		
		
				

		
 end


