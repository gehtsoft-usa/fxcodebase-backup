-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33600
-- Id: 8772

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Moving average comparison tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
     indicator.parameters:addInteger("WavePeriod", "Wave Period", "Period", 20);
	 indicator.parameters:addInteger("MaPeriod", "MA Period", "Period", 10);
	 indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "CMA", "CMA" , "CMA");
	indicator.parameters:addStringAlternative("Method", "BBPOMVA", "BBPOMVA" , "BBPOMVA");
	
	indicator.parameters:addGroup("BBPOMVA Sub Parameter");
	indicator.parameters:addString("Method1", "BBPOMVA Sub Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Wave_color", "Color of Input", "Color of Input", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Out_color", "Color of Output", "Color of Output", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 

local first;
local source = nil;
local Method;
-- Streams block
local Wave,Out;
local Flag, First;
local WavePeriod;
local MaPeriod;
local MA;
local Method1;
local font;
-- Routine
function Prepare(nameOnly)
    WavePeriod=instance.parameters.WavePeriod;
	Method1=instance.parameters.Method1;
	MaPeriod=instance.parameters.MaPeriod;
	Method=instance.parameters.Method;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. WavePeriod  .. ", " .. MaPeriod .. ", " .. Method .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		font = core.host:execute("createFont", "Courier", 15, true, false);
    
		assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " .. Method .. ".LUA indicator");
		Wave = instance:addStream("Input", core.Line, name, "Input", instance.parameters.Wave_color, first);
    Wave:setPrecision(math.max(2, instance.source:getPrecision()));
		Wave:setWidth(instance.parameters.width);
        Wave:setStyle(instance.parameters.style);
		
		if Method== "BBPOMVA" then
		MA = core.indicators:create(Method, Wave, MaPeriod, Method1);
		else
		MA = core.indicators:create(Method, Wave, MaPeriod);
		end
		Out = instance:addStream("Output", core.Line, name, "Output", instance.parameters.Out_color, MA.DATA:first());
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
		Out:setWidth(instance.parameters.width1);
        Out:setStyle(instance.parameters.style1);
    end
	
	Flag= true;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	if Flag then
	Flag= false;
	First= source:date(first);
	end
	
	
	if period < first   then
	return;
	end
	
	local p = core.findDate(source, First, false);
	
        Wave[period] = math.sin((period-p)/WavePeriod*(math.pi)*2);
		
		
		MA:update(mode);
		
		if period <MA.DATA:first() then
		return;
		end
		
		Out[period]= MA.DATA[period];
		
		
		if period <source:size()-1 then
		return;
		end
		
		
		local min1, pos1;
		local min2, pos2;
		
		
		min1,pos1=mathex.max(Wave, period-WavePeriod+1, period);
		min2,pos2=mathex.max(Out, period-WavePeriod+1, period);
		
		  
			local Value3, Value4 ,value3, value4 ;
		Value3=  ( pos2-pos1) /(WavePeriod/100)
		value3 =   "X : " ..  string.format("%." .. 2 .. "f", Value3  )  .. " %";
		core.host:execute("drawLabel1", 1, 0, core.CR_RIGHT, 15, core.CR_TOP, core.H_Left, core.V_Bottom, font, core.rgb(0, 0, 255), value3 );
		
       
        Value4 = ( min1-min2)*100;    
		value4 =   "Y : " ..  string.format("%." .. 2 .. "f" ,   Value4  ) .. " %";
		core.host:execute("drawLabel1", 2, 0, core.CR_RIGHT, 30, core.CR_TOP, core.H_Left, core.V_Bottom, font, core.rgb(0, 0, 255), value4 );
end


 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   
	   
