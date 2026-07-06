-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8145


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
    indicator:name("Two Horizontal Lines Helper Tool");
    indicator:description("Two Horizontal Lines Helper Tool");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Upper", "Upper distance (Pips/%))", "Upper distance", 10);
    indicator.parameters:addDouble("Lower", "Lower  distance (Pips/%))", "Lower  distance ", 10);
  
     indicator.parameters:addString("Units", "Pips/Percentages", "", "Pips");
    indicator.parameters:addStringAlternative("Units", "Pips", "", "Pips");
    indicator.parameters:addStringAlternative("Units", "Percentages", "", "Percentages");
    
  
    indicator.parameters:addString("Price", "Price", "", "Close");
    indicator.parameters:addStringAlternative("Price", "Close", "", "Close");
    indicator.parameters:addStringAlternative("Price", "High/Low", "", "High/Low");
  
    indicator.parameters:addString("Mode", "Mode", "", "Live");
    indicator.parameters:addStringAlternative("Mode", "Live", "", "Live");
    indicator.parameters:addStringAlternative("Mode", "Previous", "", "Previous");   
    
     indicator.parameters:addGroup("Style");
     indicator.parameters:addString("Type", "Type", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Zone", "", "Zone");
    
    indicator.parameters:addColor("Top", "Top Line", "", core.rgb(255, 0, 0));
     indicator.parameters:addColor("Bottom", "Bottom Line", "", core.rgb(255, 0, 0));
     
     indicator.parameters:addColor("clr", "Channel color", "", core.rgb(0, 0, 255));
       indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Upper;
local Lower;
local Type;
local first;
local source = nil;
local Mode;
local Price;
local Units;

-- Streams block
local S1 = nil;
local S2 = nil;
local Units;
-- Routine
function Prepare(nameOnly)
    Price = instance.parameters.Price;
    Mode = instance.parameters.Mode;
    Upper = instance.parameters.Upper;
    Lower = instance.parameters.Lower;
    Type = instance.parameters.Type;
    Units = instance.parameters.Units;
    source = instance.source;
    first = source:first();
    
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. Upper .. ", " .. Lower .. ", " .. Units.. ", " .. Price.. ", " .. Mode .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    if Type == "Zone" then
    S1 = instance:addInternalStream(0, 0);
    S2 = instance:addInternalStream(0, 0);
    instance:createChannelGroup ("Zone", "Zone", S1, S2, instance.parameters.clr, 100 - instance.parameters.transparency);
    else
    S1 = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top, first);
    S2 = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom, first);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <= first  or not  source:hasData(period) or  period < source:size()-1 then
    return;
    end
    
    local High, Low;
    local PERIOD;
    
    if Mode == "Live" then
    PERIOD= period;
    else   
     PERIOD= period-1;
    end
    
    local PriceLow;
    local PriceHigh;
    
    if Price == "Close" then
    PriceLow = source.close[PERIOD];
    PriceHigh = source.close[PERIOD];
    else
    PriceHigh = source.high[PERIOD];
    PriceLow = source.low[PERIOD];
    end

    local TOP, BOTTOM; 
    if Units == "Pips" then
    TOP= Upper * source:pipSize();
    BOTTOM= Lower * source:pipSize();
    else
     TOP= (PriceHigh /100 ) *   Upper;
     BOTTOM= (PriceLow /100 ) *  Lower;
    end
    
      High = PriceHigh + TOP ;
      Low = PriceLow - BOTTOM;
        
    
        core.drawLine(S1, core.range(first, period ), High, first, High,  source:size()-1);
	core.drawLine(S2, core.range(first, period), Low, first, Low,  source:size()-1);
   
   
end

