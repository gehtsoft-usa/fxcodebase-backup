-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59593
-- Id: 10107

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
    indicator:name("Zig Zag Moving Average");
    indicator:description("Zig Zag Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Zig Zag Parameters");
	indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
    indicator.parameters:addGroup("MA Parameters");

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period", "Period", "Period", 12);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Rising CPMA", "Color of CPMA", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Color of Falling CPMA", "Color of CPMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Depth;
local Deviation;
local Backstep;
local Method, Period;
-- Streams block
local CPMA = nil;
local Raw, MA, Zig;
local Up, Down;
local Flag;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;	
	Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep.. ", " .. Period.. ", " .. Method.. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Zig= core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep);
		first = Zig.DATA:first();
		Flag = instance:addInternalStream(0, 0);
		Raw = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, Raw, Period);
        CPMA = instance:addStream("CPMA", core.Line, name, "CPMA", Up, MA.DATA:first());
		CPMA:setWidth(instance.parameters.width);
        CPMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
    Zig:update(mode);	
	

	
    if period < first  then
	return;
	end
	
		local i;
	local y= nil;
	
		for i= period, first+Depth, -1 do  

				if Zig.DATA[i]~= nil then 
				y= i;					
				end				
		end
		
	local x;
	 
	
	if y== nil then
	return;
	end
	
	if period < first+y  then
	return;
	end
	
	for x= period-y+1,period-1, 1 do 
		Flag[x]= Flag[x-1];
		
		if Zig.DATA[x-1] ~= nil and Zig.DATA[x] ~= nil  and Zig.DATA[x+1] ~= nil  then
		
			if Zig.DATA[x-1]<Zig.DATA[x] and Zig.DATA[x]>Zig.DATA[x+1] then
			Flag[x]=1;
			end
			
			if Zig.DATA[x-1]>Zig.DATA[x] and Zig.DATA[x]<Zig.DATA[x+1] then
			Flag[x]=-1;
			end
			  
		end	
		
			if Flag[x]== 1 then
			Raw[x]= source.high[x];
			Raw[x+1]= source.high[x+1];
			else
			Raw[x]= source.low[x];
			Raw[x+1]= source.low[x+1];
			end
			
		
    
	   
	end
	
	for x= period-y+1,period, 1 do 		
			MA:update(mode)
			if x < MA.DATA:first() then
			return;
			end

			
				CPMA[x] = MA.DATA[x];
				
				if CPMA[x] > CPMA[x-1] then
				CPMA:setColor(x, Up);
				else
				CPMA:setColor(x, Down);
				end
	end

end

