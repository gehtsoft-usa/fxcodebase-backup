-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72310 

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

function Init()
    indicator:name("RSI Prognosis");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 24, 1, 2000);
    indicator.parameters:addInteger("Depth", "Depth", "", 2000, 24, 2000); 
    indicator.parameters:addInteger("Shift", "Shift", "", 6, 1, 12); 	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", " Real Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Cloud Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period, Depth; 
local first;
local source = nil;
 
local Array;

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
    Period= instance.parameters.Period;
    Depth = instance.parameters.Depth;
	Shift= instance.parameters.Shift;
	
	local Parameters= Period ..  ", " .. Depth  ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
   
    
    first=source:first()+Period;
	
    p = instance:addInternalStream(0, 0);	 
    n = instance:addInternalStream(0, 0);	   
 
	Real = instance:addStream("Real" , core.Line, " Real"," Real",instance.parameters.color1, first);
	Real:setWidth(instance.parameters.width);
    Real:setStyle(instance.parameters.style);
    Real:setPrecision(math.max(2, source:getPrecision()));
	
	Max = instance:addStream("Max" , core.Line, " Max"," Max",instance.parameters.color2, first);
	Max:setWidth(instance.parameters.width);
    Max:setStyle(instance.parameters.style);
    Max:setPrecision(math.max(2, source:getPrecision()));
	
 
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
 
 
    local Delta=(source[period]-source[period-1])/source:pipSize();	
	
	p[period]=0;
	n[period]=0;
	
	
	if Delta > 0 then
	p[period]= Delta;
	else
	n[period]= -Delta;	
	end
	
    if period <= first then
	return;
	end
	
 
 
      local  sump =mathex.sum(p, period-Period+1, period);
      local  sumn =mathex.sum(n, period-Period+1, period);
	  
      local  sum=sump+sumn;
      if(sum~=0) then
      Real[period]=(sump/sum)*100;
	  else
	  Real[period]=0	
      end
 
     if period <= first+Shift+Depth then
	return;
	end

    Array={};	



  for i=0, 100, 1 do
  Array[i]=0;
  end
  
    Add(period);
		
		local max=0;  		
		local MaxValue=0;  		
		  for k =0, 100, 1  do
	 
			  if Array[ k ] > max then
			  		 max=Array[ k ]; 
					 MaxValue=k;
			  end		  
			  		 			
          end
		if MaxValue==0 then
		Max[period]=Max[period-1];
        else		
    	Max[period]=MaxValue;
		end
		
		 
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function Add(period)


  
  for i=Shift , Depth, 1 do
    if  round(Real[period],0) ==  round(Real[period-i],0) then
     Array[  round(Real[period-i+Shift],0)]= Array[ round(Real[period-i+Shift],0)]     +1;
	end
  end

end