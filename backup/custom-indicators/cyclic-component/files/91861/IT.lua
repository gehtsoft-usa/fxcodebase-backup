-- Id: 10817

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60180

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
    indicator:name("INSTANTANEOUS TRENDLINE");
    indicator:description(" INSTANTANEOUS TRENDLINE");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 20);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("IT_color", "Color of IT", "Color of IT", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;

-- Streams block
local IT = nil;
local SMA,Slope;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        SMA = core.indicators:create("MVA", source, Length);
        first = SMA.DATA:first();
        
        Slope = instance:addInternalStream(0, 0);
        IT = instance:addStream("IT", core.Line, name, "IT", instance.parameters.IT_color, first);
		IT:setWidth(instance.parameters.width);
        IT:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
     SMA:update(mode);
	
	if period < first or not  source:hasData(period) then	
	return;
	end
	
	Slope[period]= source[period]-source[period- Length+1];	

	local SmoothSlope = (Slope[period] + 2* Slope [period-1] + 2* Slope [period-2] + Slope[period-3])/6; 
	IT[period]  = SMA.DATA[period] + 0.5 *SmoothSlope;
    
end

--[[
SMA = 0;
For count = 0 to Length -1 Begin
SMA = SMA + Price[count];
End;
SMA = SMA / Length;
Slope = Price - Price[Length - 1];
SmoothSlope = (Slope + 2* Slope [1] + 2* Slope [2] + Slope[3]) / 6;
ITrend = SMA + .5*SmoothSlope;
]]
