-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69133

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Simple Support Resistance");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	
	
 
	indicator.parameters:addGroup("Pivot");
	
	indicator.parameters:addInteger("Minimum", "Minimum", "", 100);
	indicator.parameters:addString("PivotTF", "Pivot Time frame", "", "D1");
    indicator.parameters:setFlag("PivotTF", core.FLAG_PERIODS);
    indicator.parameters:addString("CalcMode", "Calculation mode", "The mode of pivot calculation.", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Classic Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Minimum; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Average;
local ItIs;
-- Routine
 function Prepare(nameOnly)   
 
 
 
	  Minimum=instance.parameters.Minimum;
	
	local Parameters=Minimum;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
			
    source = instance.source; 
	
	 Pivot = core.indicators:create("PIVOT", source ,instance.parameters.PivotTF , instance.parameters.CalcMode, "HIST" ); 
    first=Pivot.DATA:first(); 
	
 
 
	Oscillator1 = instance:addStream("Oscillator2" , core.Line, " Top"," Top",instance.parameters.color1, first);
	Oscillator1:setWidth(instance.parameters.width);
    Oscillator1:setStyle(instance.parameters.style);
    Oscillator1:setPrecision(math.max(2, source:getPrecision()));
   Oscillator2 = instance:addStream("Oscillator2" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first);
	 Oscillator2:setWidth(instance.parameters.width);
    Oscillator2:setStyle(instance.parameters.style);
    Oscillator2:setPrecision(math.max(2, source:getPrecision()));
	
	ItIs=false;
	
	core.host:execute ("setTimer", 1, 1);
 
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- Indicator calculation routine
function Update(period, mode)

 
	Pivot:update(core.UpdateLast);

 
	if period < source:first() 
	then
	return;
	end
	local Top=FindTop(period);
    local Bottom=FindBottom(period);
	 if Top~= 0 then
     Oscillator1[period]=Top;
	 else
	 Oscillator1[period]=Oscillator1[period-1];
	 end
	 if Bottom~= 0 then
	 Oscillator2[period]=Bottom;
	 else
	  Oscillator2[period]=Oscillator2[period-1];
	 end
				  
end


 

function FindBottom(period)

local Value =0;

local Flag=false;

for i= 1, 4 , 1 do 

if Pivot:getStream(i)[period]< (source.low[period]- Minimum*source:pipSize()) then
Value= Pivot:getStream(i)[period]
 Flag=true;
end



if Flag == true then
break;
end
end

return Value;
end



function FindTop(period)

local Value =0;

local Flag=false;

for i= 5, 8 , 1 do 

if Pivot:getStream(i)[period]> (source.high[period]+ Minimum*source:pipSize()) then
Value= Pivot:getStream(i)[period]
 Flag=true;
end



if Flag == true then
break;
end
end

return Value;
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    if ItIs then
	return;
	end
	
	ItIs=true;
	
    if cookie== 1 then
	 instance:updateFrom(0);	
 
        
    return core.ASYNC_REDRAW ;
	end
end

