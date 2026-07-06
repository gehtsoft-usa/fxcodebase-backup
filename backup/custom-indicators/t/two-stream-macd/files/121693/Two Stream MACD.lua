-- Id: 22498
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66848

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
    indicator:name("Two Stream MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
	
	indicator.parameters:addString("Instrument", "Base Instrument", "", "EUR"); 
	local Instrument={"USD", "EUR", "JPY", "CHF", "GBP", "AUD"};
	for i=1, 6,1  do
    indicator.parameters:addStringAlternative("Instrument", Instrument[i], Instrument[i] , Instrument[i]);
    end
	
	
	indicator.parameters:addString("Instrument1", "1. Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument1", core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addString("Instrument2", "2. Instrument", "", "EUR/JPY");
    indicator.parameters:setFlag("Instrument2", core.FLAG_INSTRUMENTS);
	
    indicator.parameters:addInteger("Period1", "Short Period", "Period", 12);
    indicator.parameters:addInteger("Period2", "Long Period", "Period", 26);
	indicator.parameters:addInteger("Period3", "Signal Period", "Period", 9);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color3", "Histogram Bar Color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
 
	local dayoffset;
	local weekoffset;
	local Source={}; 
	local loading={};   
	local Indicator={};
	
	
	local Instrument, Instrument1, Instrument2;
	
	local sample = "(%a%a%a)/(%a%a%a)"
	
	local Switch={};
-- Streams block
    local MACD = nil;
    local Signal = nil;
	local Histogram = nil;
-- Routine

local FirstDataPoint=nil;
function Prepare(nameOnly)   


   Instrument= instance.parameters.Instrument;
   Instrument1= instance.parameters.Instrument1;
   Instrument2= instance.parameters.Instrument2;
 
    local name = profile:id() .. "(" ..  instance.source:name().. ", " ..  Instrument .. ", " ..  Instrument1.. ", " ..  Instrument2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	FirstDataPoint=nil;
	
	
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	
	
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
   
	
	local  First, Second = string.match(Instrument1, sample);
	
	if First ==  Instrument then  
	Switch[1]= true;
	elseif Second == Instrument then 
    Switch[1]= false;
    else
	error(Instrument.. "should be included in first instrument"   );    
    end
	 
    
	local  First, Second = string.match(Instrument2, sample);
	
	if First ==  Instrument then  
	Switch[2]= true;
	elseif Second == Instrument then 
    Switch[2]= false;	
	else
	error(Instrument.. "should be included in second instrument"   );    
    end
	
	
	Source[1] = core.host:execute("getSyncHistory",   Instrument1, source:barSize(), source:isBid(), math.max(300,math.max(Period1,Period2)+Period3), 100, 101);
	loading[1]=true;
	
	Source[2] = core.host:execute("getSyncHistory" , Instrument2, source:barSize(), source:isBid(), math.max(300,math.max(Period1,Period2)+Period3), 200, 201);
	loading[2]=true;
 

     
	    Indicator[1] = core.indicators:create("EMA", Source[1].close, Period1);
		Indicator[2] = core.indicators:create("EMA", Source[2].close, Period2);

        MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, source:first());
		MACD:setWidth(instance.parameters.width1);
        MACD:setStyle(instance.parameters.style1);
		
		Indicator[3] = core.indicators:create("MVA", MACD, Period3);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, source:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, source:first());
		
		MACD:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
   
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        
	    if period == first then
		FirstDataPoint=nil;
		end
		
		local p1 =  Initialization(1,period);
        local p2 =  Initialization(2,period) 		
     
	    if not p1
		or not p2
		then
		return;
		end
		
	
	   Indicator[1]:update(mode); 
       Indicator[2]:update(mode); 		   
    
	    if not Indicator[1].DATA:hasData(p1) 
		or  not Indicator[2].DATA:hasData(p2) 
		then
		return;
		end
		
		MACD[period]=0;
		
		if Switch[1] then
        MACD[period] =MACD[period] + Indicator[1].DATA[p1];
		else
		MACD[period] =MACD[period] - Indicator[1].DATA[p1];
		end
		
		
		if Switch[2] then
        MACD[period] =MACD[period] - Indicator[2].DATA[p2];
		else
		MACD[period] =MACD[period] + Indicator[2].DATA[p2];
		end
		
		
		if FirstDataPoint== nil then
		FirstDataPoint=MACD[period];		
		end
		
		MACD[period]= (MACD[period]-FirstDataPoint) ;
		
		
		Indicator[3]:update(mode)
		
		if  not Indicator[3].DATA:hasData(period) 
		then
		return;
		end
		
		
		Signal[period]= Indicator[3].DATA[period];
		
		Histogram[period]= MACD[period]-Signal[period];
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false; 
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	if cookie == 200 then
        loading[2] = false;
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	
	if not loading[1] and not loading[2] then
        instance:updateFrom(0);
	end	
end


