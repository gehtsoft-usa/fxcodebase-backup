--[[ 
based on LINEAR REGRESSION LINE and POLYNOMIAL_REGRESSION 

The purpose of this indicator is to show the evolution of a polynomial regression of degree 1 (linear) over time. 
This also makes it possible to visualize where the tapes are to consider where not a profit taking 
or the positioning of the stop loss, as desired.

]]

-- Donate :

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
    indicator:name("LRLBD");
    indicator:description("Linear Regression Line with Band Deviation");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Perios",20);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Color of Down Trend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrBand", "Color band", "Color band", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local LRL = nil;
local Deviation;

-- Routine
function Prepare(nameOnly)

    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD;
    Deviation=instance.parameters.Deviation;


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if (not (nameOnly)) 
    then
        LRL = instance:addStream("LRL", core.Line, name, "LRL", instance.parameters.Up, first);
		LRL:setWidth(instance.parameters.width);
        LRL:setStyle(instance.parameters.style);
        
        BuffBandUp = instance:addStream("BuffBandUp", core.Line, name .. ".BandUp", "BandUp", instance.parameters.clrBand, first);
        BuffBandUp:setWidth(instance.parameters.width);
        BuffBandUp:setStyle(instance.parameters.style);

        BuffBandDn = instance:addStream("BuffBandDn", core.Line, name .. ".BandDn", "BandDn", instance.parameters.clrBand, first);
        BuffBandDn:setWidth(instance.parameters.width);
        BuffBandDn:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if 
    period < first or not source:hasData(period) 
    then
        return;
	end

    LRL[period] =   mathex.lreg(source, period - PERIOD + 1, period)

    local sum=0;

    for i=period-PERIOD+1,period,1 do
        sum=sum+math.pow(source[i]-LRL[i],2)
    end

    local variance=math.sqrt(sum/PERIOD);

    for i=period-PERIOD+1,period,1 do
        BuffBandUp[i]=LRL[i]+Deviation*variance;
        BuffBandDn[i]=LRL[i]-Deviation*variance;
    end

    if LRL[period] > LRL[period-1] 
    then
        LRL:setColor(period, instance.parameters.Up);
    else
        LRL:setColor(period, instance.parameters.Dn);
    end

end

