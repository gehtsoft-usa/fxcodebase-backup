-- Id: 16762
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63943&p=108466#p108466

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Parallel lines");
    indicator:description(" ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Delta Selector");
	indicator.parameters:addDouble("DeltaUp", "Top Line Delta (in Pips)", "", 10);
	indicator.parameters:addDouble("DeltaDown", "Bottom Line Delta (in Pips)", "", 10);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period", "Period", "", 14);
 
	  
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("L1", "Show Up Line", "", true);	
	indicator.parameters:addBoolean("L2", "Show Down Line", "", true);
	indicator.parameters:addBoolean("L3", "Show MA Line", "", true);

	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
   indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local L1, L2,L3;
local first;
local source = nil;
local Method, Period;
-- Streams block
local Up = nil;
local Down = nil;
local MA,ma;
local DeltaUp, DeltaDown;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Type=instance.parameters.Type;
	L1=instance.parameters.L1;
	L2=instance.parameters.L2;
	L3=instance.parameters.L3;
	NormalizationPeriod=instance.parameters.NormalizationPeriod;
	
	DeltaUp=instance.parameters.DeltaUp;
	DeltaDown=instance.parameters.DeltaDown;
   
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ")";
    instance:name(name);	
	if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		ma = core.indicators:create(Method, source, Period);
		first =ma.DATA:first();
	    if L1 then
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
		Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
		else
		 Up= instance:addInternalStream(0, 0);
		end
		if L2 then
        Down = instance:addStream("Dowm", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
		Down:setWidth(instance.parameters.width2);
        Down:setStyle(instance.parameters.style2);
		else
		 Down= instance:addInternalStream(0, 0);
		end
		
		if L3 then
		 MA  = instance:addStream("MA ", core.Line, name .. ".MA ", "MA ", instance.parameters.MA_color, first);
		 MA:setWidth(instance.parameters.width3);
         MA:setStyle(instance.parameters.style3);
		  else
		 MA = instance:addInternalStream(0, 0);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	
	ma:update(mode); 

    if period < first  then
	return;
	end 
	 
        
        MA[period]= ma.DATA[period] ;
		Up[period] =  MA[period]+DeltaUp*source:pipSize() ;
        Down[period]= MA[period]-DeltaDown*source:pipSize() ;
end

