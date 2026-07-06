-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62888

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

function Init()
    indicator:name("Quantum Signal Oscillator");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period", 300);
    indicator.parameters:addBoolean("ReversalOnly", "Trend reversal only", "", true);	 
		 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0)); 
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local ReversalOnly;
local Size; 
local Period;
local first;
local Period;
 
local Confirmation;
local  Signal;
function Prepare(nameOnly)  
    source = instance.source;
	
	
	 local name = profile:id() ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Size = instance.parameters.Size;
	Period = instance.parameters.Period; 
    ReversalOnly= instance.parameters.ReversalOnly;
	
	 
	Signal= instance:addStream("Signal", core.Bar, name .. ".Signal", "MA", instance.parameters.UP, 0);
 
	
	Confirmation = instance:addInternalStream(0, 0);
	
	 
    
	first=source:first()+Period; 
	 
 
end

function Update(period)


       
       Signal[period]=Signal[period-1];
       
       if period < first  then
	   return;
	   end
	  
	   local min,max=mathex.minmax(source,period-Period+1, period);
	  
	   
	   if source.high[period]== max then
        
             Confirmation[period]=1;
			 
			 if  ((ReversalOnly and  Confirmation[period-1]~=1) or not ReversalOnly) then
			 
			 Signal[period]= 1;
			 end 
        
        elseif  source.low[period]== min   then
             if  ((ReversalOnly and  Confirmation[period-1]~=-1) or not ReversalOnly) then
			 
			 Signal[period]= -1;
			 end
			 Confirmation[period]=-1;
       else
	        Confirmation[period]=Confirmation[period-1];
       end
	   
		    
	      
	 
end
