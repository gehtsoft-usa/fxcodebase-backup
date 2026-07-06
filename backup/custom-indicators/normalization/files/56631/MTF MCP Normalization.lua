-- Id: 8739
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23559

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
    indicator:name("Normalization");
    indicator:description("Normalization");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	 indicator.parameters:addGroup("Calcultion");	 
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
 
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addString("CP" , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("CP" , core.FLAG_INSTRUMENTS);
	
       indicator.parameters:addInteger("Period", "Normalization Period", "Period", 50);
 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Normalization_color", "Color of Normalization", "Color of Normalization", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local TF, CP;
local first;
local source = nil;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false; 
local Price;	
-- Streams block
local Normalization = nil;
 

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
	TF = instance.parameters.TF;
	CP = instance.parameters.CP;
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	 
    source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Price)  .. ", " .. tostring(TF) .. ", " .. tostring(CP) .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	SourceData = core.host:execute("getSyncHistory", CP, TF, source:isBid(), Period, 100, 101);
	loading = true;

   
        Normalization = instance:addStream("Normalization", core.Line, name, "Normalization", instance.parameters.Normalization_color, first);
    Normalization:setPrecision(math.max(2, instance.source:getPrecision()));
		Normalization:setWidth(instance.parameters.width);
        Normalization:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	 local p1 =  Initialization(period) ;
	 local p2 =  Initialization(period-Period+1) ;
	 
	 
     
	    if not p1 or not p2	 
		then
		return;
		end
		
		
		
	  
		local min, max;
		min,max=mathex.minmax(SourceData,p2, p1);
		Normalization[period] = ((SourceData[Price][p1] - min)/ (max-min))*100; 		
	 
end


function   Initialization(period)

    if period < source:first() then
        return false;
    end

    local Candle;
    Candle = core.getcandle(TF, source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
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

