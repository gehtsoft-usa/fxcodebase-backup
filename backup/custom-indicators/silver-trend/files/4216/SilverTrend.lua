-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2060
-- Id: 1495

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Silver Trend");
    indicator:description("Silver Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SSP", "SSP", "", 6);
    indicator.parameters:addDouble("Kmin", "Kmin", "", 1.6);
    indicator.parameters:addDouble("Kmax", "Kmax", "", 50.6);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("S1_color", "S1 Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("S2_color", "S2 Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SSP;
local Kmin;
local Kmax;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;

-- Routine
function Prepare(nameOnly)
    SSP = instance.parameters.SSP;
    Kmin = instance.parameters.Kmin;
    Kmax = instance.parameters.Kmax;
    --Filter = instance.parameters.Filter;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. SSP .. ", " .. Kmin .. ", " .. Kmax .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    S1 = instance:addStream("S1", core.Line, name .. ".S1", "S1", instance.parameters.S1_color, first+SSP);
    S2 = instance:addStream("S2", core.Line, name .. ".S2", "S2", instance.parameters.S2_color, first);
	
	S1:setWidth(instance.parameters.width1);
    S1:setStyle(instance.parameters.style1);
	S2:setWidth(instance.parameters.width2);
    S2:setStyle(instance.parameters.style2);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first+SSP  or not  source:hasData(period) then
	return;
	end	
	
			local SsMin,  SsMax = mathex.minmax(source,period-SSP+1,period);
			--local SsMin = core.min(source.low,core.range(period-SSP+1,period));
		   
			local  smin =((SsMin - (SsMax - SsMin)*Kmin / 100));
			local  smax = ((SsMax - (SsMax - SsMin)*Kmax / 100));
			
	
        S1[period] = smax;
        S2[period-SSP+1] = smax;
     
end
 