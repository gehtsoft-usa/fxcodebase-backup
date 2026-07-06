-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59795
-- Id: 10338

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
    indicator:name("Performance Index");
    indicator:description("Performance Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "EMA Period", "EMA Period", 14);
    indicator.parameters:addString("Instrument" , "Pair", "", "USDOLLAR");
    indicator.parameters:setFlag("Instrument"  , core.FLAG_INSTRUMENTS);
	
	
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
	local host;
	local offset;
	local weekoffset;
	local Source;
	local loading = false;   
	local Indicator1,Indicator2;
-- Streams block
    local PI = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    Instrument = instance.parameters.Instrument;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Instrument) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Source = core.host:execute("getSyncHistory", Instrument, source:barSize(), source:isBid(), math.min(300, Period), 100, 101);
        loading=true;
        
        Indicator1 = core.indicators:create("MVA", source.close ,Period);   
        Indicator2 = core.indicators:create("MVA", Source.close ,Period);
        first= Indicator1.DATA:first() ; 	
        PI = instance:addStream("PI", core.Line, name, "PI", instance.parameters.color, first);
    PI:setPrecision(math.max(2, instance.source:getPrecision()));
		PI:setWidth(instance.parameters.width);
        PI:setStyle(instance.parameters.style);
		PI:addLevel(1);
		
    end
end


 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        local p =  Initialization(period) 
     
	    if not p then
		return;
		end	   
	   
	   	   
	
	   Indicator1:update(mode); 	
	   Indicator2:update(mode); 
	   
	   if not  Indicator1.DATA:hasData(period)
	   or not  Indicator2.DATA:hasData(p)
	   then
	   return;
	   end
	   
	   PI[period]= (source.close[period]/ Source.close[p]) *(Indicator2.DATA[p]/Indicator1.DATA[period] )
   -- PI = Stock Close / (Index Close) x (Index MA / Stock MA)
 
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
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


