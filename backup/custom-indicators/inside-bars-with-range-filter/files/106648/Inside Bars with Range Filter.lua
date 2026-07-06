
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63568

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
function Init()
    indicator:name("Inside Bars with Range Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 4);
	
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("LabelSize", "Font Size", "Font Size", 20);
    indicator.parameters:addColor("clrUP", "Color of Up Fractal", "Color of Up Fractal", core.rgb(255, 192, 0));
    indicator.parameters:addColor("clrDN", "Color of Down Fractal", "Color of Down Fractal", core.rgb(0, 192, 255));
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local LabelSize, LookBack;
local R = nil;
local S = nil;
 
-- Routine
function Prepare(nameOnly)  
   
 
	LookBack= instance.parameters.LookBack; 
	LabelSize= instance.parameters.LabelSize;
	 
    source = instance.source;
    first = source:first() + LookBack
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	R = instance:createTextOutput ("Up", "Up", "Wingdings", LabelSize, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    S = instance:createTextOutput ("Dn", "Dn", "Wingdings",  LabelSize, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
 
end

-- Indicator calculation routine
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
  
	R:setNoData(period);
	S:setNoData(period);
	
	
	
	    if  not ((source.high[period]<source.high[period-1])and (source.low[period]>source.low[period-1])) then
		return;
		end
		
		
		local Status=Filter(period);
		
		if Status then
		return;
		end
	   
	    if source.close[period-1]> source.open[period-1] then
		R:set(period , source.high[period], "\218", source.high[period]);  
        else		
        S:set(period , source.low[period], "\217", source.low[period]);		
        end
 
end
 
 function Filter(Start)
 local Status= false;
 
    for period= (Start-1), (Start-1-LookBack+1), -1  do
	    if ((source.high[period]-source.low[period])<(source.high[Start]-source.low[Start])) then
		Status=true;		
		end
	end
 
 return Status;
 end