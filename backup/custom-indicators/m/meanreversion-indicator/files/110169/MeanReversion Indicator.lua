-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64229

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
    indicator:name("MeanReversion Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
   
   
	
   indicator.parameters:addGroup("Parameters");
   
  indicator.parameters:addInteger("Length", "Length", "", 20);
  indicator.parameters:addInteger("MA_Length", "MA Length", "", 50);
	
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clrMA", "Color of the ma line", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
 
end
  
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 
local first;
local source = nil;
 
 

 
local sm;
local dn = nil;
local du = nil;
local dm = nil;
local ma=nil;
local Length,MA_Length;
local low, high;
function Prepare(nameOnly)
    
     
    source = instance.source;
    
	Length=instance.parameters.Length;
	MA_Length=instance.parameters.MA_Length;
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first()+ math.max(MA_Length, Length);
    
   
 
    
    du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
   
    dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
	dm:setWidth(instance.parameters.width3);
    dm:setStyle(instance.parameters.style3);
	
	ma = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.clrMA,  first)
	ma:setWidth(instance.parameters.width4);
    ma:setStyle(instance.parameters.style4);
	 
   

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period< first or not  source:hasData(period) then
	return;
	end
   
    local min,max=mathex.minmax(source, period-Length+1, period);
            
     if source.low[period]== min then
	 low=min;
	 end
	 
     if source.high[period]== max then
	 high=max;
	 end
	 
	 if high== nil or low== nil then
	 return;
	 end
	 
	   dn[period]=min;
	   du[period]=max;
       dm[period] = (high+low) / 2;
	   ma[period]=mathex.avg(source.close, period-MA_Length+1, period);
    
   
end
