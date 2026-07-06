-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72011

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility Explosive Measure");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator	);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "length", "", 10, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+1 ; 
	
 
   bulloutput = instance:addInternalStream(0, 0);
   bearoutput = instance:addInternalStream(0, 0);
   irange= instance:addInternalStream(0, 0);
   upbar= instance:addInternalStream(0, 0);
   downbar= instance:addInternalStream(0, 0);
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+length );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
 
 local doji =false

 irange[period] = source.close[period] - source.open[period];
 
 if irange[period] == 0 then
 doji =true;
 end
 

if irange[period] > 0 or doji and irange[period-1] > 0 then
upbar[period]=1;
else
upbar[period]=0;
end

	 if period < first + length
	 then
	 return;
	 end
	 


local bullcounter = barssinceup(period);

if irange[period] < 0 or doji and irange[period-1] < 0 then
downbar[period]=1;
else
downbar[period]=0;
end

local bearcounter = barssincedown(period); 

bulloutput[period]=0;
bearoutput[period]=0;

 if upbar[period]== 1 then
	for i = 0, math.max(0, bullcounter - 1), 1  do
	bulloutput[period] = bulloutput[period] + irange[period-i];
	end
end


 if  downbar[period]== 1 then
	for i = 0, math.max(0, bearcounter - 1), 1  do
	bearoutput[period] = bearoutput[period] + irange[period-i];
	end
end


	Line[period]= mathex.avg(bulloutput, period-length+1, period)-mathex.avg(bearoutput, period-length+1, period);
	
end

function barssinceup(period)

  local Return=-1;
  

  for i= period, first, -1 do
	  if upbar[i]== 0 then
	  Return=i;
	  break;
	  end  
  end
  
  return Return;
  
end

function barssincedown(period)

  local Return=-1;
  

  for i= period, first, -1 do
	  if downbar[i]== 0 then
	  Return=i;
	  break;
	  end  
  end
  
  return Return;
  
end