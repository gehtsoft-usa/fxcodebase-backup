-- Id: 14438
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62294


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
    indicator:name("InvestorsVsSpeculators Delta");
    indicator:description("InvestorsVsSpeculators Delta");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addString("Method", "Calculation Method","", "CS");
    indicator.parameters:addStringAlternative("Method", "Classic", "", "CS");
    indicator.parameters:addStringAlternative("Method", "TradeStation", "", "TS");
  
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color_Up", "Color of Up", "Color of Bar", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color_Down", "Color of Down", "Color of Bar", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;
local Type;
-- Streams block
local Investors = nil;
local Speculators = nil;
local o, h, l, c, v;
-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
	if instance.parameters.Method == "CS" then
        Method = 1;
    elseif instance.parameters.Method == "TS" then
        Method = 2;
    end
	
	Type=instance.parameters.Type;
		
    source = instance.source;
    first = source:first();
	
	
	o = source.open;
    h = source.high;
    l = source.low;
    c = source.close;
    v = source.volume;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ")";
    instance:name(name);
  
  
    if   (nameOnly) then
        return;
    end
 
		
		 
			Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.color_Up, first+Period); 
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
		    Speculators = instance:addInternalStream(first, 0);
	        Investors = instance:addInternalStream(first, 0);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
   
	if period < first or not source:hasData(period) then
	return;
	end
	
	local AD=0;
	
	     if Method == 1  then
            -- classic
            if h[period] - l[period] == 0 then
                AD = 0;
            else
                AD = ((c[period] - l[period]) - (h[period] - c[period])) / (h[period] - l[period]) * v[period];
            end
        else
            
            if h[period] - l[period] == 0 then
                AD = 0;
            else
                AD = (c[period] - o[period]) / (h[period] - l[period]) * v[period];
            end
        end

		if period < Period then
		return;
		end
		
		if  v[period]> mathex.avg(v, period-Period+1, period) then
		Speculators[period]= Speculators[period-1];
		Investors[period]=Investors[period-1]+AD;
		else
		Investors[period]= Investors[period-1];
		Speculators[period]=Speculators[period-1]+AD;
		end
       
       Delta[period]= Investors[period]-Speculators[period];
	   
	   if Delta[period]>0 then
	   Delta:setColor(period, instance.parameters.color_Up);
	   else
	   Delta:setColor(period, instance.parameters.color_Down);
	   end
end

