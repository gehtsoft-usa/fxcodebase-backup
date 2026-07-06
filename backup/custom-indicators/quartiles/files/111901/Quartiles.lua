-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64581

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Quartiles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	 indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("SetPrice", "Price Type", "", "1");
    indicator.parameters:addIntegerAlternative("SetPrice", "OPEN", "", "1");
    indicator.parameters:addIntegerAlternative("SetPrice", "HIGH", "", "2");
    indicator.parameters:addIntegerAlternative("SetPrice", "LOW", "", "3");
    indicator.parameters:addIntegerAlternative("SetPrice","CLOSE", "", "4");
    indicator.parameters:addIntegerAlternative("SetPrice", "(High/Low)/2", "", "5");
    indicator.parameters:addIntegerAlternative("SetPrice", "(High+Low+Close)/3", "", "6");
    indicator.parameters:addIntegerAlternative("SetPrice", "(High+Low+2*Close)/4", "", "7");
	indicator.parameters:addIntegerAlternative("SetPrice", "(Open+High+Low+Close)/4.0", "", "8");
    indicator.parameters:addIntegerAlternative("SetPrice", "(Open+Close)/2.0", "", "9");
	
	
	indicator.parameters:addInteger("N", "N", "", 20);
	indicator.parameters:addDouble("p1", "N", "", 0.25);
	indicator.parameters:addDouble("p3", "N", "", 0.75);
 
	
    indicator.parameters:addGroup("Style");
 
	indicator.parameters:addColor("Top", "Color of Top Line ", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Central", "Color of Central Line ", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Bottom", "Color of Bottom Line ", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Central, Top,Bottom;
local first;
local source = nil;
local N, p1, p3;
local PriceArray;
local SetPrice;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    
	N=instance.parameters.N;
	p1=instance.parameters.p1;
	p3=instance.parameters.p3;
	SetPrice=instance.parameters.SetPrice;

	
	first = source:first()+N;
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
 

    
    Central = instance:addStream("Central", core.Line, name, "Central",instance.parameters.Central, first);
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top, first);
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom, first);    
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < first   then
	return;
	end
	
	PriceArray={};
	
	for i=  1, N , 1 do 
	PriceArray[i]=GetPrice(period-i+1);
	end
	
	 table.sort(PriceArray);
	
	local  n2;
	local  q2;
	
	    if(N%2>0)  then          
		n2=(N+1)/2;
        q2=PriceArray[n2-1];
        else 
        n2 = N/2;
        q2 = (PriceArray[n2-1]+PriceArray[n2])/2;
        end
	
	  local n1=round(N*p1,0);
      local q1=PriceArray[n1-1];
      local n3=round(N*p3,0);
      local q3=PriceArray[n3-1];
	  
	  Central[period]=q1;
	  Top[period]=q2;
	  Bottom[period]=q3;
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function GetPrice(Shift) 
 
   
     if SetPrice== 1 then
	 return source.open[Shift];
	 elseif SetPrice== 2 then
	 return source.high[Shift];	
	 elseif SetPrice== 3 then
	 return source.low[Shift];	 	  
	 elseif SetPrice== 4 then
     return source.close[Shift];
	 elseif SetPrice== 5 then
	 return (source.high[Shift]+source.low[Shift])/2.0;
	 elseif SetPrice== 6 then
	 return (source.high[Shift]+source.low[Shift]+source.close[Shift])/3.0;
	 elseif SetPrice== 7 then
	 return (source.high[Shift]+source.low[Shift]+2*source.close[Shift])/4.0
	 elseif SetPrice== 8 then
	 return (source.open[Shift]+source.high[Shift]+source.low[Shift]+source.close[Shift])/4.0;
	 elseif SetPrice== 9 then	
	 return (source.open[Shift]+source.close[Shift])/2.0;
	 end
	     
end