
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
    indicator:name("Volume Adjusted Moving Average with Real volume/Transactions");
    indicator:description("Volume Adjusted Moving Average with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
	
	indicator.parameters:addGroup("VAMA Parameters");
	indicator.parameters:addInteger("Frame","Period", "", 8, 2, 2000);
	
	indicator.parameters:addGroup("Price Type");
	indicator.parameters:addString("Type", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type", "WEIGHTED", "", "W");
   
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("VAMA_color", "Color of VAMA", "Color of VAMA", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

local first;
local source = nil;
local PriceTimesVolume;
local VAMA = nil;
local Frame;

local Type;
local p;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Type=instance.parameters.Type;
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 if Type == "O" then
        p = source.open;
    elseif Type == "H" then
        p = source.high;
    elseif Type == "L" then
        p = source.low;
    elseif Type == "M" then
        p = source.median;
    elseif Type == "T" then
        p = source.typical;
    elseif Type == "W" then
        p = source.weighted;
    else
        p = source.close;
    end

     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
	
	PriceTimesVolume = instance:addInternalStream(first,0);

    
	
	
    VAMA = instance:addStream("VAMA", core.Line, name, "VAMA", instance.parameters.VAMA_color, first);
	VAMA:setWidth(instance.parameters.width);
    VAMA:setStyle(instance.parameters.style);
	
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
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

	     	PriceTimesVolume[period]=p[period] *Ind.DATA[period];
	   
	    if period > Frame then
				VAMA[period] = core.sum(PriceTimesVolume,core.range(period-Frame,period))/core.sum(Ind.DATA,core.range(period-Frame, period));	
		end
		
    end
	
end