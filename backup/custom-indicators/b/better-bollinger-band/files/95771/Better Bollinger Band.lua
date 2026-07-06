-- Id: 12422
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61115

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
    indicator:name("Better Bollinger Band");
    indicator:description("Better Bollinger Band");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("lb", "Envelope Lookback Length", "Envelope Lookback Length", 20);
    indicator.parameters:addDouble("de", "Envelope Band Deviation", "Envelope Band Deviation", 2);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local lb;
local de;

local first;
local source = nil;

-- Streams block
local Top = nil;
local Central = nil;
local Bottom = nil;
local alp;
local mt, ut; 
local mt2, ut2; 
-- Routine
function Prepare(nameOnly)
    lb = instance.parameters.lb;
    de = instance.parameters.de;
    source = instance.source.median;
    first = source:first();
    alp=2/(lb+1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(lb) .. ", " .. tostring(de) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	mt = instance:addInternalStream(0, 0);
	ut = instance:addInternalStream(0, 0);
	mt2 = instance:addInternalStream(0, 0);
	ut2 = instance:addInternalStream(0, 0);

    if (not (nameOnly)) then
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
        Top[period] = nil;
        Central[period] = nil;
        Bottom[period] = nil;
   
 
 
mt[period]=alp*source[period]+(1-alp)*mt[period-1];
ut[period]=alp*mt[period]+(1-alp)*ut[period-1]
Central[period]=((2-alp)*mt[period]-ut[period])/(1-alp)
mt2[period]=alp*math.abs(source[period]-Central[period])+(1-alp)* mt2[period-1];
ut2[period]=alp*mt2[period]+(1-alp)* ut2[period-1]; 
dt2=((2-alp)*mt2[period]-ut2[period])/(1-alp);
Top[period]=Central[period]+de*dt2;
Bottom[period]=Central[period]-de*dt2; 
 
end

