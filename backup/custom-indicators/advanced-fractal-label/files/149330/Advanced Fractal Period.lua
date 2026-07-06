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
    indicator:name("Advanced  Fractal Period");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 	indicator.parameters:addGroup("Calculation");	  
	indicator.parameters:addInteger("Frame", "Max Fractal Number (Odd)", "", 99, 1,1000);
	
	
	indicator.parameters:addGroup("Line Style");		
    indicator.parameters:addColor("color1", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("color2", "Down fractal color", "Down fractal color", core.rgb(255,0,0));


end

local source;
local up, down;
local Frame=0; 

function Prepare(nameOnly)
    source = instance.source;
    Frame=instance.parameters.Frame
  	
    if  (nameOnly)  then
	return;
	end 		 
  
    local name = profile:id() .. " ( " .. Frame .. " )";
    instance:name(name);
	
	
    Up = instance:addStream("Up", core.Bar, name, "Up", instance.parameters.color1, source:first()+Frame );
    Up:setPrecision(math.max(2, instance.source:getPrecision())); 
    Up:addLevel(0);	

    Down = instance:addStream("Down", core.Bar, name, "Down", instance.parameters.color2, source:first()+Frame );
    Down:setPrecision(math.max(2, instance.source:getPrecision())); 
    Down:addLevel(0);		
end

function Update(period, mode)

 

	if period <= Frame then
	return;
	end
	
 
	
	
	Up[period]=0;
	Down[period]=0;	

 
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
	    Up[period]=test;
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
	    Down[period]=test;
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