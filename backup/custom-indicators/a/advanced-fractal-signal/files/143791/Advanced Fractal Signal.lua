-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71530

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
    indicator:name("Advanced Fractal Signal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals)", "Number of fractals", 2, 1,99);
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
 
end

local source;
local Oscillator;
local Frame;
local Size;
local first;

function Prepare()
   
	
    Size = instance.parameters.Size;
	Frame = instance.parameters.Frame;
	 
 
    source = instance.source;
	first=source:first()+Frame*2;
	
	
	Up = instance:addStream("Up" , core.Bar, " Up"," Up",instance.parameters.UP, first ); 
    Up:setPrecision(math.max(2, source:getPrecision()));

	Down = instance:addStream("Down" , core.Bar, " Down"," Down",instance.parameters.DOWN, first ); 
    Down:setPrecision(math.max(2, source:getPrecision()));		
  
  local name = profile:id() .. " ( " .. Frame  .. " )";
    instance:name(name);
end

function Update(period, mode)
 
    local ThePeriod=period; 
	period = period-Frame;

 
    
    if (period < first) then
	return;
	end
	
	 Up[ThePeriod]=0;
	 Down[ThePeriod]=0;
	

	    local test=true;
 
	
		
		
         for i= 1, Frame, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end	
		 
		 if test then
		   Up[ThePeriod]=1;
		 end

        test=true; 
		
        for i= 1, Frame, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
	   
	      if test then
		  Down[ThePeriod]=1;
		  end
        
 
end
