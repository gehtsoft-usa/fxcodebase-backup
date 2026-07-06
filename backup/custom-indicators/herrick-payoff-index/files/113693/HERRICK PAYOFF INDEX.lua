-- Id: 18718
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64939

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
    indicator:name("HERRICK PAYOFF INDEX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("pointValue", "point Value", "point Value", 100);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up Trend", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down Trend", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral Trend", " ", core.rgb(128, 128, 128));
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Up, Down, Neutral;
local first;
local source = nil;
local pointValue;
local HPI;
local k;
-- Routine
function Prepare(nameOnly)
    pointValue = instance.parameters.pointValue;
    source = instance.source; 
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
 
	first=source:first()+1;
		
    local name = profile:id() .. " (" .. source:name() .. ", " .. pointValue ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
	k = instance:addInternalStream(0, 0);
   
    HPI = instance:addStream("HPI", core.Bar, name, "HPI", Neutral, first);
    HPI:setPrecision(math.max(2, instance.source:getPrecision()));
 
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )
 
 

local prevOpen = source.open[period-1];
local prevHigh = source.high[period-1];
local prevLow = source.low[period-1];
local prevClose = source.close[period-1];
local median =source.median[period];
local prevMedian =source.median[period-1];

local i = math.abs(source.close[period] - prevClose);
local g = math.min(source.open[period], prevOpen);


k[period] = (median-prevMedian) * pointValue * source.volume[period];
local temp = 1 + ((i/2) / g);

if (median < prevMedian) then temp = 1 - ((i/2) / g); end
k[period] = k[period] * temp;

local prevK = k[period-1]


HPI[period]=  prevK + (k[period] - prevK);

if HPI[period]> 0 then
HPI:setColor(period, Up);
elseif HPI[period]< 0 then
HPI:setColor(period, Down);
else
HPI:setColor(period,Neutral);
end


end

