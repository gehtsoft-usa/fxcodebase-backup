-- Id: 22190
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61209


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
    indicator:name("Non-standard Timeframe Price Momentum Oscillator");
    indicator:description("Non-standard Timeframe Price Momentum Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	
    indicator.parameters:addInteger("one", "Short Period", "Period", 20);
	indicator.parameters:addInteger("two", "Long Period", "Period", 35);
	indicator.parameters:addInteger("Period", "Signal Period", "Period", 10);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PMO_color", "Color of PMO", "Color of PMO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local one, two;

local first;
local source = nil;
 
-- Streams block
local PMO = nil;
local Signal;
local Indicator;
local Period;

local TF;
local weekoffset, dayoffset;
local loading;
local SourceData;
-- Routine
function Prepare(nameOnly)
    one = instance.parameters.one;
	two = instance.parameters.two;
	Period= instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(one) .. ", " .. tostring(two) .. ", " .. tostring(Period).. ")";
    instance:name(name);

 
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("PMO") ~= nil, "Please, download and install PMO.LUA indicator");
	
	
	TF= instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	

    local precision = math.max(2, source:getPrecision());

	if TF ~= "Chart"then
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	end
	
	if TF ~= source:barSize() then 
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true; 
	
	Indicator = core.indicators:create("PMO", SourceData.close, one, two, Period);
	else	 
	Indicator = core.indicators:create("PMO", source, one, two, Period);
	end
	
	
	
	
        PMO = instance:addStream("PMO", core.Line, name, "PMO", instance.parameters.PMO_color, first);
		PMO:setWidth(instance.parameters.width1);
        PMO:setStyle(instance.parameters.style1);
		
		
		
		Signal = instance:addStream("SIGNAL", core.Line, name, "Signal", instance.parameters.Signal_color, first);
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		PMO:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   if period < first or not source:hasData(period) then
	return;
	end  
	
	
	
	 
	 local p =  Initialization(period) 
     
        if not p then
        return;
        end
		 
		
		Indicator:update(mode);
		
		PMO[period]= Indicator.PMO[p];
		Signal[period]= Indicator.SIGNAL[p];
		 
    
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

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
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

 