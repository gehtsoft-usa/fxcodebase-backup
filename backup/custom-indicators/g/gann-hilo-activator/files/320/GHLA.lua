
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=227

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
function Init()
    indicator:name("Gann High Low Activator");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
    
    indicator.parameters:addInteger("N", "Number of Periods", "", 10);
	
	indicator.parameters:addGroup("Style");    
	indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("GHLA_Up", "Color of the Line Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("GHLA_Down", "Color of the Line Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local N;
local first;
local source = nil;

-- Streams block
local GHLA = nil;	-- indicator result
local pdir = nil;	-- the previous direction

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    first = source:first() + N;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    GHLA = instance:addStream("GHLA", core.Line, name, "GHLA", instance.parameters.GHLA_Up, first);
	GHLA:setWidth(instance.parameters.width);
	GHLA:setStyle(instance.parameters.style);
    pdir = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period)
    pdir[period] = 0;
	
    if period < first or not  source:hasData(period) then
	return;
	end 
       
    local switch = 0;
		
	local AvgHigh= mathex.avg(source.high, period-N+1, period);  	
	local AvgLow= mathex.avg(source.low, period-N+1, period);  
    
	-- change direction in case the current close is above average high
        -- or below average low
        if source.close[period] > AvgHigh then
            switch = 1;
        elseif source.close[period] < AvgLow then
            switch = -1;
        end        
				
        if (switch ~= 0) then
	    -- remember the direction in case we have to switch
            pdir[period] = switch;
        else
	    -- or use the previous direction             
			pdir[period]=pdir[period - 1];
        end
		
        -- and get average of the last N high or low values depending on the direction
        
        if (pdir[period] == -1) then
            GHLA[period] = AvgHigh;
        else
            GHLA[period] = AvgLow;
        end
		
		if pdir[period] == 1 then
	   GHLA:setColor(period, instance.parameters.GHLA_Up);
	   else
	    GHLA:setColor(period, instance.parameters.GHLA_Down);
	   end
	   
	   
	if pdir[period]~=pdir[period-1] then
	GHLA:setBreak (period, true); 
    else	 
	GHLA:setBreak (period, false);
	end  
     
end

