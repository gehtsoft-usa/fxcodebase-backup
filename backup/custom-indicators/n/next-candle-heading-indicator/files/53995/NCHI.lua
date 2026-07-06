-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31660

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
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Next Candle Heading indicator");
    indicator:description("Next Candle Heading indicator");
    indicator:requiredSource(core.Bar);	
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
	indicator.parameters:addBoolean("Historical", "Show Historical Indications", "", true);
    indicator.parameters:addDouble("Percentage", "Filter Percentage (%)", "", 20);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Filter,Percentage,Historical;

local first;
local source = nil;
local One;
-- Streams block
local Up,Dn;

-- Routine
function Prepare(nameOnly)
    Filter = instance.parameters.Filter;
	Historical = instance.parameters.Historical;
	Percentage = instance.parameters.Percentage;
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Filter)  .. ", " .. tostring(Percentage).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 assert (source:supportsVolume (), "The chosen source don't supports the trading volume!");

 
    Up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.UPclr, first);
    Dn = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.DNclr, first);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end	
	
	One = (source.high[period]-source.low[period])/100;
	
	if not Historical then
    Dn:setNoData(period-1);
	Up:setNoData(period-1);
	end
	
	Dn:setNoData(period);
	Up:setNoData(period);
	
	local Volume= (source.volume[period]-source.volume[period-1] ) / (source.volume[period-1]/100);
	
	local volume = nil;	
	local current= nil;
	local previous=nil;
	
	if Volume > 100 then
	volume = "Up"
	end	
	
	if Volume < -50 then
	volume = "Down"
	end	
		
	if ( source.close[period] < source.open[period]) then
	current = "Up";
	else
	current = "Down";
	end
	
	if ( source.close[period-1] > source.open[period-1]) then
	previous = "Up";
	else
	previous = "Down";
	end
	
	
	if volume=="Up" then	
	       --1. 
			if current ~= previous	then
			
			   if current== "Up" then
			   UP(period);	
			   else
			   DOWN(period);	
			   end
			
			end
			
			--2.
			
			if current == previous	then
			
			   if current== "Up" then
			   DOWN(period);	
			   else
			   UP(period);	
			   end
			
			end
	
	end
	


    if volume=="Down" then
				--3.
				
				if current ~= previous	then
				
				   if current== "Up" then
				   UP(period);	
				   else
				   DOWN(period);	
				   end
				
				end
				
				--4.
				
				if current == previous	then
				
				   if current== "Up" then
				   DOWN(period);	
				   else
				   UP(period);	
				   end
				
				end
				
	
	end

  
		
 end

 
 
 function UP(period) 
 
 
 
 if ( Percentage )<  ((source.high[period]- math.max(source.open[period],source.close[period] ) ) /One ) and Filter then
 return;
 end
 
 
 
 
 Up:set(period, source.low[period], "\225");
     
 end
 
 function DOWN(period)
 
 if (Percentage )<  ((math.min (source.open[period],source.close[period] ) -source.low[period] ) /One ) and Filter then
 return;
 end
 
  Dn:set(period, source.high[period],"\226");
 end

