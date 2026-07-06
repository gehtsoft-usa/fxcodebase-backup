-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73282

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Advanced fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
 	indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addInteger("Frame", "Max Fractal Number", "", 99, 5,100);

	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));	
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down;
local Frame=0;
local Rez=0;
local Size;

function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;

	
	Frame=instance.parameters.Frame
 
  
    local name = profile:id() .. " ( " .. Frame  .. " )";
    instance:name(name);
	
    if  (nameOnly)  then
	return;
	end 		
	
	up = instance:createTextOutput ("Up", "Up", "Arial", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Arial", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	
end

function Update(period, mode)



    if period < source:first()+Frame then
	return;
	end
	

    local test=0;   
	local i;
	local count=Frame;

	

	 local x ;
	
	if period < count then	    
		 count=period;
	end
	
	  if  ( source:size() -1 - period)  < count  then
	     
		 count=( source:size() -1 - period);		
		
	end
	

	
	
	
	     x = period;
	
        local curr = source.high[x];
	
		
		
         for i= 1, count, 1 do
		
		     if  curr > source.high[x + i] and curr > source.high[x  - i]  then
			 test=test+1;
			 else
			 break;
			 end
			
		 end	
		 
		 if test ~= 0 then
		   up:set(x, source.high[x],  tostring(test));
		 end

        test=0;		 
       
	     curr = source.low[x];
		
		  
          for i= 1 , count, 1 do
		
		     if  curr < source.low[x + i] and curr < source.low[x  - i]  then
			 test=test+1;
			  else
			 break;
			 end
			
		 end	
	   
	     if test ~= 0 then
	      down:set(x, source.low[x], tostring(test));
		end
        
    
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

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