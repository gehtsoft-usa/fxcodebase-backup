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
      indicator:name("Trailing Min");
    indicator:description("Trailing Min");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 5);  
	
	indicator.parameters:addString("TF"  , "Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF"  , core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("ThePrice", "Price Source", "", "low");
    indicator.parameters:addStringAlternative("ThePrice", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("ThePrice", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("ThePrice", "LOW", "", "low");
    indicator.parameters:addStringAlternative("ThePrice","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("ThePrice", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("ThePrice", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("ThePrice", "WEIGHTED", "", "weighted");
	
	  indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("POC", "POC Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("Size", "Font Size", "", 8);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Size;
local BoxSize;
local source;
local ThePrice;
local first;  
local s;
local e;  
local BOX; 
local PocMark;
local BarSize;
local Signal;
local TF;
-- Routine
 function Prepare(nameOnly) 
    TF = instance.parameters.TF;
    BoxSize = instance.parameters.BoxSize; 
	ThePrice = instance.parameters.ThePrice;
	Size = instance.parameters.Size;	 
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. BoxSize .. ", " .. TF .. ", " .. ThePrice.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	PocMark= instance:createTextOutput ("POC", "POC", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.POC, 0);
    Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.POC, first );
    Signal:setStyle(core.LINE_NONE );
    local s1, e2;
	 s1, e2 = core.getcandle(TF, 0, 0, 0);
     BarSize= e2-s1;	 
	 
	 
end

local date; 
local Filter;
local FLAG;
-- Indicator calculation routine
function Update(period)
 
  
  
  local End = source:date(period);
  local Start=End-BarSize;
  
  if Start < source:date(source:first()) then
  Start = source:date(source:first());
  end
  

 
  MP (Start,End, period);
  
  
end

function MP (s,e, period)

 
 local j;
 local Max=0;
	 
	  
 
 local x= core.findDate(source, s, false);
 local y= core.findDate(source, e, false);
 
  if   (x <= 0  or y < 0) then
  return;
  end
 


  if   (x <= first  or y > source:size()-1) then
  return;
  end

  
							   
 
	local Profile={};
    local min, max;
    local Price;

	
	for j= x , y, 1 do	

                   
						   
 
						    Price =  source[ThePrice][j]/source:pipSize(); 
							min=Price - Price%BoxSize;
							max=min +BoxSize*source:pipSize();
 					 
		 
							if Profile[min] == nil then 
							Profile[min]=0;
							end
							  
			   
							Profile[min]= Profile[min]+1;	
 
							
				
							if Max  <  Profile[min]  then  
							Max=Profile[min];	
							PocMark:set(period, source[ThePrice][j], "\108");
	                        Signal[period]=  source[ThePrice][j];	
							core.host:execute ("setStatus", Max.. " - " .. min)
							end
							  
					end		
					
				 
 
end