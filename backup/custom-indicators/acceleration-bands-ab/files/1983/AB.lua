
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1051

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
    indicator:name("Acceleration Bands");
    indicator:description("Acceleration Bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculate");	
	indicator.parameters:addInteger("Period", "Period", "Period", 20,2,2000); 
    indicator.parameters:addDouble("Factor", "Factor", "Factor", 0.001);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Factor=nil;

local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;
local Central = nil;
local AVGTOP = nil;
local AVGBottom = nil;
local Period=nil;
local UP=nil;
local DOWN=nil;

-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
    Factor = instance.parameters.Factor;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. Factor .. ", " .. Period .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
	UP = instance:addInternalStream(0,0); 
    DOWN = instance:addInternalStream(0,0); 
	
	AVGTOP = core.indicators:create("MVA", UP, Period);
	AVGBOTTOM = core.indicators:create("MVA", DOWN, Period);
	AVG = core.indicators:create("MVA", source.close, Period);	
	
    Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, AVG.DATA:first());
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	
	
    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, AVG.DATA:first());
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
	Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, AVG.DATA:first());
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
	
	first=  AVG.DATA:first();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
		
       UP[period] = ( source.high[period] * ( 1 + 2 * (((( source.high[period] - source.low[period] )/(( source.high[period] + source.low[period] ) / 2 )) * 1000 ) * Factor )));
       DOWN[period] = ( source.low[period] * ( 1 - 2 * (((( source.high[period] - source.low[period])/(( source.high[period] + source.low[period] ) / 2 )) * 1000 ) * Factor )));
      
	AVGTOP:update(mode);
    AVGBOTTOM:update(mode);
	AVG:update(mode);	 
	
	if period <  first then
    return;
	end
	 
	    
		 Central[period]= AVG.DATA[period];
		 Top[period]= AVGTOP.DATA[period];
		 Bottom[period]=AVGBOTTOM.DATA[period];
	

end

