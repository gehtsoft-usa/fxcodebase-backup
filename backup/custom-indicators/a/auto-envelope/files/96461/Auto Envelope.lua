-- Id: 12696
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61315


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
    indicator:name("Auto Envelope");
    indicator:description("Auto Envelope");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
	
    indicator.parameters:addInteger("Period", "MA Period", "MA Period", 22);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Factor", "Factor", "EMA Period", 27);
	indicator.parameters:addInteger("DeviationPeriod", "Deviation Period", "Deviation Period", 100);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Central Line Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "Top Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	local ma;
	local Factor;
-- Streams block
    local Central = nil;
    local Method;
	local DeviationPeriod;
	local Top, Bottom;
	local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	Factor= instance.parameters.Factor;
	DeviationPeriod= instance.parameters.DeviationPeriod;
    source = instance.source;
    first = source:first();

	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method).. ", " .. tostring(Factor) .. ", " .. tostring(DeviationPeriod).. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end
	
		
	Raw= instance:addInternalStream(0, 0);
 
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method, source.close, Period);
	first=source:first();
	
   
 
	    

        Central = instance:addStream( "Central", core.Line, name, "Central", instance.parameters.color1, first);
		Central:setWidth(instance.parameters.width1);
        Central:setStyle(instance.parameters.style1);
		
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color2, first+DeviationPeriod);
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
		
		Bottom = instance:addStream("Bottom", core.Line, name,"Bottom", instance.parameters.color3,first+DeviationPeriod);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
   
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ma:update(mode); 
	   
	   
	 if period < first then
	 return;
	 end
		
	

	    Raw[period]= 2*math.max(math.abs(source.high[period]-ma.DATA[period]) ,math.abs(source.low[period]-ma.DATA[period])) / ma.DATA[period]

    if period < first +DeviationPeriod then
	 return;
	 end
		
	   local  Stdev =mathex.stdev (Raw, period-DeviationPeriod+1, period)
	    local Csize= Stdev*Factor/10;     
	    local  Channel= Csize *ma.DATA[period];
 
        Central[period] =ma.DATA[period];		
		Top[period] =ma.DATA[period]+Channel/2; 
		Bottom[period]=ma.DATA[period]-Channel/2; 
  
end
 

