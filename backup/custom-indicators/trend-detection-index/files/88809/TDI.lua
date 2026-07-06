-- Id: 9782
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59268


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
    indicator:name("Trend Detection Index");
    indicator:description("Trend Detection Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	indicator.parameters:addString("Type", "Type", "", "Signal");
    indicator.parameters:addStringAlternative("Type", "Signal", "", "Signal");
    indicator.parameters:addStringAlternative("Type", "Indicator", "", "Indicator");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TDI_color", "Color of TDI", "Color of TDI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Direction_color", "Color of Direction", "Color of Direction", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Type;
-- Streams block
local TDI = nil;
local Direction = nil;
local MomBuffer,MomAbsBuffer;
local Signal;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Type = instance.parameters.Type;
    source = instance.source;
	
	MomBuffer = instance:addInternalStream(0, 0);	
	MomAbsBuffer = instance:addInternalStream(0, 0);
	
    first = source:first()+Period;


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	 if Type ~= "Signal" then 
        TDI = instance:addStream("TDI", core.Line, name .. ".TDI", "TDI", instance.parameters.TDI_color, first);
    TDI:setPrecision(math.max(2, instance.source:getPrecision()));
		TDI:setWidth(instance.parameters.width1);
        TDI:setStyle(instance.parameters.style1);
        Direction = instance:addStream("Direction", core.Line, name .. ".Direction", "Direction", instance.parameters.Direction_color, first+Period);
    Direction:setPrecision(math.max(2, instance.source:getPrecision()));
		Direction:setWidth(instance.parameters.width2);
        Direction:setStyle(instance.parameters.style2)
		Signal = instance:addInternalStream(0, 0);
    	else
		
        TDI = instance:addInternalStream(0, 0);
        Direction = instance:addInternalStream(0, 0);		
		Signal = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, first+2*Period);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width3);
        Signal:setStyle(instance.parameters.style3);
   
		
		end
		
		
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first then
	return;
	end
	
	
	MomBuffer[period]=source[period]-source[period-Period];
    MomAbsBuffer[period]=math.abs(MomBuffer[period]);
	
	if period < first+Period then
	return;
	end
	
	
    Direction[period]=mathex.sum(MomBuffer,period-Period+1, period);
	
	local F= math.abs(Direction[period]);
	local H=mathex.sum(MomAbsBuffer,period-Period+1, period);
	
	if period < first+2*Period then
	return;
	end
	
	local G=mathex.sum(MomAbsBuffer,period-Period*2+1, period);
   
  
   
        TDI[period] = (F + H)- G;
		
		if TDI[period] > 0 then
		
		   if Direction[period] >0 then
		   Signal[period]=1;
		   else
		   Signal[period]=-1;
		   end
		else
		Signal[period]=Signal[period-1];
		end
		
		--IF(I60>0,IF(E60>0,1,-1),J60)
   
end

