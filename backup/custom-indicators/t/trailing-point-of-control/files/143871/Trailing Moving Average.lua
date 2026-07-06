-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71553

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
      indicator:name("Trailing Moving Average");
    indicator:description("Trailing Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
      indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addString("TF"  , "Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF"  , core.FLAG_PERIODS);
	
	  indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(127, 127, 127));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block 
local source;
local first;   
local BarSize;
local Line;
local TF;
-- Routine
 function Prepare(nameOnly) 
    TF = instance.parameters.TF; 
    source = instance.source;
    first = source:first(); 
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. TF.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 
    Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first );
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    local s1, e2;
	 s1, e2 = core.getcandle(TF, 0, 0, 0);
     BarSize= e2-s1;	 
	 
	 
end

local Average=0;
local Count=0;

-- Indicator calculation routine
function Update(period)
 
  
  
  local End = source:date(period);
  local Start=End-BarSize;
  
  if Start < source:date(source:first()) then
  Start = source:date(source:first());
  end
  
  Average=0;
  Count=0; 
  
  MP (Start,End);
  
  if Count~=0 then
  Line[period]=Average/Count;	
  end  
end

function MP (s,e)

 
	 
	  
 
 local x= core.findDate(source, s, false);
 local y= core.findDate(source, e, false);
 
  if   (x <= 0  or y < 0) then
  return;
  end
 


  if   (x <= first  or y > source:size()-1) then
  return;
  end
	 
				 
	for period = x, y, 1 do
	Count=Count+1;
	Average=Average+source[period];
    end	
					          

end
