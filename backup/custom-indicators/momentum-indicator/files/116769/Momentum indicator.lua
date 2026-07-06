-- Id: 20078
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65509

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
    indicator:name("Momentum indicator");
    indicator:description("Momentum indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Duration", "Duration in seconds", "Duration in seconds", 60);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OpenClose_Color", "Color of Open Close Line", "Color", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("HighClose_Color", "Color of High Close Line", "Color", core.rgb(255, 0, 0));
	  indicator.parameters:addColor("LowClose_Color", "Color of Low Close Line", "Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local Duration;
local OpenClose;
local HighClose;
local LowClose;
local Second; 
-- Routine
function Prepare(nameOnly)
    Duration = instance.parameters.Duration; 
    source = instance.source;
    first=source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	

	Second=1/86400;
	 
   
        OpenClose = instance:addStream("OpenClose", core.Line, name .. ".OpenClose", "OpenClose", instance.parameters.OpenClose_Color, source:first());
    OpenClose:setPrecision(math.max(2, instance.source:getPrecision()));
		OpenClose:setWidth(instance.parameters.Width);
        OpenClose:setStyle(instance.parameters.Style);
		
		HighClose = instance:addStream("HighClose", core.Line, name .. ".HighClose", "HighClose", instance.parameters.HighClose_Color, source:first());
    HighClose:setPrecision(math.max(2, instance.source:getPrecision()));
		HighClose:setWidth(instance.parameters.Width);
        HighClose:setStyle(instance.parameters.Style);
		
		LowClose = instance:addStream("LowClose", core.Line, name .. ".LowClose", "LowClose", instance.parameters.LowClose_Color, source:first());
    LowClose:setPrecision(math.max(2, instance.source:getPrecision()));
		LowClose:setWidth(instance.parameters.Width);
        LowClose:setStyle(instance.parameters.Style);
      
      
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	
	if period <= first then
	return;
	end
	
 
	 
	 
	local P1= core.findDate (source, source:date(period)- Second * Duration, false);
	
	if P1==-1
	or P1< first+1 
	or P1>= period
    then
    return;
    end 
	 
	 
	 local Open=source[P1];
	 local Close=source[period];	 
	 local Low,High=mathex.minmax(source,P1,period);
 
		
     OpenClose[period]= Open-Close;
     HighClose[period]= High-Close;
	 LowClose[period]=  Low-Close;
	 
end
 