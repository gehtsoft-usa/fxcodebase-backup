
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65024

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


function Init()
    indicator:name("Fully customizable Bollinger Band");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N1", "Number of periods for Top Midline", "", 20, 1, 10000);
	indicator.parameters:addInteger("N2", "Number of periods for Bottom Midline", "", 20, 1, 10000);
	
    indicator.parameters:addDouble("D1", "Deviation for Top Line", "", 2.0, 0.00001, 10000);
    indicator.parameters:addDouble("D2", "Deviation for Bottom Line", "", 2.0, 0.00001, 10000);
	
	indicator.parameters:addInteger("D1_Period", "Period for Top Line Deviation", "", 20, 1, 10000);
    indicator.parameters:addInteger("D2_Period", "Period for Bottom Line Deviation", "", 20, 1, 10000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("MS", "Midline Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MW", "Midline Width", "", 1, 1, 5);
    indicator.parameters:addColor("M_Top", "Top Line Midline Color", "", core.rgb(255, 0, 255));
	 indicator.parameters:addColor("M_Bottom", "Bottom Line Midline Color", "", core.rgb(255, 0, 255));

    indicator.parameters:addInteger("Top_S", "Top Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Top_S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("Top_W", "Top Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Top_C", "Top Line Color", "", core.rgb(127, 0, 0));

    indicator.parameters:addInteger("Bottom_S", "Bottom Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Bottom_S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("Bottom_W", "Bottom Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Bottom_C", "Bottom Line  Color", "", core.rgb(255, 128, 64));
 
end

local N1,N2, D1, D2;
local first;
local source;
local M_Top,M_Bottom;
local D1_Period, D2_Period;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
    N1 = instance.parameters.N1;
	N2 = instance.parameters.N2;
    D1 = instance.parameters.D1;
    D2 = instance.parameters.D2;
	D1_Period = instance.parameters.D1_Period;
    D2_Period = instance.parameters.D2_Period;
    first = source:first() ;

    M_Top = instance:addStream("Mid_Top", core.Line, name .. ".Mid_Top", "Mid_Top", instance.parameters.M_Top, first+N1);
    M_Top:setStyle(instance.parameters.MS);
    M_Top:setWidth(instance.parameters.MW);	
	
    M_Bottom = instance:addStream("Mid_Bottom", core.Line, name .. ".Mid_Bottom", "Mid_Bottom", instance.parameters.M_Bottom, first+N2);
    M_Bottom:setStyle(instance.parameters.MS);
    M_Bottom:setWidth(instance.parameters.MW);
	
    Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_C, first+math.max(N1,D1));
    Top:setStyle(instance.parameters.Top_S);
    Top:setWidth(instance.parameters.Top_W);
    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_C,   first+math.max(N2,D2));
    Bottom:setStyle(instance.parameters.Bottom_S);
    Bottom:setWidth(instance.parameters.Bottom_W);
 

  end

  

function Update(period, mode)
    
 		
    if period >= first+math.max(N1,D1_Period) then
        local m1 = core.avg(source, period - N1 + 1, period);
        local d1 = mathex.stdev(source, period - D1_Period + 1, period);
		M_Top[period] = m1;
		Top[period] = m1 + d1 * D1;
    
    end		
	
	if period >=  first+math.max(N2,D2_Period) then
        local m2 = core.avg(source, period - N2 + 1, period);
        local d2 = mathex.stdev(source, period - D2_Period + 1, period);
		M_Bottom[period] = m2;
		Bottom[period] = m2 - d2 * D2;
    end		
         
end




