-- Id: 9185
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=38110

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
    indicator:name("Average Period Range");
    indicator:description("Average Period Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF", "Period Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
	
	indicator.parameters:addString("Method", "Range Method", "Method" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "Open/Close", "Open/Close" , "Open/Close");
	
	indicator.parameters:addString("Type", "Absolute/Relativ", "Method" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Absolute", "Absolute" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "Relativ" , "Relativ");
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("APR_color", "Color of APR", "Color of APR", core.rgb(255, 0, 0));
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
local loading;
local first;
local source;
local TF;
-- Streams block
local APR;
local SourceData;
local offset,weekoffset;
local Method;
local Type;
-- Routine
function Prepare(nameOnly)   
 
   

   
	
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	Type = instance.parameters.Type;
	TF = instance.parameters.TF;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(TF).. ", " .. tostring(Period).. ", " .. tostring(Method).. ", " .. tostring(Type) .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), Period, 100, 101);
	loading= true;
	
	
	local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
	 
	  
    first = source:first();

   

    
        APR = instance:addStream("APR", core.Line, name, "APR", instance.parameters.APR_color, first);
    APR:setPrecision(math.max(2, instance.source:getPrecision()));
		APR:setWidth(instance.parameters.width);
        APR:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	  local p =  Initialization(period);
	       
	    if not p then
		return;
		end
		
		local Sum=0;
		local i;
	    for i = p-Period+1, p, 1 do
			if Method == "High/Low" then
			Sum=Sum+(SourceData.high[i] -SourceData.low[i]);
			elseif Method == "Open/Close" then
			Sum=Sum+math.abs(SourceData.open[i] -SourceData.close[i]);
			end
        end		
	    if Type == "Absolute" then
        APR[period] = Sum/Period;
		else
		APR[period] = (Sum/Period) / (  SourceData.open[p]/100);
		end
		
     
end

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
    Candle = core.getcandle(TF, source:date(period), offset, weekoffset);

  
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


