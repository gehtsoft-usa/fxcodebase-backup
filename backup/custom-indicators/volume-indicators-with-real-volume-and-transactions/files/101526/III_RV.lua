-- Id: 14497

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
    indicator:name("Intraday Intensity Index with Real volume/Transactions");
    indicator:description("Intraday Intensity Index with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "", 21);
	indicator.parameters:addBoolean("Normalized"  , "Use Normalization", "", true);	
	
	indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("III_color", "Color of III", "Color of III", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
  
local first;
local source = nil;
local Period;
local Normalized;
-- Streams block
local III = nil;
local Raw;
local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Normalized = instance.parameters.Normalized;
    source = instance.source;
    first = source:first()+Period;
	
	 Raw = instance:addInternalStream(0, 0);
	 assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period  .. ")";
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
        III = instance:addStream("III", core.Line, name, "III", instance.parameters.III_color, first);
    III:setPrecision(math.max(2, instance.source:getPrecision()));
		III:setWidth(instance.parameters.width);
        III:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   if period < first   then
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
    Raw[period] =  ((2*source.close[period]-source.high[period]-source.low[period])/(source.high[period]-source.low[period]))*Ind.DATA[period];
   
 	if  Normalized then	 
	III[period]= (mathex.sum(Raw, period-Period+1, period)/ mathex.sum(Ind.DATA, period-Period+1, period))*100 ;
	else	
	III[period]= mathex.sum(Raw, period-Period+1, period);
	end
        
    
end

function AsyncOperationFinished(cookie, success, message)

end

