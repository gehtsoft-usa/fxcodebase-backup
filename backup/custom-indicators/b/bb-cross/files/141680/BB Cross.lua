-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71124

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2.0, 0.0001, 1000.0);
   
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addInteger("Size", "Font Size","", 15);
    indicator.parameters:addColor("clrUP", "Top Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Bottom Color","", core.COLOR_DOWNCANDLE);
	
	indicator.parameters:addGroup("BB Style"); 
	indicator.parameters:addBoolean("Show", "Show Bands","", false);
	
 
    indicator.parameters:addColor("BandsClr", "Bands line color", "Bands line color", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("BandsWidth", "Bands line width", "Bands line width", 1, 1, 5);
    indicator.parameters:addInteger("BandsStyle", "Bands line style", "Bands line style", core.LINE_SOLID);
    indicator.parameters:setFlag("BandsStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("AverageClr", "Average line color", "Average line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("AverageWidth", "Average line width", "Average line width", 1, 1, 5);
    indicator.parameters:addInteger("AverageStyle", "Average line style", "Average line style", core.LINE_SOLID);
    indicator.parameters:setFlag("AverageStyle", core.FLAG_LINE_STYLE);
 
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Deviation ; 
local first;
local source = nil;
local BB;
local Label_Top, Label_Bottom; 
local Size; 
local Show;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Deviation= instance.parameters.Deviation;
	Size= instance.parameters.Size;
	Show= instance.parameters.Show;

	local Parameters= Period..", "..Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	BB = core.indicators:create("BB", source.close, Period, Deviation);
    first=BB.DATA:first() ;
	
 
	Label_Top = instance:createTextOutput ("Top", "Top", "Arial", Size, core.H_Right, core.V_Top, instance.parameters.clrUP, 0);
	Label_Bottom = instance:createTextOutput ("Bottom", "Bottom", "Arial", Size, core.H_Right, core.V_Bottom, instance.parameters.clrDN, 0);
	
	
	BB_Top = instance:addStream("BB_Top", core.Line, name .. ".Top", "Top", instance.parameters.BandsClr, first);
    BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BandsClr, first);
    BB_Middle = instance:addStream("BB_Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.AverageClr, first);
    BB_Top:setWidth(instance.parameters.BandsWidth);
    BB_Top:setStyle(instance.parameters.BandsStyle);
    BB_Bottom:setWidth(instance.parameters.BandsWidth);
    BB_Bottom:setStyle(instance.parameters.BandsStyle);
    BB_Middle:setWidth(instance.parameters.AverageWidth);
    BB_Middle:setStyle(instance.parameters.AverageStyle);
end

-- Indicator calculation routine
function Update(period, mode)

    BB:update(mode);
	if period < first
	then
	return;
	end
	
	
	Label_Top:setNoData(period);
	Label_Bottom:setNoData(period);

 

	if source.close[period]> BB.TL[period] 
	and source.close[period-1]<= BB.TL[period-1] 
	then
	Label_Top:set(period , source.high[period ], "Top"); 
	elseif source.close[period]< BB.TL[period]	
	and source.close[period-1]>= BB.TL[period-1] 
	then
    Label_Bottom:set(period , source.low[period ], "Bottom"); 
    end	
 
 
    if Show then
	BB_Top[period]=BB.TL[period];
    BB_Bottom[period]=BB.BL[period];
    BB_Middle[period]=BB.AL[period];	
	end
				  
end


 
