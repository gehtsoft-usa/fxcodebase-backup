-- Id: 6525
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18169


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("GHLA Super Trend Bar");
    indicator:description("GHLA Super Trend Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("GHLA Calculation");
	indicator.parameters:addInteger("G", "Number of Periods", "", 10);
    indicator.parameters:addGroup("Super Trend Calculation");  
    indicator.parameters:addInteger("S", "Number of periods", "No description", 10);
    indicator.parameters:addDouble("M", "Multiplier", "No description", 1.5);
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("No", "Color for No Trend", "", core.rgb(255, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local M,S,G;
local first;
local source = nil;

-- Streams block
local Indicator={};
local Out = nil;

-- Routine
function Prepare(nameOnly)
    M = instance.parameters.M;
    G = instance.parameters.G;
    S = instance.parameters.S;	
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(G) .. ", " .. tostring(S) .. ", " .. tostring(M) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("GHLA") ~= nil, "Please, download  GHLA.lua Indicator");
	assert(core.indicators:findIndicator("ST") ~= nil, "Please, download  ST.lua Indicator");
	
	 Indicator[1] = core.indicators:create("GHLA", source, G);
	 Indicator[2] = core.indicators:create("ST", source, S, M);

	 
	 first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first());

    
        Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.Up, first);
		Out:addLevel(0);
    Out:setPrecision(math.max(2, instance.source:getPrecision())); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < period or  not source:hasData(period) then
	return;
	end
	
	 Indicator[1]:update(mode);
	 Indicator[2]:update(mode);
	
	 
	  Out[period] = 1;
	 
	 if source.close[period] > Indicator[1].DATA[period]
	 and source.close[period] > Indicator[2].DATA[period]
	 then
	  Out:setColor(period, instance.parameters.Up);  
	 elseif source.close[period] < Indicator[1].DATA[period]
	 and source.close[period] < Indicator[2].DATA[period]
	 then
	  Out:setColor(period, instance.parameters.Dn);  
	 else
	  Out:setColor(period, instance.parameters.No);  
	 end
	
       
    
end

