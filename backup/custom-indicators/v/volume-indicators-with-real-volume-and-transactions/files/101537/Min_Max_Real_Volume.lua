
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
    indicator:name("Min Max Real volume");
    indicator:description("Min Max Real volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
	indicator.parameters:addInteger("Period", "Period", "", 20);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arriw Size", "", 10);
	indicator.parameters:addColor("Up", "Max color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Min color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Size;
local Type;
local up, down; 
local Period;
local Ind;

local FirstStart;
local LastTime;
function Prepare(nameOnly)
    Period=instance.parameters.Period;
	Size=instance.parameters.Size;
	source = instance.source;	 
	
	  local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() .. ", "..Period;
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Dn, 0);
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
    FirstStart=true;
    LastTime=0;
	
  
	
	first= source:first()+Period;
		
end

-- Indicator calculation routine
function Update(period, mode)

	
			if period < first then
			return;
			end
			
			up:setNoData(period);
            down:setNoData(period);
			
	      local min,max;
		  
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
		  min,max=mathex.minmax(Ind.DATA, period-Period+1, period);
		 
		                        if Ind.DATA[period]== max then
								up:set(period, source.high[period], "\108",Ind.DATA[period]);
							    end
							    if Ind.DATA[period]== min  then
								down:set(period, source.low[period], "\108", Ind.DATA[period]);
								end
		 
 end

function AsyncOperationFinished(cookie, success, message)

end

