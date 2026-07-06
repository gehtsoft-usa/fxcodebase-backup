-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60741
-- Id: 11820

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Smart money pressure");
    indicator:description("Smart money pressure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
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
 
local MA,SM;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    LookBack = instance.parameters.LookBack;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(LookBack) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		MA= core.indicators:create("MVA", source.volume, Period);
		first = MA.DATA:first()+LookBack;
		 
		SM  = instance:addInternalStream(0, 0);
        SMP = instance:addStream("SMP", core.Line, name, "SMP", instance.parameters.SMP_color, first);
		SMP:setWidth(instance.parameters.width);
        SMP:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

     
    MA:update(mode); 
	
    if period < source:size()-1 then
    return;
    end
  	
	SM[period]=nil
	SMP[period]=nil
	
	local Start;
	if LookBack== 0 then
	Start=first;
	else
	Start=math.max(source:size()-1-LookBack, first)
	end
	
	for period=Start, source:size()-1 ,1 do
	 
	     
	
		    Change=source.close[period]-source.close[period-1]; 
		 
			 if source.volume[period]> MA.DATA[period] then
			SM[period]= SM[period-1] + Change;
			else    
			SM[period]= SM[period-1];
			end		 
		 
		
	
 
		 if LookBack== 0 then
		 SMP[period] = source.close[first]+SM[period];
		 else	
		 SMP[period] = source.close[math.max(source:size()-1-LookBack, first)]+SM[period];
		 end
	end 
    
end

