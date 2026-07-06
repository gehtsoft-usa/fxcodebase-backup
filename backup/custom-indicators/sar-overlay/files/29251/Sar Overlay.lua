-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15523
-- Id: 6253

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Sar Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("SAR Calculation");
	 indicator.parameters:addDouble("Step", "Short EMA", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);
	

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("DnDn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 0));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Max, Step, Period;

local DMI;
local SAR;


function Prepare(nameOnly)
    Period= instance.parameters.Period;
	Max= instance.parameters.Max;
	Step= instance.parameters.Step;
	source = instance.source;
    local name = profile:id() .. "(" .. source:name() ..", ".. Step..", " .. Max .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	SAR=core.indicators:create("SAR",  source, Step, Max);
	first= math.max(SAR.UP:first(), SAR.DN:first());

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			return;
			end
	

    local ONE=nil;

	
			
			   SAR:update(mode);
		
		
		
		    if SAR.DN:hasData(period) then
			ONE = true;
			else
			ONE = false;
			end  
	
		
	
		
		 
		
		if  ONE == nil  then
		open:setColor(period, instance.parameters.No);	   
		elseif ONE    then		
		open:setColor(period, instance.parameters.UpUp);
        elseif  not ONE   then
		open:setColor(period, instance.parameters.DnDn);		
		end
		
		
				

		
 end


