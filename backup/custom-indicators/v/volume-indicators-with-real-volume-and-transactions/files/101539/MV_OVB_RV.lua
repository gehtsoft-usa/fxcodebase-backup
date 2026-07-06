-- Id: 14514

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
    indicator:name("MultiVote OBV with Real volume/Transactions");
    indicator:description("MultiVote OBV with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");

    indicator.parameters:addColor("Up", "Color of Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Color of Down", "", core.rgb(255, 0, 0));
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
local Ind;

local FirstStart;
local LastTime;

-- Streams block
local MVOBV = nil;

-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ")";
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
        MVOBV = instance:addStream("MVOBV", core.Line, name, "MVOBV", core.rgb(128, 128, 128), first);
    MVOBV:setPrecision(math.max(2, instance.source:getPrecision()));
		MVOBV:setWidth(instance.parameters.width);
        MVOBV:setStyle(instance.parameters.style);

    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
    
   local HIGHVOTE = 0;

   local LOWVOTE = 0;

   local CLOSEVOTE = 0;

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


    if source.high[period] > source.high[period-1] then
    HIGHVOTE = 1 
    elseif source.high[period] < source.high[period-1] then 
	HIGHVOTE = -1;
	end

	
	 
	if source.low[period] > source.low[period-1] then
    LOWVOTE = 1 
    elseif source.low[period] < source.low[period-1] then 
	LOWVOTE = -1;
	end

    
	
	if source.close[period] > source.close[period-1] then
    CLOSEVOTE = 1 
    elseif source.close[period] < source.close[period-1] then 
	CLOSEVOTE = -1;
	end
    
	
local TOTALVOTE = HIGHVOTE + LOWVOTE + CLOSEVOTE;



MVOBV[period] = MVOBV[period-1] + (Ind.DATA[period] * TOTALVOTE );

if MVOBV[period] > 0 then
MVOBV:setColor(period, instance.parameters.Up);
elseif  MVOBV[period] < 0 then
MVOBV:setColor(period, instance.parameters.Down);
else
MVOBV:setColor(period, core.rgb(128, 128, 128));
end

  
    
end

