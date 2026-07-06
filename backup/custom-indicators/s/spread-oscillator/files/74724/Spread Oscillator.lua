-- Id: 9500
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=36328


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
    indicator:name("Spread Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Selection"); 	 
    indicator.parameters:addString("p1", "Second Instrumet", "", "");
    indicator.parameters:setFlag("p1", core.FLAG_INSTRUMENTS );
	indicator.parameters:addInteger("Period","Period","", 14);

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("EMA_color", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Zero Line");	
    indicator.parameters:addDouble("Zero", "Zero Level","", 0);
	 indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading = false;   
	local Indicator;
	local EMA;
-- Streams block

	
local p1, p2;
local Period;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	Period = instance.parameters.Period;
    first = source:first()+Period;
		
	p1 = instance.parameters.p1;

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(p1).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = source:barSize();
	
	SourceData[1]=core.host:execute("getSyncHistory", p1, BS, source:isBid(), 0, 100, 101);
	loading=true;
		
    
 
	   

        EMA = instance:addStream("ST", core.Line, name, "Spread Oscillator", instance.parameters.EMA_color, first);
    EMA:setPrecision(math.max(2, instance.source:getPrecision()));
		EMA:setWidth(instance.parameters.width);
        EMA:setStyle(instance.parameters.style);
		EMA:addLevel(instance.parameters.Zero, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
    if loading or SourceData[1]:size() == 0   then
        return false, false ;
    end

    
	
    if period < source:first() then
        return false ;
    end

    local r1 = core.findDate(SourceData[1], Candle, false);
	 

    -- candle is not found
    if r1 < 0   then
        return false ;
	else return r1 	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

        if period < first then
		return;
		end

        local r1,r2;
		r1  = Initialization(period) 
		r2 = Initialization(period-Period) 
		
	
	    if not r1 or not r2 then
		return;
		end		
		
		 
    
	    if  not SourceData[1].close:hasData(r1)  or not  SourceData[1].close:hasData(r2)		
		then
		return;
		end
		

	--Value1 = (( Close[period]/Close[period- Length])- Data[Period]/Data[period-Length] ))*100;
      EMA[period]=  (( source.close[period]/source.close[period- Period])-(SourceData[1].close[r1]/SourceData[1].close[r2] ))*100;
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


