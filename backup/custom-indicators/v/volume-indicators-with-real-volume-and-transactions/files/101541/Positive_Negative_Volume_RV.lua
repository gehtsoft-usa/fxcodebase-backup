-- Id: 14523

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Positiv Negativ Volume with Real volume/Transactions");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
	indicator.parameters:addString("Method", "Method", "Method" , "Price");
    indicator.parameters:addStringAlternative("Method", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Method", "Heikin Hashi", "Heiken Ashi" , "Heiken Ashi");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arriw Size", "", 10);
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "oOwn color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local volume; 
local Method;
local HA;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    Method=instance.parameters.Method;
	source = instance.source;
	   
    local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() .. ", "..Method;
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
	
	HA = core.indicators:create("HA",source);
	
	first= HA.DATA:first();
	 assert(source:supportsVolume(), "The source must have volume");
	volume = instance:addStream("PNV", core.Bar, name, "PNV", instance.parameters.Up, first );
    volume:setPrecision(math.max(2, instance.source:getPrecision()));
		
end

-- Indicator calculation routine
function Update(period, mode)


    HA:update(mode);
	
			if period < first then
			return;
			end
			        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end

		if Method == "Price" then	
		        if source.close[period]> source.open[period] then
				volume[period]= Ind.DATA[period];
				else
				volume[period]= -Ind.DATA[period];
				end
		else
		         if HA.close[period]> HA.open[period] then
				volume[period]= Ind.DATA[period];
				else
				volume[period]= -Ind.DATA[period];
				end
		end
			
		 if volume[period]> 0 then
		 volume:setColor(period,instance.parameters.Up);
		 else
		 volume:setColor(period, instance.parameters.Dn);
		 end
		
		 
 end

function AsyncOperationFinished(cookie, success, message)

end

