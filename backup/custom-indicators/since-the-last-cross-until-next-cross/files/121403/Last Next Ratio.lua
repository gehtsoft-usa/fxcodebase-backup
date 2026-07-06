-- Id: 22407
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66705

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
    indicator:name("Last Next Ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addInteger("Cutoff", "Cutoff", "", 14, 1, 2000);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 28, 1, 2000);
	
	
 
	indicator.parameters:addString("Price1", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 100, 1, 2000);
 
	indicator.parameters:addString("Price2", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local  Price1, Period1;
local  Price2, Period2; 
local first;
local source = nil;
 
local Oscillator;  
local MA1, MA2;
local Cutoff;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Price1 = instance.parameters.Price1;
	
	Period2= instance.parameters.Period2;
    Price2 = instance.parameters.Price2;
	
	Cutoff = instance.parameters.Cutoff;
	
	
	local Parameters= Cutoff ..  ", " .. Period1 ..  ", " .. Price1..  ", " ..Period2  ..  ", " .. Price2;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.BIN indicator");
			
    source = instance.source;
    
  
    MA1 = core.indicators:create("CMA", source[Price1], Period1);
    MA2 = core.indicators:create("CMA", source[Price2], Period2);
    
    first=math.max(MA1.DATA:first(), MA2.DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    MA2:update(mode);
	
	
    if period < first then
	return;
	end
	
	
	local Last=FindLast(period);
	
	local Next=FindNext(period);
	
	 if Next > Last	 then
	 Oscillator[period]=1;
	 else
	 Oscillator[period]=Next/Last;
	 end
				  
end


function FindNext(period)
local Return=0;

local Delta1=MA1.DATA[period]-MA1.DATA[period-1];
local Delta2=MA2.DATA[period]-MA2.DATA[period-1]; 


if math.abs((MA1.DATA[period]+1*Delta1)- (MA2.DATA[period]+1*Delta2)) > math.abs(MA1.DATA[period]- MA2.DATA[period]) then
return Cutoff;
end


local i=1;

while true do

   
	if ((MA1.DATA[period]+i*Delta1)< (MA2.DATA[period]+i*Delta2) and MA1.DATA[period]>= MA2.DATA[period])
	or ((MA1.DATA[period]+i*Delta1)> (MA2.DATA[period]+i*Delta2) and MA1.DATA[period]<= MA2.DATA[period])
	then
	Return=i;
	break;
	end
	 
	if i > Cutoff then
	break;
	end
	
    i= i+1;

end	

 

if i > Cutoff then
  return Cutoff;
 else
 return Return;
 end

end


function FindLast(period)
local Return=0;

for i= period-1, first, -1 do


	if (MA1.DATA[i]< MA2.DATA[i] and MA1.DATA[period]>= MA2.DATA[period])
	or (MA1.DATA[i]> MA2.DATA[i] and MA1.DATA[period]<= MA2.DATA[period])
	then
	Return=i;
	break;
	end


end

return period-Return;

end


