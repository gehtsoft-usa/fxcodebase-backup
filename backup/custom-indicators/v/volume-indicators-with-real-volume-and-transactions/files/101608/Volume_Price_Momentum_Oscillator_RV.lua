-- Id: 14602

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
    indicator:name("Volume Price Momentum Oscillator with Real volume/Transactions");
    indicator:description("Volume  Price Momentum Oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "Period", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VPMO_color", "Color of VPMO", "Color of VPMO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
 
local source = nil;
local EMA;
-- Streams block
local VPMO = nil;
local vpmo;
local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
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

   
	
    vpmo  = instance:addInternalStream(0, 0);
	
	assert( source:supportsVolume () , "The source that includes data volume is required.");
	
	
	EMA = core.indicators:create("EMA", vpmo, Period);
	
    if (not (nameOnly)) then
        VPMO = instance:addStream("VPMO", core.Line, name, "VPMO", instance.parameters.VPMO_color, EMA.DATA:first());
    VPMO:setPrecision(math.max(2, instance.source:getPrecision()));
		VPMO:setWidth(instance.parameters.width);
        VPMO:setStyle(instance.parameters.style);
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < EMA.DATA:first() or not source:hasData(period) then
	return;
	end
         Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==EMA.DATA:first() then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(EMA.DATA:first());    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end

	vpmo[period]=Ind.DATA[period]*(source.close[period]-source.close[period-1]);
	EMA:update(mode);
	
	VPMO[period] = EMA.DATA[period];
    
end

