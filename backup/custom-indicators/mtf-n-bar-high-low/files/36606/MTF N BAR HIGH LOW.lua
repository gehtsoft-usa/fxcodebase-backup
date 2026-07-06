-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20899

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF N BAR HIGH LOW");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "Period", "Period", 0, 0, 1000);
	indicator.parameters:addString("BS", "Time Frame", "", "D1");
	indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	-- Streams block
    local Top = nil;
	 local Bottom = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
   
   
     local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(BS) .. ")";
    instance:name(name);
     if   (nameOnly) then
        return;
    end
	    
		
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = instance.parameters.BS;
	SourceData = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), Period, 100, 101);
	
	
  

        Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color, first);
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color, first);
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
   
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

        if period < source:size()-1 then
		return;
		end

        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	local max, min;
	
    if SourceData:first() > p - Period then
	return
	end
	
	min,max = mathex.minmax (SourceData, p-Period, p)	   
    
	core.drawLine(Top, core.range(first, source:size()-1), max, first, max, source:size()-1, color);
	core.drawLine(Bottom, core.range(first, source:size()-1), min, first, min, source:size()-1, color);
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


