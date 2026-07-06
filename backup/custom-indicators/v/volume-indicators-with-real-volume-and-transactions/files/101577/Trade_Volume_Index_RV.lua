-- Id: 14563

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
    indicator:name("Trade Volume Index with Real volume/Transactions");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("MTV", "Minimum Tick Value", "Minimum Tick Value",10);
    indicator.parameters:addColor("TVI_color", "Color of TVI", "Color of TVI", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local MTV;
-- Streams block
local TVI = nil;
local Direction;
local ExtremePrice=0;
local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	MTV=instance.parameters.MTV;
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	
	Direction = instance:addInternalStream(0, 0);
	ExtremePrice = instance:addInternalStream(0, 0);
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;


    if (not (nameOnly)) then
        TVI = instance:addStream("TVI", core.Line, name, "TVI", instance.parameters.TVI_color, first);
    TVI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period  <= first or not  source:hasData(period) then		
	        	ExtremePrice[period]=source.close[period];		
                Direction[period]=0;				
		return;
	end
	 
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+1 then
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
	
	
	 
	local Change= (source.close[period]-ExtremePrice[period-1])/ source:pipSize()  ;
	
	if  Change > MTV then
	Direction[period]=1;
	ExtremePrice[period]=source.close[period];
	elseif Change < -MTV then	
	Direction[period]=-1;
	ExtremePrice[period]=source.close[period];
	else
	Direction[period]=Direction[period-1];
	ExtremePrice[period]=ExtremePrice[period-1]; 
	end
	
	    if Direction[period]== 1 then
		TVI[period] = TVI[period-1]+Ind.DATA[period];
		elseif Direction[period]== -1 then
		TVI[period] = TVI[period-1]-Ind.DATA[period];
		else
		TVI[period]=TVI[period-1];
		end
        
    
end

