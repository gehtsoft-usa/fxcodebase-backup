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
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	
    indicator.parameters:addInteger("one", "Short Period", "Period", 20);
	indicator.parameters:addInteger("two", "Long Period", "Period", 35);
	indicator.parameters:addInteger("Period", "Signal Period", "Period", 10);
	
	indicator.parameters:addBoolean("SH", "Show Horizontal Line", "", true);
	indicator.parameters:addBoolean("SV", "Show Vertical Line", "", true);
	indicator.parameters:addBoolean("Show", "Show Show Historical", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of PMO Up", "Color of PMO", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of PMO Down", "Color of PMO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
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
local EMA;
local Period;
local SH,SV;

local Show;
local TF;
local weekoffset, dayoffset;
local loading;
local SourceData;

-- Routine
function Prepare(nameOnly)
    one = instance.parameters.one;
	two = instance.parameters.two;
	Period= instance.parameters.Period;
	SH= instance.parameters.SH;
	SV= instance.parameters.SV;
	Show= instance.parameters.Show;
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
	
	
        PMO = instance:addInternalStream(0, 0);	  	
		Signal = instance:addInternalStream(0, 0);		
		instance:ownerDrawn(true);

	 
    
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2  then
	return;
	end
	
	local ItIs=false;
	
        if not init then
            context:createPen (1	, context:convertPenStyle (instance.parameters.style), instance.parameters.width,  instance.parameters.Up_color);
			context:createPen (2    , context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down_color);
            init = true;
        end

		
		for period=    source:size()-1 ,  context:firstBar () , -1 do
		
		
			if PMO[period]> Signal[period] 
			and PMO[period-1]<= Signal[period-1]
			then
			
			ItIs=true;
			
			if SV then
			x, x1, x2 = context:positionOfBar (period);
			context:drawLine (1, x, context:top (), x, context:bottom ());
			end
			
			if SH then
			visible, y = context:pointOfPrice (source[period] );
			context:drawLine (1, x, y, context:right (), y);
			end
			
			elseif PMO[period]< Signal[period]
			and PMO[period-1]>= Signal[period-1]
			then
			
			ItIs=true;
			
			
			if SV then
			x, x1, x2 = context:positionOfBar (period);			
			context:drawLine (2, x, context:top (), x, context:bottom ());
			end
			
			if SH then
			visible, y = context:pointOfPrice (source[period] );
			context:drawLine (2, x, y, context:right (), y);
			end
			end
			
			
			if not Show and ItIs then
			break;
			end

       end		
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   if period < first or not source:hasData(period) then
	return;
	end  
	
	
 Indicator:update(mode);
	 
  if TF ~= source:barSize() then 
	 
	 local p =  Initialization(period) 
     
        if not p then
        return;
        end
		 
		
	
		
		PMO[period]= Indicator.PMO[p];
		Signal[period]= Indicator.SIGNAL[p];
		
		else
		
		 
		 
 
		
		PMO[period]= Indicator.PMO[period];
		Signal[period]= Indicator.SIGNAL[period];
		
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
