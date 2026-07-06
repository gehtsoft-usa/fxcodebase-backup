-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58535


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
    indicator:name("DMA");
    indicator:description("DMA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 17);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("DMA_color", "Color of DMA", "Color of DMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "Vertical Shift", 0);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local DMA = nil;
local Color, font, Size,Shift;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Shift = instance.parameters.Shift;
	Color=instance.parameters.Color;
	Size=instance.parameters.Size;
	
	font = core.host:execute("createFont", "Arial", Size, true, false);
	
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end

	
 
        DMA = instance:addStream("DMA", core.Line, name, "DMA", instance.parameters.DMA_color, first);
		DMA:setWidth(instance.parameters.width);
        DMA:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end


    local A=source[period] - source[period-Period+1]
    local B=0,i;

    for i = period, period- Period + 1, -1 do	
	B = B +math.abs((source[i]-source[i-1])	);
	end
	if B== 0 then
	B=0.00001
	end
	local C= A/B;
    local D = C* (2/31)+ (2/3)*(1-C)
	local E= D^2;
	
        DMA[period] = E*source[period] + (1-E)*DMA[period-1];
		
		Signal (period);
    
end



function Signal (period)

local Label="";
--(1) when DMAn >DMAn-1  and  DMAn-1 >DMAn-2   and  DMAn / DMAn-2 >=1.00050, print“  ”under the k-line.
if DMA[period]>DMA[period-1] and DMA[period-1]>DMA[period-2] and DMA[period]/DMA[period-2] >= 1.00050 then
Label= "under the k-line";
-- (2) when DMAn < DMAn-1  and  DMAn-1 < DMAn-2  and DMAn-2 < DMAn-3  ,print“  ”under the k-line.
elseif DMA[period]<DMA[period-1] and DMA[period-1]<DMA[period-2] and DMA[period-2]<DMA[period-3]  then
Label= "under the k-line";
--(3) when DMAn < DMAn-1  and  DMAn-1 < DMAn-2 and  DMAn / DMAn-2 < =0.99950 , print“  ” above the k-line
elseif DMA[period]<DMA[period-1] and DMA[period-1]<DMA[period-2] and DMA[period]/DMA[period-2] <=0.99950 then
Label= "above the k-line";
--(4) when DMAn >DMAn-1  and  DMAn-1 > DMAn-2  and DMAn-2 >DMAn-3  ,print“  ” above the k-line.
elseif DMA[period]>DMA[period-1] and DMA[period-1]>DMA[period-2] and DMA[period-2]>DMA[period-3]  then
Label= "above the k-line";
end

core.host:execute("drawLabel1", 1, 0, core.CR_RIGHT, 0+Shift+ (Size-10), core.CR_TOP, core.H_Left, core.V_Bottom,
                             font, Color, Label);

end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end