-- Id: 4814
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7485

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

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("ADX ROC Value Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("ADX Parameters"); 
    indicator.parameters:addInteger("PERIOD", "Period", "", 14, 2, 2000);
	 indicator.parameters:addDouble("FastLevel", "FastLevel", "", 5, 0, 2000);
	  indicator.parameters:addDouble("SlowLevel", "SlowLevel", "", 2.5, 0, 2000);
	
	indicator.parameters:addGroup("Smoothing Parameters"); 
	 indicator.parameters:addInteger("SP", "ROC Period", "", 14, 1, 2000);
	
	indicator.parameters:addGroup("ADX Style"); 
	indicator.parameters:addColor("Fast", "Fast ROC Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Moderate", "Moderate ROC Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Slow", "Slow ROC Color", "", core.rgb(255, 0, 0));

	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local PERIOD;
local Fast, Moderate, Slow;
local FastLevel,  SlowLevel;
local Mode;

local SP;
local Smoothing;

local first;
local source = nil;  
local Oscillator;
local indicator;

-- Routine
function Prepare(nameOnly)
    SP= instance.parameters.SP;
    PERIOD= instance.parameters.PERIOD; 
	Fast= instance.parameters.Fast;	
	Moderate= instance.parameters.Moderate;
	Slow= instance.parameters.Slow;
	
	
	FastLevel= instance.parameters.FastLevel;		
	SlowLevel= instance.parameters.SlowLevel;
	
    source = instance.source; 
	
	
	    local name = profile:id() .. "(" .. source:name() .. ", "  .. PERIOD   .. ", "  .. FastLevel   .. ", "  .. SlowLevel  .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
    indicator = core.indicators:create("ADX", source,PERIOD);
	
     first = math.max( indicator.DATA:first()   )+SP+1;	
	
	 
	Oscillator= instance:addStream("Oscillator", core.Bar, name, "Oscillator", core.rgb(0, 0, 0), first)
	Oscillator:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)


    
  
	 indicator:update(mode);
	 
	if period < first   or not source:hasData(period) then
	Oscillator:setColor(period, core.rgb(128, 128, 128));
    return;
    end 
 
   
	
    Oscillator[period]= indicator.DATA[period]-indicator.DATA[period-SP+1]
 
	
	

      
				if  math.abs(indicator.DATA[period] - indicator.DATA[period-SP+1])  >= FastLevel then 
				Oscillator:setColor(period, Fast);
				elseif    math.abs(indicator.DATA[period] - indicator.DATA[period-SP+1])   <=  SlowLevel then
				Oscillator:setColor(period, Slow);	
				else
				Oscillator:setColor(period, Moderate);
				end
					  
end

