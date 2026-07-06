-- Id: 13547

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61780

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
    indicator:name("Guppy Count Back Line");
    indicator:description("Guppy Count Back Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("Out1_color", "Color of Out1", "Color of Out1", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	
	indicator.parameters:addColor("Out2_color", "Color of Out2", "Color of Out2", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Out3_color", "Color of Out3", "Color of Out3", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	
	indicator.parameters:addColor("Out4_color", "Color of Out4", "Color of Out4", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Out5_color", "Color of Out5", "Color of Out5", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Out6_color", "Color of Out6", "Color of Out6", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local V1,V2,V3,V4;
local LOW, HIGH;
local Out1,Out2,Out3,Out4;
 

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+3;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	LOW=source.low;
	HIGH=source.high;

    V1 = instance:addInternalStream(0, 0);  
	V2 = instance:addInternalStream(0, 0);
	V3 = instance:addInternalStream(0, 0);
	V4 = instance:addInternalStream(0, 0);
	
	Out1 = instance:addStream("Out1", core.Dot, name .. ".Out1", "Out1", instance.parameters.Out1_color, first);
	Out1:setWidth(instance.parameters.width1);
    
		
	Out2 = instance:addStream("Out2", core.Line, name .. ".Out2", "Out2", instance.parameters.Out2_color, first);
	Out2:setWidth(instance.parameters.width2);
    Out2:setStyle(instance.parameters.style2);
	
	Out3 = instance:addStream("Out3", core.Dot, name .. ".Out3", "Out3", instance.parameters.Out3_color, first);
	Out3:setWidth(instance.parameters.width3);
  
	
	Out4 = instance:addStream("Out4", core.Line, name .. ".Out4", "Out4", instance.parameters.Out4_color, first);
	Out4:setWidth(instance.parameters.width4);
    Out4:setStyle(instance.parameters.style4);
	
	Out5 = instance:addStream("Out5", core.Line, name .. ".Out5", "Out5", instance.parameters.Out5_color, first);
	Out5:setWidth(instance.parameters.width5);
    Out5:setStyle(instance.parameters.style5);
	
	Out6 = instance:addStream("Out6", core.Line, name .. ".Out6", "Out6", instance.parameters.Out6_color, first);
	Out6:setWidth(instance.parameters.width6);
    Out6:setStyle(instance.parameters.style6);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < first then
	return;
    end

    period=period-2; 
  
	if   ((LOW[period] < LOW[period+1]) and (LOW[period] < LOW[period-1])) then
	V1[period] = 1;
	else
	V1[period] = 0;
	end
	
    if ((HIGH[period] > HIGH[period+1]) and (HIGH[period+1] > HIGH[period+2])) then
	V2[period] = 1;
	else
	V2[period] = 0;
	end
	
	
    if  (((HIGH[period] > HIGH[period+1]) and (HIGH[period] > HIGH[period-1]))) then
	V3[period] =1;
	else
	V3[period] =0;
	end
	
    if  ((LOW[period] < LOW[period+1]) and (LOW[period+1] < LOW[period+2]))then
	V4[period] =1;
	else
	V4[period] =0;
	end
	
	if((V1[period] > 0.5))then 
	Out1[period]= LOW[period];
	else 
	Out1[period]=Out1[period-1] ;
	end
	
	
	
  if  ((V2[period-2] > 0.5)and (V1[period] > 0.5)) then 
  Out2[period]=HIGH[period-2];
  else 
  Out2[period]=Out2[period-1];
  end
     
   if V3[period] > 0.5 then 
   Out3[period] = HIGH[period];
   else 
   Out3[period] =Out3[period-1];
   end
   
   
   
  if ((V4[period-2] > 0.5)and(V3[period] > 0.5)) then
  Out4[period]=LOW[period-2];
  else 
  Out4[period]=Out4[period-1];
  end
 

  if Out4[period] < Out3[period] then 
  Out5[period]=Out4[period] - (Out3[period] - Out4[period]);
  else 
  Out5[period]=nil;
  end
  
  if Out2[period] > Out1[period] then 
  Out6[period]=Out2[period] + (Out2[period] - Out1[period]);
  else 
  Out6[period]=nil;
  end
 
end   
 