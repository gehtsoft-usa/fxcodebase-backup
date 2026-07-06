-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33544
-- Id: 8765

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Relative Strength");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);

	
	indicator.parameters:addString("INSTRUMENT", "Contra Currency Pair", "", "EUR/USD");	
    indicator.parameters:setFlag("INSTRUMENT" , core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("EMA_color", "Line Color", "", core.rgb(255, 0, 0));
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
    local INSTRUMENT;	
	local RS;

-- Streams block

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period+1;
	INSTRUMENT = instance.parameters.INSTRUMENT;

    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
     
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(INSTRUMENT) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        SourceData = core.host:execute("getSyncHistory", INSTRUMENT, source:barSize(), source:isBid(), Period, 100, 101);
        loading=true;
        RS = instance:addStream("RS", core.Line, name, "RS", instance.parameters.EMA_color, first);
    RS:setPrecision(math.max(2, instance.source:getPrecision()));
		RS:setWidth(instance.parameters.width);
        RS:setStyle(instance.parameters.style);
    end
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
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
function Update(period )


       if  loading or period < first  then return; end
      
		local p1 =  Initialization(period-Period) 
	    local p2 =  Initialization(period) 


       if not p1 or not p2
		
		or INSTRUMENT == source:instrument()
		then
		RS[period] =0;
		return;
		end
		

  
       
		
     
		
	   local A1=source.close[period-Period];
	   local A2=source.close[period];
	   local B1=SourceData.close[p1];
	   local B2=SourceData.close[p2];
	  
     
	 
	  
        RS[period] =((A2/B2)-(A1/B1))/(A1/B1);
		 
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
	return 0;
end


