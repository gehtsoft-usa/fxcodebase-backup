-- Id: 14556

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
    indicator:name("Smart money pressure with Real volume/Transactions");
    indicator:description("Smart money pressure with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addInteger("LookBack", "Look Back", "Look Back", 300);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SMP_color", "Color of SMP", "Color of SMP", core.rgb(255, 0, 0));
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
local LookBack;

local first;
local source = nil;

-- Streams block
local SMP = nil;
 local iSMP;
local MA,SM;

local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    LookBack = instance.parameters.LookBack;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(LookBack) .. ")";
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
	MA= core.indicators:create("MVA", Ind.DATA, Period);
	first = MA.DATA:first()+LookBack;
	
	 
	SM  = instance:addInternalStream(0, 0);
    iSMP  = instance:addInternalStream(0, 0);
    if (not (nameOnly)) then
        SMP = instance:addStream("SMP", core.Line, name, "SMP", instance.parameters.SMP_color, first);
    SMP:setPrecision(math.max(2, instance.source:getPrecision()));
		SMP:setWidth(instance.parameters.width);
        SMP:setStyle(instance.parameters.style);
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

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

     
    MA:update(mode); 
	
    if period < source:size()-1 then
    return;
    end
  	
	SM[period]=0;
	SMP[period]=0;
	
	local Start;
	if LookBack== 0 then
	Start=first;
	else
	Start=math.max(source:size()-1-LookBack, first)
	end
	
	for period=Start, source:size()-1 ,1 do
	 
	     if period == Start then
		 SM[period-1]=source.close[period];
		 end
		 
	
		    Change=source.close[period]-source.close[period-1]; 
		 
			 if Ind.DATA[period]> MA.DATA[period] then
			SM[period]= SM[period-1] + Change;
			else    
			SM[period]= SM[period-1];
			end		 
		 
		
	
 
		 
		 SMP[period]=source.close[period]-SM[period];
	end 
    
end

