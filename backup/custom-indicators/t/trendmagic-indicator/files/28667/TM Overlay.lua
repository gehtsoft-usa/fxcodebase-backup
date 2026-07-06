-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=563&start=10

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
function Init()
    indicator:name("Trend Magic Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CP", "CCI Periods", "", 50);
	 indicator.parameters:addDouble("AP", "ATR Period", "", 5);
    indicator.parameters:addDouble("AM", "ATR Multiplier", "", 1);
	 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local AP, CP, AM;

local first;
local source = nil;
local ATR = nil;
local CCI;

-- Streams block
local OUT = nil;
local UP = nil;
local DN = nil;
local TR = nil;

local Up,Down, Neutral; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    AP = instance.parameters.AP;
	AM = instance.parameters.AM;
	
	Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;	
	
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. CP .. ", " .. AP .. ", " .. AM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, AP);
	CCI = core.indicators:create("CCI", source, CP);
    first = math.max( ATR.DATA:first(),CCI.DATA:first()) ;
	
    UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
    TR = instance:addInternalStream(first, 0);
    OUT = instance:addInternalStream(first, 0);	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);	
	CCI:update(mode);
	
	open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
           
   
     if CCI.DATA[period] > 0 then
	 TR[period]= 1;
	 OUT[period] = math.max( (source.low[period] - ATR.DATA[period]*AM),  OUT[period-1]);
	 elseif CCI.DATA[period] < 0 then
	  TR[period]= -1;
	  OUT[period] = math.min( (source.high[period] + ATR.DATA[period]*AM),  OUT[period-1]);
	 end
	    
		if  TR[period] == 1  then
	    open:setColor(period,  Up);
        elseif TR[period] == -1   then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
   	
     
  end
 
