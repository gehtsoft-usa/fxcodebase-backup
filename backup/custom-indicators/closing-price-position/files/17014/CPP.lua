-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7662

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Closing Price Position");
    indicator:description("Closing Price Position");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
      indicator.parameters:addGroup("Calculation");	  
    indicator.parameters:addDouble("High", "High(%)", "", 75);
    indicator.parameters:addDouble("Low", "Low(%)", "", 25);
	indicator.parameters:addDouble("Shift", "Vertical Shift (in Pips)", "", 10);
	 indicator.parameters:addGroup("Style");
	 
	 indicator.parameters:addString("Type", "Body/Wick", "", "Label");
    indicator.parameters:addStringAlternative("Type", "Label", "", "Label");
    indicator.parameters:addStringAlternative("Type", "Overlay", "", "Overlay");
	 indicator.parameters:addStringAlternative("Type", "Both", "", "Both");
	 
    indicator.parameters:addColor("UP", "Color of Top Range Candle", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color of Bottom Range Candle", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NE", "Color of Mid Range Candle", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("Lbl_color", "Color of labels", "Color of labels", core.rgb(0, 0, 0));    
    indicator.parameters:addInteger("FontSize", "Font size", "", 8);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local High;
local Low;
local UP, DN, NE;

local first;
local source = nil;

-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;

local  Label;
local idp;
local Shift;
local Type;

-- Routine
function Prepare(nameOnly)
     Type = instance.parameters.Type;
	 Shift = instance.parameters.Shift;
    UP = instance.parameters.UP;
	DN = instance.parameters.DN;
	NE = instance.parameters.NE;
	
    High = instance.parameters.High;
    Low = instance.parameters.Low;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. High .. ", " .. Low .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name .. ".open", "open",  core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name .. ".low", "low",  core.rgb(0, 0, 0), first);
	
	 instance:createCandleGroup("LS", "LS", open, high, low, close);
	 
	  Label = instance:createTextOutput ("Lbl", "Lbl", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.Lbl_color, first);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first and not source:hasData(period) then
	return;
	end
	
    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
		local One=  (source.high[period] -source.low[period]) /100;
        local Percentage=  (source.close[period]-source.low[period])/ One;	
		
		if Type ~= "Label"	then	 
     		if  Percentage > High  then 
			open:setColor(period, UP);	
			elseif  Percentage < Low then 
			open:setColor(period, DN);	
			else
            open:setColor(period, NE);				
			end	
		end
		
	if Type ~= "Overlay"	then	 
	Label:set(period, source.high[period] +Shift*source:pipSize() , tostring(round(Percentage, 2) ) , "");
	end
    
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

