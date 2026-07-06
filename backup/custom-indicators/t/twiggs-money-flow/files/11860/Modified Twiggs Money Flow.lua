-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4782

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

--[[Twiggs Money Flow is a proprietary indicator. 
Readers are permitted to explain/describe Twiggs Money Flow on other websites/publications and/or to include/reproduce the formula in other software,
 provided that they display a hyperlink to this web page.
 http://www.incrediblecharts.com/indicators/twiggs_money_flow.php
]]
function Init()
    indicator:name("Modified Twiggs Money Flow");
    indicator:description("Modified Twiggs Money Flow");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculate");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 21);
	 indicator.parameters:addDouble("Level", "Level", "Level", 0.2499);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMF_color", "Color of TMF", "Color of TMF", core.rgb(0, 0, 255));
	 indicator.parameters:addColor("TMFF_color", "Color of TMFF", "Color of TMFF", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("TMFM_color", "Color of TMFM", "Color of TMFM", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Level;
local first;
local source = nil;

-- Streams block
local TMF = nil;
local EMA={};

local ADV;
local tmfm, tmff;
-- Routine
 function Prepare(nameOnly)   
 
 

    PERIOD = instance.parameters.PERIOD;
	Level= instance.parameters.Level;
	
	   local name = profile:id() .. "(" ..  instance.source:name().. ", " ..  PERIOD.. ", " ..  Level    .. ")";
    instance:name(name); 

	
	
    if   (nameOnly) then
        return;
    end

	
	
    source = instance.source;	
	
	ADV= instance:addInternalStream (0, 0);
	
	if not source:supportsVolume () then
	end
    
    EMA["VOLUME"] = core.indicators:create("WMA", source.volume, PERIOD);	
	 EMA["ADV"] = core.indicators:create("WMA", ADV, PERIOD);	
    first = math.max( EMA["VOLUME"].DATA:first(), EMA["ADV"].DATA:first());

   
	
    TMF = instance:addStream("TMF", core.Line, name, "TMF", instance.parameters.TMF_color, first);
	TMF:setWidth(instance.parameters.width);
    TMF:setStyle(instance.parameters.style);  
	TMF:setPrecision (10);
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local TRH = math.max ( source.high[period], source.close[period-1]);
    local TRL  = math.min ( source.low[period],  source.close[period-1]);
	local TR=TRH-TRL;
	
	ADV[period]=((source.close[period]-TRL)-(TRH-source.close[period]))/ TR;
	
	if period < EMA["ADV"].DATA:first() then
	return;
	end
	
	 EMA["ADV"]:update(mode);
	EMA["VOLUME"]:update(mode);
	
	if EMA["VOLUME"].DATA[period]==0 then 
	TMF[period]=0;
	else
	TMF[period] =  EMA["ADV"].DATA[period]/EMA["VOLUME"].DATA[period];
	end    
	
		if(TMF[period]>Level) then
		TMF:setColor(period,  instance.parameters.TMFF_color); 
		elseif(TMF[period]<-Level) then
		TMF:setColor(period,  instance.parameters.TMFM_color);
		else
	   TMF:setColor(period,  instance.parameters.TMF_color);
		end
	end

 