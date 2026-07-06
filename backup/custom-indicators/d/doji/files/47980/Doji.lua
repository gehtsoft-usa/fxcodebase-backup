-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 8035

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
    indicator:name("Doji Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	 indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Type", "Doji Type", "", "All");
    indicator.parameters:addStringAlternative("Type", "All Types", "", "All");
    indicator.parameters:addStringAlternative("Type", "Dragonfly/Gravestone Doji", "", "Dragonfly/Gravestone");
     indicator.parameters:addInteger("Trend", "Trend Period", " ", 1);
    indicator.parameters:addInteger("Delta", "Open/Close difference (% of body length)", " ", 5);
	indicator.parameters:addInteger("Wick", "Dragonfly / Gravestone Doji max. Wick Size(% of body length)", " ", 5);
	 
	 indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Top", "Color Doji", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Color Doji", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("No", "Color Doji", " ", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("Size", "Font Size", " ", 10);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta=nil;

local first;
local source = nil;
local Size;
-- Streams block
local up = nil;
local down = nil;
local no;
local Wick;
local Type;
local Trend;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Trend =  instance.parameters.Trend;
    first = source:first()+Trend;
	Type =  instance.parameters.Type;
	Size =  instance.parameters.Size;
	Delta =  instance.parameters.Delta;
	Wick =  instance.parameters.Wick;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, first);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, first);
	no = instance:createTextOutput ("Neutral", "Neutral", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.No, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <  first  then
	return;
	end
	
	up:setNoData (period);
	down:setNoData (period);
	no:setNoData (period);
	
	local Percentage = (source.high[period]- source.low[period])/100;
	local Diff = (source.open[period]- source.close[period]) / Percentage ;
	local Label;
	
	
	
	              if math.abs(Diff) <= Delta then
				  
							
							if Type == "All" then
						  
								   if  ( source.high[period] - math.max (source.open[period] ,source.close[period] )) / Percentage    <  Wick then
								   Label = "Dragonfly  Doji";	
								   down:set(period, source.low[period], "\225", Label);			   
							      elseif  (  math.min (source.open[period] ,source.close[period] ) -source.low[period] ) / Percentage    <  Wick then
								   Label = "Gravestone  Doji";
									up:set(period, source.high[period], "\226", Label);
								  else			
							  
							 					 
								 
										  Label = "Doji";
									  
										  if source.open[period-1-Trend]  < source.open[period]  then
										  up:set(period, source.high[period], "\226", Label);
										  elseif source.open[period-1-Trend]  > source.open[period]  then
										  down:set(period, source.low[period], "\225", Label);
										  else
										  no:set(period, source.low[period], "\225", Label);
										  end
										  
								  end
							
						  elseif Type == "Dragonfly/Gravestone" then 
						      
							  
							     if  ( source.high[period] - math.max (source.open[period] ,source.close[period] )) / Percentage    <  Wick then
								   Label = "Dragonfly  Doji";	
								   down:set(period, source.low[period], "\225", Label);			   
							      elseif  (  math.min (source.open[period] ,source.close[period] ) -source.low[period] ) / Percentage    <  Wick then
								   Label = "Gravestone  Doji";
									up:set(period, source.high[period], "\226", Label);
						         end
						  end
				end		  
end	 

