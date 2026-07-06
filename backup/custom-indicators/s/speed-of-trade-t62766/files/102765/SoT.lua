-- Id: 14906
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62766

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
    indicator:name("Speed of Trade");
    indicator:description("Speed of Trade");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Claculation");	
    indicator.parameters:addString("Type", "Candle Type", "", "OC");
    indicator.parameters:addStringAlternative("Type", "Open / Close", "", "OC");
    indicator.parameters:addStringAlternative("Type", "High / Low", "", "HL");
	indicator.parameters:addInteger("Period", "MA Period", "", 14);
	indicator.parameters:addInteger("Trigger", "Trigger Level", "", 2);
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addInteger("Size", "Font Size", "", 15);
    indicator.parameters:addColor("SOT_color", "Color of SOT", "Color of SOT", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	   indicator.parameters:addColor("AVG_color", "Color of AVG", "Color of AVG", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clrUP", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrDN", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type;

local first;
local source = nil;

-- Streams block
local SOT = nil;
local Trigger;
local Period;
local Avg;
local Size, up, down;
-- Routine
function Prepare(nameOnly)
    Type=instance.parameters.Type;
	Trigger=instance.parameters.Trigger;
	Period=instance.parameters.Period;
	Size=instance.parameters.Size;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name().. ", " .. Type  .. ", " .. Period .. ", " .. Trigger .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        SOT = instance:addStream("SOT", core.Line, name, "SOT", instance.parameters.SOT_color, first); 
    SOT:setPrecision(math.max(2, instance.source:getPrecision()));
		SOT:setWidth(instance.parameters.width1);
        SOT:setStyle(instance.parameters.style1);
		
		AVG = instance:addStream("AVG", core.Line, name, "AVG", instance.parameters.AVG_color, first+Period); 
    AVG:setPrecision(math.max(2, instance.source:getPrecision()));
		AVG:setWidth(instance.parameters.width2);
        AVG:setStyle(instance.parameters.style2);
		
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	    if Type == "OC" then
        SOT[period] = ((math.abs(source.open[period]-source.close[period])) /source:pipSize())/source.volume[period];
		else
		 SOT[period] = ((math.abs(source.high[period]-source.low[period])) /source:pipSize())/source.volume[period];
		end
   
   
	   
	if period < first +Period then
	return;
	end
	
	
	 AVG[period]=mathex.avg(SOT, period-Period+1, period);
	 
	 
	 down:setNoData(period);
	 up:setNoData(period);
	 
	 if  SOT[period]  > AVG[period] *Trigger   then
	     if source.close[period]> source.open[period] then 
		 up:set(period , AVG[period ], "\217");
		 elseif source.close[period]< source.open[period] then
		 down:set(period, AVG[period], "\218");
		 end
	 end
          
end

