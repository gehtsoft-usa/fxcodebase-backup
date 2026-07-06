-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69360

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
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
    indicator:name("Trend bands Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 10, 1, 2000);
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addColor("color3", "Neutral Bar Color", "", core.rgb(128, 128, 128));	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2 ; 
local first;
local source = nil;
 
local Line1, Line2;   

local Top1,Bottom1,Top2,Bottom2;

 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
 
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period1,Period2);
 
   
 
    Line1 = instance:addStream("Line1" , core.Bar, " Line1"," Line1",instance.parameters.color1, first);
    Line1:setPrecision(math.max(2, source:getPrecision())); 
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	local min1, max1 = mathex.minmax(source, period-Period2+1, period);
    local min2, max2 = mathex.minmax(source, period-Period1+1, period); 
 
	
	local First=max2-max1;
	local Second=min1-min2;
	
	if First> Second then
	Line1[period]=1;
	elseif Second> First then
	Line1[period]=-1;
	else
	Line1[period]=0;
	end
	
	if  Line1[period]==1 then
	Line1:setColor(period, instance.parameters.color1);
	elseif  Line1[period]==-1 then
	Line1:setColor(period,instance.parameters.color2);
	else
	Line1:setColor(period,instance.parameters.color3);
	end
	
 
end


 