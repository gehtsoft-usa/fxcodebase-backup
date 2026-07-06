-- Id: 12765
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61357

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
    indicator:name("Equilibrium Cross");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
 
    indicator.parameters:addInteger("Period", "Period", "", 14); 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000);
	
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Size;
	local first;
	local source = nil; 
	local Indicator;
	local font;
    local PeriodPeriod

-- Routine
function Prepare(nameOnly)
    Size = instance.parameters.Size;
	Period= instance.parameters.Period;
    source = instance.source;
 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

	font  = core.host:execute("createFont", "Wingdings", Size, false, false);

    Indicator = core.indicators:create("DMI", source, Period);
	first= Indicator.DATA:first() ; 		
	 
 end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
    Indicator:update(mode);
    if period < first+1 then
	return;
	end
	
	       if  core.crossesOver(Indicator.DIP, Indicator.DIM,period) then    
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top ,
                             font , instance.parameters.Up, "\225");
           elseif core.crossesUnder(Indicator.DIP, Indicator.DIM,period) then 
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
                             font , instance.parameters.Down, "\226");
			else
			core.host:execute ("removeLabel", source:serial(period));
            end			

	 
	  
   
    
     
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
 
end	    