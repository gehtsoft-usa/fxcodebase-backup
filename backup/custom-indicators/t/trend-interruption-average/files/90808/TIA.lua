-- Id: 10416
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59851

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trend Interruption Average");
    indicator:description("Trend Interruption Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
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
	indicator.parameters:addBoolean("L3", "Show Difference Line", "", true);

	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dowm_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Difference_color", "Color of Difference", "Color of Difference", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
   indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	 
	indicator.parameters:addString("Type", " DifferenceType", "", "Bar");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
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
local up, down;
local Difference = nil;
local u, d;
local Type;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Type=instance.parameters.Type;
	L1=instance.parameters.L1;
	L2=instance.parameters.L2;
	L3=instance.parameters.L3;
   
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	u = instance:addInternalStream(0, 0);
	d = instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	up = core.indicators:create(Method, u, Period);
	down = core.indicators:create(Method, d, Period);
	
	 first = math.max(up.DATA:first(), down.DATA:first());
	if (not (nameOnly)) then
	    if L1 then
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
		else
		 Up= instance:addInternalStream(0, 0);
		end
		if L2 then
        Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Dowm_color, first);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setWidth(instance.parameters.width2);
        Down:setStyle(instance.parameters.style2);
		else
		 Down= instance:addInternalStream(0, 0);
		end
		
		if L3 then
			if Type== "Line" then
			Difference = instance:addStream("Difference", core.Line, name .. ".Difference", "Difference", instance.parameters.Difference_color, first);
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
			Difference:setWidth(instance.parameters.width3);
			Difference:setStyle(instance.parameters.style3);
			else
			Difference = instance:addStream("Difference", core.Bar, name .. ".Difference", "Difference", instance.parameters.Difference_color, first);
			end
		else
		 Difference= instance:addInternalStream(0, 0);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



	if source[period]> source[period-1] then
	u[period]=u[period-1]+1;
	d[period]=0;
	elseif source[period]< source[period-1] then
	d[period]=d[period-1]+1;
	u[period]=0;
	else
	u[period]=0;
	d[period]=0;
	end
	up:update(mode);
	down:update(mode);

    if period < first  then
	return;
	end 
	
        Up[period] = up.DATA[period];
        Down[period] = down.DATA[period];		
        Difference[period] = Up[period]-Down[period] ;
    
end

