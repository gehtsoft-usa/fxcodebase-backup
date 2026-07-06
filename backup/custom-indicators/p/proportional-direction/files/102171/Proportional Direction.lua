
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62630

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
    indicator:name("Proportional Direction");
    indicator:description("Proportional Direction");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Indicator Selection");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);
    indicator.parameters:addGroup("Calculation");		
    indicator.parameters:addString("Direction", "Direction", "Direction", "Direct");
	indicator.parameters:addStringAlternative("Direction", "Direct", "Direct" , "Direct");
	indicator.parameters:addStringAlternative("Direction", "Reverse Indicator", "ReverseIndicator" , "ReverseIndicator");
	indicator.parameters:addStringAlternative("Direction", "Reverse Price", "ReversePrice" , "ReversePrice");
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 15);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Direction;

local first;
local source = nil;
local Number;
-- Streams block
local Up,Down;
local up, down;
local Indicator;
local INDEX;
local Size;
-- Routine
function Prepare(nameOnly)
    Direction = instance.parameters.Direction; 
	Number = instance.parameters.Number-1;
	Size = instance.parameters.Size;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Direction) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		local iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local iparams = instance.parameters:getCustomParameters("INDICATOR");

		if  iprofile:requiredSource() == core.Tick then			
			Indicator = iprofile:createInstance( source.close, iparams);
		else
			Indicator = iprofile:createInstance(source, iparams);
		end
	
	 Count= Indicator:getStreamCount ();
	 
	 if Number >= Count then
	 Number = Count;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count  .. " stream(s).");
	 end	 
	 
	INDEX=  Indicator:getStream (Number);	
	 
    first = math.max(source:first(), INDEX:first()) ;	
	 			
 

    
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, Down, 0);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    Indicator:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	up:setNoData(period);
	down:setNoData(period);
	
	if Direction == "Direct" then
		if source.close[period]>source.open[period] 
        and INDEX[period]> INDEX[period-1]		
		then
		up:set(period , source.low[period], "\217");	 
		elseif source.close[period]<source.open[period]
		and INDEX[period]< INDEX[period-1]	
		then
		down:set(period , source.high[period], "\218");
		end
	elseif Direction == "ReverseIndicator" then
	 
	    if source.close[period]<source.open[period] 
        and INDEX[period]> INDEX[period-1]				
		then
		up:set(period , source.low[period], "\217");			
		elseif source.close[period]>source.open[period]
		and INDEX[period]<INDEX[period-1]		
		then
		down:set(period , source.high[period], "\218");
		end
	
	elseif Direction == "ReversePrice" then
	 
	     if source.close[period]>source.open[period] 
        and INDEX[period]< INDEX[period-1]				
		then
		up:set(period , source.low[period], "\217");			
		elseif source.close[period]<source.open[period]
		and INDEX[period]>INDEX[period-1]		
		then
		down:set(period , source.high[period], "\218");
		end
		
	end
     
end

