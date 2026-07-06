--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Advanced Fractal Based Support/Resistance lines");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fractals", "Number of fractals (Odd)", "Number of fractals (Odd)", 2, 1,99);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
   
	

end

local source;
local S,R;
local Fractals=0;
local Rez=0;
local Size;

function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
   
	Fractals=instance.parameters.Fractals
  	 
 
   first = source:first()+Fractals;
   
  local name = profile:id() .. " ( " .. Fractals .. " )";
  instance:name(name);
  
    if  (nameOnly)  then
	return;
	end
	
  
    R = instance:addStream("R", core.Dot, name .. ".R", "R", instance.parameters.R_color, first);		
    S = instance:addStream("S", core.Dot, name .. ".S", "S", instance.parameters.S_color, first);
	
	R:setWidth(instance.parameters.widthLinReg);   
	S:setWidth(instance.parameters.widthLinReg);
 
end

function Update(period, mode)

	if period < first then
	return;
	end
 
	
	     local x = period - Fractals;
	
       
       local test=true;		
         for i= 1, Fractals, 1 do
		
		     if  source.high[x]  < source.high[x+i]
			 or  source.high[x] < source.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
		 
		 if test then 
          R[period] = source.high[period];
		 else 
		  R[period] = R[period - 1];
			
		 end

        test=true;	 
	   
         for i= 1, Fractals, 1 do
		
		     if  source.low[x] > source.low[x+i]
			 or  source.low[x] > source.low[x-i]
			 then
			 test=false;
			 end
			
		 end	
	   
	      if test then 
          S[period] = source.low[period];
		  else			    
		  S[period] = S[period - 1];			 
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