-- Id: 6270
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15548

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
    indicator:name("Multiple smoothing moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Average Period", "", 5, 2, 2000);
	indicator.parameters:addInteger("Repetitions", "Number of Repetitions", "", 5, 1,1000);
	indicator.parameters:addString("Method", " Average Method", "" , "MVA");	
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("MSMA Line Style");	
    indicator.parameters:addColor("MSMA", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Intermediate Line Style");	
	indicator.parameters:addBoolean("Show", "Show intermediate results", "", true);
    indicator.parameters:addColor("Intermediate", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("iwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("istyle", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("istyle", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method, Period,Repetitions;
local first;
local source = nil;
local MSMA;
local MA={};
local Show;
local Intermediate={};
-- Routine
function Prepare(nameOnly)
    Show = instance.parameters.Show;
    Method = instance.parameters.Method;	
	Period = instance.parameters.Period;	
	Repetitions = instance.parameters.Repetitions;
    source = instance.source;
   
	first = MA[Repetitions].DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method).. ", " .. tostring(Period).. ", " .. tostring(Method).. ", " .. tostring(Repetitions).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		local i;
		for i = 1,Repetitions , 1 do
			if i == 1 then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
			 MA[i]= core.indicators:create(Method, source, Period);
			else
			MA[i]= core.indicators:create(Method, MA[i-1].DATA, Period);
			end 
			
			if Show and i < Repetitions then
			 Intermediate[i] = instance:addStream(tostring( "Intermediate"..i), core.Line, i, i, instance.parameters.Intermediate, MA[i].DATA:first());
			 Intermediate[i]:setWidth(instance.parameters.iwidth);
			 Intermediate[i]:setStyle(instance.parameters.istyle);
			end
		
		end	
		
        MSMA = instance:addStream("MSMA", core.Line, name .. ".MSMA", "MSMA", instance.parameters.MSMA, first);
		MSMA:setWidth(instance.parameters.width);
        MSMA:setStyle(instance.parameters.style);
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
	return;
	end
        
	local i;
	for i = 1,Repetitions , 1 do	
	    MA[i]:update(mode);
		
		if Show and i < Repetitions then
		Intermediate[i][period]= MA[i].DATA[period];
		end
		
    end		
		
		MSMA[period] = MA[Repetitions].DATA[period] ;
		
 end

