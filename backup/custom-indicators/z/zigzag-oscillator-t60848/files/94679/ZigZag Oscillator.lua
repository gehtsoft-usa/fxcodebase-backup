-- Id: 12067
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60848

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
    indicator:name("ZigZag Oscillator");
    indicator:description("ZigZag Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Zig Zag Parameters");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "Color of Line", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Color;
-- Streams block
local ZigZag = nil;
local Depth;
local Deviation;
local Backstep;
local Trend;
local Top=nil;
local Bottom=nil;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
	Color = instance.parameters.Color;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ZigZag = core.indicators:create("ZIGZAG", source,Depth,Deviation,Backstep);
		first = source:first();
        Trend = instance:addStream("Trend", core.Line, name, "Trend", Color, first);
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period ,mode)

    if ZigZag.DATA:hasData(period) then
	 ZigZag:update(mode);
	else
    ZigZag:update(core.UpdateAll);
	end
	
	 
	
    if period < first 
	or not  source:hasData(period) 
	then
	return;
	end
	
	local Position={};
	local Direction={};
	for i= math.min(period, source:size()-2), first, -1 do 
	
		 if   ZigZag.DATA:hasData(i) then
		 if ( ZigZag.DATA[i]> ZigZag.DATA[i-1] and ( ZigZag.DATA[i]> ZigZag.DATA[i+1] or  ZigZag.DATA[i+1]== nil or  ZigZag.DATA[i+1]==0   ))
		 or  ( ZigZag.DATA[i]< ZigZag.DATA[i-1]	 and (ZigZag.DATA[i]< ZigZag.DATA[i+1] or ZigZag.DATA[i+1]== nil  or  ZigZag.DATA[i+1]==0  ))		 
		 then
		    Position[#Position+1]= i;
			
			if ZigZag.DATA[i]> ZigZag.DATA[i-1] and (ZigZag.DATA[i]> ZigZag.DATA[i+1]or ZigZag.DATA[i+1]== nil  or  ZigZag.DATA[i+1]==0  ) then
		    Direction[#Position]=1;
			end
			
			if ZigZag.DATA[i]< ZigZag.DATA[i-1]	 and (ZigZag.DATA[i]< ZigZag.DATA[i+1]or ZigZag.DATA[i+1]== nil  or  ZigZag.DATA[i+1]==0 )  then
		    Direction[#Position]=-1;
			end
			
         end
		 
		 
		 if #Position== 2 then
		 break;
	     end
		else
		Trend[i]= nil;
        end		
    end
    
	if #Position <2 then
	return;
	end

		
	local prev_peak= Position[2];
	local last_peak= Position[1];
	
 
	Draw (prev_peak+1,last_peak,Direction[1] );
	
	  
end

function Draw (prev_peak,last_peak,Value )
     if prev_peak ~= last_peak then
	core.drawLine(Trend, core.range(prev_peak, last_peak ), Value , prev_peak, Value, last_peak, Color);
	else
	Trend[last_peak]=Value;	
	end
	
 
end	