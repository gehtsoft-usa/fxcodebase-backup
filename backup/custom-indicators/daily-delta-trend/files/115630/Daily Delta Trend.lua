-- Id: 19638

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65208

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
    indicator:name("Daily Delta Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period11", "1. Stage 1. MA Period", "MA Period", 50);
	indicator.parameters:addInteger("Period12", "1. Stage 2. MA Period", "MA Period", 200);
	
	indicator.parameters:addInteger("Period21", "2. Stage 1. MA Period", "MA Period", 50);
	indicator.parameters:addInteger("Period22", "2. Stage 2. MA Period", "MA Period", 200);
	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "2. Bar Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period11, Period12, Period21, Period22;
	local first;
	local source = nil;
	local TF; 
	local dayoffset;
	local weekoffset;
	local SourceData;
	local loading = false;   
    local Delta;
-- Streams block
    local MA11,MA12,MA21,MA22 = nil;

-- Routine
function Prepare(nameOnly)
    Period11= instance.parameters.Period11;
	Period12= instance.parameters.Period12;
	Period21= instance.parameters.Period21;
	Period22= instance.parameters.Period22;
    source = instance.source;
    first = source:first();	
	
	local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	assert(core.indicators:findIndicator("DELTA") ~= nil, "Please, download and install DELTA.LUA indicator");   

	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300, math.max(Period11,Period12)+math.max(Period21,Period22)), 100, 101);
	loading=true;
	


 
	    Delta = core.indicators:create("DELTA", SourceData);
		
		MA11 = core.indicators:create("MVA", Delta.DATA, Period21);
		MA12 = core.indicators:create("MVA", Delta.DATA, Period22);
		
		MA21 = core.indicators:create("MVA", MA11.DATA, Period21);
		MA22 = core.indicators:create("MVA", MA21.DATA, Period22);

        MA1 = instance:addStream("MA1", core.Bar, name, "1. MA", instance.parameters.color1, source:first());
        MA2 = instance:addStream("MA2", core.Line, name, "2. MA", instance.parameters.color2, source:first());
		
		MA1:setPrecision(math.max(2, instance.source:getPrecision()));
	    MA2:setPrecision(math.max(2, instance.source:getPrecision()));
		
		MA1:addLevel(0);
 
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	   Delta:update(mode);
	   MA11:update(mode); 
       MA12:update(mode); 	
       MA21:update(mode); 
       MA22:update(mode); 		  	   
    
	    if MA21.DATA:hasData(p) then
        MA1[period] =MA21.DATA[p];
		end
		
		  if MA22.DATA:hasData(p) then
        MA2[period] =MA22.DATA[p];
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


