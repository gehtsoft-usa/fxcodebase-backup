
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63735

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Period Donchian channel ");
    indicator:description("Period Donchian channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
   
   
	
   indicator.parameters:addGroup("Parameters");
   
  indicator.parameters:addInteger("Period", "Period", "", 20);
   
   indicator.parameters:addString("TF", "Base Unit", "", "H1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
   
   indicator.parameters:addBoolean("sm"  , "Show middle line", "", false);	
	
	
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
 
end
  
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 
local first;
local source = nil;
local TF; 


local s=nil
local e=nil;
local START=nil;
 
local sm;
 local dn = nil;
local du = nil;
local dm = nil;
local Period;
function Prepare(nameOnly) 
    
    TF=instance.parameters.TF;
    source = instance.source;
    first = source:first();
	sm=instance.parameters.sm;
	Period=instance.parameters.Period;
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

   
   if   (nameOnly) then
        return;
    end
    
    du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.width3);
        dm:setStyle(instance.parameters.style3);
	else
	    dm = instance:addInternalStream(first, 0);
    end
   

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period< first or not  source:hasData(period) then
	return;
	end
   
    local i;
            
             s, e = core.getcandle(TF, source:date(period),0, 0);
             START = core.findDate (source, e-(e-s)*Period, false);    
     
	if START <0  then
	return;
	end	 
    
     local Min=0;
	 local Max=0;
	 local Number=0;
     for i=  START , period, 1 do
	 Max=math.max(Max, source.high[i]);
	 
		 if i==  START then
		 Min=source.low[i];
		 end
	 
	 Min=math.min(Min, source.low[i]); 
     end	 
	   dn[period]=Min;
	   du[period]=Max;
       dm[period] = (du[period] + dn[period]) / 2;
    
   
end
