-- Id: 6904
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20668

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pivot Width Histogram");
    indicator:description("Pivot Width Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time Frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);

    indicator.parameters:addString("CalcMode", "Select Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PWH_color", "Color of PWH", "Color of PWH", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false; 
	local CalcMode;
	local first;
	local source = nil;

-- Streams block
    local PWH = nil;
    local P;
-- Routine
function Prepare(nameOnly)
    
	source = instance.source;
    first = source:first();
	CalcMode = instance.parameters.CalcMode;
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = instance.parameters.BS;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BS).. ", " .. tostring(CalcMode) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        SourceData = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), 0, 100, 101);
        loading=true;
        P= instance:addInternalStream(0, 0);	
        PWH = instance:addStream("PWH", core.Bar, name, "PWH", instance.parameters.PWH_color, first);
    PWH:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

       local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
		   if CalcMode == "Pivot" or CalcMode == "Fibonacci" or CalcMode == "Floor" then
				P[p] = (SourceData.high[p] + SourceData.close[p] + SourceData.low[p]) / 3;
			elseif CalcMode == "Camarilla" then			
				P[p] = SourceData.close[p];
			elseif CalcMode ==  "FibonacciR" then
				P[p] = (SourceData.high[p] + SourceData.low[p]) / 2;
			elseif CalcMode == "Woodie" then				
				P[p] = (SourceData.high[p] + SourceData.low[p] + SourceData.open[p] * 2 ) / 4;
			end

		 if p > SourceData.close:first()+2   then
		PWH[period] =((P[p]-P[p-2])/P[p-1] )*100;
		end  
     
   
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


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


