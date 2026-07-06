-- Id: 14547

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Range / Volume Ratio with Real volume/Transactions");
    indicator:description("Range / Volume Ratio with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addString("Method", "Calculation Method", "Method" , "Open/Close");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "Open/Close", "Open/Close" , "Open/Close");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Ratio_color", "Color of Ratio", "Color of Ratio", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;

local first;
local source = nil;

local Ind;

local FirstStart;
local LastTime;

-- Streams block
local Ratio = nil;

-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;

    if (not (nameOnly)) then
        Ratio = instance:addStream("Ratio", core.Bar, name, "Ratio", instance.parameters.Ratio_color, first);
    Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    
    if period < first or not source:hasData(period) then
	return;
	end
	
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end

	if Method == "High/Low" then
	 Ratio[period]=(source.high[period]-source.low[period])/Ind.DATA[period];
	else
	Ratio[period]=math.abs(source.open[period]-source.close[period])/Ind.DATA[period];
	end
	
      
    
end

