-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63494

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
    indicator:name("RLW Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
    indicator.parameters:addDouble("OB", "OB Level", "", -20);
	indicator.parameters:addDouble("OS", "OS Level", "", -80);

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("OBUp", "OB Up color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("OBDown", "OB Down color", "", core.rgb(0, 0, 200));
	
	
	indicator.parameters:addColor("OSUp", "OS Up color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("OSDown", "OS Down color", "", core.rgb(100, 100, 100));
	
	
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local OBUp,OBDown;
local OSUp,OSDown;
local OB,OS;
local first;
local source = nil;
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Period;
local RLW;

function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
	OBUp = instance.parameters.OBUp;
    OBDown= instance.parameters.OBDown;
	OSUp = instance.parameters.OSUp;
    OSDown= instance.parameters.OSDown;
   
    Period = instance.parameters.Period;
 
	source = instance.source;
	
	
	
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", "..Period 	..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
		RLW=core.indicators:create("RLW",  source, Period);

    
	
	
	first=RLW.DATA:first()+1 ;

    	
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
	
	RLW:update(mode);
	        if period < first  then
			open:setColor(period, Neutral);	
			return;
			end
	
   
		if RLW.DATA[period]> OB then
		   if RLW.DATA[period] > RLW.DATA[period-1] then
			open:setColor(period,  OBUp);
			else
			open:setColor(period,  OBDown);	
			end		
		elseif RLW.DATA[period]< OS then
		   if RLW.DATA[period] > RLW.DATA[period-1] then
			open:setColor(period,  OSUp);
			else
			open:setColor(period,  OSDown);	
			end		
        else 
			if RLW.DATA[period] > RLW.DATA[period-1] then
			open:setColor(period,  Up);
			else
			open:setColor(period,  Down);	
			end		
		end
		
		
				

		
 end


