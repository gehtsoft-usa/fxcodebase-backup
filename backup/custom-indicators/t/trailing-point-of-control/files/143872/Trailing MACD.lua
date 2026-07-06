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
      indicator:name("Trailing MACD");
    indicator:description("Trailing MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
      indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addString("TF1"  , "Short Time Frame ", "", "H4");
    indicator.parameters:setFlag("TF1"  , core.FLAG_PERIODS);

	indicator.parameters:addString("TF2"  , "Long Time Frame ", "", "H8");
    indicator.parameters:setFlag("TF2"  , core.FLAG_PERIODS);

	indicator.parameters:addString("TF3"  , "Signal Time Frame ", "", "H6");
    indicator.parameters:setFlag("TF3"  , core.FLAG_PERIODS);	
	  indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("color1", "Short Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Long Line Color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addColor("color3", "Historgam Color", "", core.rgb(0, 0, 255));	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block 
local source;
local first;   
local Line1,Line2,Line3;
local TF1,TF2,TF3;
-- Routine
 function Prepare(nameOnly) 
    TF1 = instance.parameters.TF1; 
    TF2 = instance.parameters.TF2; 
    TF3 = instance.parameters.TF3; 	
    source = instance.source;
    first = source:first(); 
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. TF1.. ", " .. TF2.. ", " .. TF3.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 
    Line1 = instance:addStream("Line1" , core.Line, "1. Line","1. Line",instance.parameters.color1, first );
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
	
    Line2 = instance:addStream("Line2" , core.Line, "2. Line","2. Line",instance.parameters.color2, first );
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);	


    Line3 = instance:addStream("Line3" , core.Bar, "Histogram","Histogram",instance.parameters.color3, first );
 
end

local Average=0;
local Count=0;

-- Indicator calculation routine
function Update(period)
 
  
  
Line1[period]=MP(source, period, TF1)-MP(source,period, TF2);
Line2[period]=MP(Line1, period, TF3);  
Line3[period]=Line1[period]-Line2[period];
end

function MP (data, period,TF)



	s1, e2 = core.getcandle(TF, 0, 0, 0);
    BarSize= e2-s1;	 
  local Return=0;
  local End = source:date(period);
  local Start=End-BarSize;
  
  if Start < source:date(source:first()) then
  Start = source:date(source:first());
  end
  
  Average=0;
  Count=0;  
	  
 
 local x= core.findDate(source, Start, false);
 local y= core.findDate(source, End, false);
 
  if   (x <= 0  or y < 0) then
  return 0;
  end
 


  if   (x <= first  or y > source:size()-1) then
  return 0;
  end
	 
				 
	for period = x, y, 1 do
	Count=Count+1;
		if data[period]~= nil then
		Average=Average+data[period];
		end
    end	
	
    if Count~=0 then	
	Return= Average/Count;
	end					          
	
	  return Return;	
  
end
