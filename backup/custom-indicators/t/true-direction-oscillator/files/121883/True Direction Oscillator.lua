-- Id: 22589
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66877
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

function Init()
    indicator:name("True Direction Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 0, 2000);	 
    indicator.parameters:addInteger("Period2", "1. Period", "", 20, 0, 2000);
    indicator.parameters:addInteger("Period3", "2. Period", "", 40, 0, 2000);	 
    indicator.parameters:addInteger("Period4", "3. Period", "", 80, 0, 2000);
	indicator.parameters:addInteger("Period5", "4. Period", "", 160, 0, 2000);
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color3", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period={}; 
local first;
local source = nil;
 
local Oscillator;  
local Bars; 
local Data={};
-- Routine
 function Prepare(nameOnly)   
 
    Period[1]= instance.parameters.Period1;
	Period[2]= instance.parameters.Period2;
	Period[3]= instance.parameters.Period3;
	Period[4]= instance.parameters.Period4;
	Period[5]= instance.parameters.Period5;
	
    
	
	
	local Parameters= Period[1] ..  ", " .. Period[2] ..  ", " .. Period[3]..  ", " ..Period[4] ..  ", " .. Period[5];
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period[1] ,Period[2], Period[3],Period[4] , Period[5]);
	
	for i= 1, 5, 1 do 
    Data[i] = instance:addInternalStream(0, 0);
    end
	
	Oscillator = instance:addStream("TDO" , core.Line, " TDO"," TDO",instance.parameters.color, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Bars= instance:addStream("Signal" , core.Bar, " Signal"," Signal",instance.parameters.color3, first);
    Bars:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period )


     if period < first then
	return;
	end



   for i= 1, 5, 1 do
   Add(i,period);
   end
   
  
		
     Oscillator[period]=Data[1][period];	

     Bars[period]=Oscillator[period]; 
	 
	 if Data[1][period] >0  and  Data[2][period] >0 and  Data[3][period] >0  and  Data[4][period] >0 and  Data[5][period] >0 then
	 Bars:setColor(period, instance.parameters.color1);
	 elseif Data[1][period] <0  and  Data[2][period] <0 and  Data[3][period] <0  and  Data[4][period] <0 and  Data[5][period] <0 then
	 Bars:setColor(period, instance.parameters.color2);
	 else
	 Bars:setColor(period, instance.parameters.color3);
	 end
end


function Add(id, period)


local A=source[period];
local B=source[period-Period[id]+1];
local Center = (A + B)/2;

Data[id][period]=100*(A-B)/Center;

end
